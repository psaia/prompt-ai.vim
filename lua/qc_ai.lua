-- qc_ai.lua

local M = {}

M.options = {
  model = "o4-mini",
  temperature = 1,
  max_history = 8,
}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})
  M._load_history()
  M._load_cache()
end

local openai_api_key = os.getenv("OPENAI_API_KEY")
local history_path = vim.fn.stdpath("data") .. "/qc_ai_history.json"
local cache_path = vim.fn.stdpath("data") .. "/qc_ai_cache.json"
local history = {}
local cache = {}

local function append_log(content)
  local log_path = "/tmp/nvim_qc_ai.log"
  local file = io.open(log_path, "a")
  if file then
    file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - " .. content .. "\n")
    file:close()
  end
end

local function clean_code_block(text)
  local code = text:match("```lua(.-)```") or text:match("```(.-)```")
  if code then
    return vim.trim(code)
  end
  return vim.trim(text)
end

function M._save_history()
  local f = io.open(history_path, "w")
  if f then
    f:write(vim.fn.json_encode(history))
    f:close()
  end
end

function M._save_cache()
  local f = io.open(cache_path, "w")
  if f then
    f:write(vim.fn.json_encode(cache))
    f:close()
  end
end

function M._load_history()
  local f = io.open(history_path, "r")
  if f then
    local content = f:read("*a")
    f:close()
    local ok, data = pcall(vim.fn.json_decode, content)
    if ok and type(data) == "table" then
      history = data
    end
  end
end

function M._load_cache()
  local f = io.open(cache_path, "r")
  if f then
    local content = f:read("*a")
    f:close()
    local ok, data = pcall(vim.fn.json_decode, content)
    if ok and type(data) == "table" then
      cache = data
    end
  end
end

function M.clear_history()
  history = {}
  local f = io.open(history_path, "w")
  if f then
    f:write("[]")
    f:close()
  end
  vim.notify("AI config history cleared", vim.log.levels.INFO)
end

function M.clear_cache()
  cache = {}
  local f = io.open(cache_path, "w")
  if f then
    f:write("{}")
    f:close()
  end
  vim.notify("AI config cache cleared", vim.log.levels.INFO)
end

local function call_openai(prompt, callback)
  local cache_key = prompt .. ":" .. M.options.model
  if cache[cache_key] then
    append_log("[CACHE HIT] " .. cache_key)
    callback(cache[cache_key])
    return
  end

  table.insert(history, { role = "user", content = prompt })

  -- Trim history to max_history * 2 (user + assistant pairs)
  while #history > M.options.max_history * 2 do
    table.remove(history, 1)
  end

  local messages = {
    { 
      role = "system",
      content = "You are a Vim configuration assistant. Output valid Lua code to apply the user's request. Do not include Markdown code block formatting (no triple backticks). 'this' refers to the file the user is currently looking at in their vim buffer. Only provide commands."
    },
  }

  for _, msg in ipairs(history) do
    table.insert(messages, msg)
  end

  local json = vim.fn.json_encode({
    model = M.options.model,
    messages = messages,
    temperature = M.options.temperature
  })

  local result = vim.fn.system({
    "curl", "-s",
    "-X", "POST",
    "-H", "Content-Type: application/json",
    "-H", "Authorization: Bearer " .. openai_api_key,
    "https://api.openai.com/v1/chat/completions",
    "-d", json
  })

  append_log("RAW OpenAI response: " .. result)

  local ok, decoded = pcall(vim.fn.json_decode, result)
  if not ok or not decoded.choices or not decoded.choices[1] then
    vim.notify("Failed to decode OpenAI response", vim.log.levels.ERROR)
    return
  end

  local raw_code = decoded.choices[1].message.content
  local cleaned_code = clean_code_block(raw_code)
  table.insert(history, { role = "assistant", content = raw_code })
  cache[cache_key] = cleaned_code
  M._save_history()
  M._save_cache()
  callback(cleaned_code)
end

function M.configure_from_prompt(prompt)
  call_openai(prompt, function(code)
    vim.schedule(function()
      local confirm = vim.fn.confirm("Apply this config?\n\n" .. code, "&Yes\n&No", 1)
      if confirm ~= 1 then
        vim.notify("QC-AI: Cancelled", vim.log.levels.INFO)
        return
      end

      local path = "/tmp/nvim_ai_config.lua"
      local f = assert(io.open(path, "w"))
      f:write(code)
      f:close()

      vim.cmd("luafile " .. path)
      vim.notify("QC-AI: Config applied", vim.log.levels.INFO)
    end)
  end)
end

vim.api.nvim_create_user_command("QC", function(opts)
  local prompt = table.concat(opts.fargs, " ")
  M.configure_from_prompt(prompt)
end, { nargs = "+" })

vim.api.nvim_create_user_command("QCClearHistory", function()
  M.clear_history()
end, {})

vim.api.nvim_create_user_command("QCClearCache", function()
  M.clear_cache()
end, {})

return M
