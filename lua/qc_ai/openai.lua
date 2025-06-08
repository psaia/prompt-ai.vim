local config = require("qc_ai.config")
local state = require("qc_ai.state")
local util = require("qc_ai.util")

local M = {}

function M.call(prompt, callback)
  local model = config.options.model
  local cache_key = prompt .. ":" .. model

  if state.cache[cache_key] then
    util.log("[CACHE HIT] " .. cache_key)
    callback(state.cache[cache_key])
    return
  end

  table.insert(state.history, { role = "user", content = prompt })
  while #state.history > config.options.max_history * 2 do
    table.remove(state.history, 1)
  end

  local messages = {
    {
      role = "system",
      content = "You are a Vim configuration assistant. Output valid Lua code only. No Markdown code blocks.",
    },
  }
  vim.list_extend(messages, state.history)

  local payload = {
    model = model,
    temperature = config.options.temperature,
    messages = messages,
  }

  local result = vim.fn.system({
    "curl", "-s",
    "-X", "POST",
    "-H", "Content-Type: application/json",
    "-H", "Authorization: Bearer " .. os.getenv("OPENAI_API_KEY"),
    "https://api.openai.com/v1/chat/completions",
    "-d", vim.fn.json_encode(payload)
  })

  util.log("RAW OpenAI response: " .. result)

  local ok, decoded = pcall(vim.fn.json_decode, result)
  if not ok or not decoded.choices or not decoded.choices[1] then
    vim.notify("QC-AI: Failed to decode OpenAI response", vim.log.levels.ERROR)
    return
  end

  local raw = decoded.choices[1].message.content
  local cleaned = util.clean_code(raw)

  table.insert(state.history, { role = "assistant", content = raw })
  state.cache[cache_key] = cleaned
  state.save()
  callback(cleaned)
end

return M
