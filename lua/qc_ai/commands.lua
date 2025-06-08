local openai = require("qc_ai.openai")
local state = require("qc_ai.state")

vim.api.nvim_create_user_command("QC", function(opts)
  local prompt = table.concat(opts.fargs, " ")
  openai.call(prompt, function(code)
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
    end)
  end)
end, { nargs = "+" })

vim.api.nvim_create_user_command("QCClearHistory", state.clear_history, {})
vim.api.nvim_create_user_command("QCClearCache", state.clear_cache, {})
