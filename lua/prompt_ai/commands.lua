local openai = require("prompt_ai.openai")
local state = require("prompt_ai.state")

vim.api.nvim_create_user_command("P", function(opts)
  local prompt = table.concat(opts.fargs, " ")
  openai.call(prompt, function(code)
    vim.schedule(function()
      local confirm = vim.fn.confirm("Apply this config?\n\n" .. code, "&Yes\n&No", 1)
      if confirm ~= 1 then
        vim.notify("prompt-ai: cancelled", vim.log.levels.INFO)
        return
      end

      local path = "/tmp/nvim_prompt_config.lua"
      local f = assert(io.open(path, "w"))
      f:write(code)
      f:close()

      vim.cmd("luafile " .. path)
    end)
  end)
end, { nargs = "+" })

vim.api.nvim_create_user_command("PClearHistory", state.clear_history, {})
vim.api.nvim_create_user_command("PClearCache", state.clear_cache, {})
