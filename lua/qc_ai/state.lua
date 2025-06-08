local util = require("qc_ai.util")

local M = {}

M.history = {}
M.cache = {}

local data_path = vim.fn.stdpath("data")
local history_path = data_path .. "/qc_ai_history.json"
local cache_path = data_path .. "/qc_ai_cache.json"

function M.save()
  util.write_json(history_path, M.history)
  util.write_json(cache_path, M.cache)
end

function M.load()
  M.history = util.read_json(history_path) or {}
  M.cache = util.read_json(cache_path) or {}
end

function M.clear_history()
  M.history = {}
  util.write_json(history_path, {})
  vim.notify("QC-AI: History cleared", vim.log.levels.INFO)
end

function M.clear_cache()
  M.cache = {}
  util.write_json(cache_path, {})
  vim.notify("QC-AI: Cache cleared", vim.log.levels.INFO)
end

return M
