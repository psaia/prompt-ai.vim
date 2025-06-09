local state = require("prompt_ai.state")

local M = {}

M.options = {
  model = "o4-mini",
  temperature = 1,
  max_history = 8,
}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})
  state.load()
end

return M
