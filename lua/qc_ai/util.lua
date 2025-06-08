local M = {}

function M.log(msg)
  local path = "/tmp/nvim_qc_ai.log"
  local f = io.open(path, "a")
  if f then
    f:write(os.date("%F %T") .. " - " .. msg .. "\n")
    f:close()
  end
end

function M.clean_code(text)
  local code = text:match("```lua(.-)```") or text:match("```(.-)```")
  return vim.trim(code or text)
end

function M.read_json(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local ok, decoded = pcall(vim.fn.json_decode, f:read("*a"))
  f:close()
  return ok and decoded or nil
end

function M.write_json(path, data)
  local f = io.open(path, "w")
  if not f then return end
  f:write(vim.fn.json_encode(data))
  f:close()
end

return M
