# ⚡️ qc-ai - Configure you vim runtime with natural language.

**qc-ai** (short for _quick config_) is a super lightweight Neovim plugin that lets you configure your editor using natural language prompts like:

* `:QC use a light theme and turn on line numbers`
* `:QC optimize for viewing large files`
* `:QC replace word "foo" with "bar"`
* `:QC use the kanagawa-lotus colorscheme`
* `:QC format file`
* Or really anything you can think of.

![Demo](./demo.gif)

---

## ✨ Features

* Easily apply prompt config via natural language (`:QC`)
* Caches responses to avoid redundant API calls
* Remembers previous conversations (limited to recent history)
* Saves history and cache to disk across sessions
* Configurable model, temperature, and history length
* Commands to clear history and cache


> [!TIP]
> This plugin focuses solely on one thing: on-the-fly Vim prompt generation.
> If you're looking for AI-powered file editing or manipulation, check out [vim-ai](https://github.com/madox2/vim-ai).

---

## 📦 Requirements

* Neovim 0.8+
* OpenAI API key in your environment:

```sh
export OPENAI_API_KEY="sk-..."
```

## 🚀 Installation (Lazy.nvim)

```lua
{
  "psaia/qc-ai",
  config = function()
    require("ai_config").setup({
      model = "o4-mini",    -- or "o4-mini" (default)
      temperature = 1  ,    -- controls creativity (default: 1)
      max_history = 8,      -- max prompt/response pairs remembered (default: 8)
    })
  end,
  cmd = { "QC", "QCClearHistory", "QCClearCache" },
}
```

---

## Usage

### Configure with Natural Language

```vim
:QC use gruvbox with transparent background
```

### Clear History

```vim
:QCClearHistory
```

### Clear Cache

```vim
:QCClearCache
```

---

## Where Data is Stored

| File                                         | Purpose                 |
| -------------------------------------------- | ----------------------- |
| `~/.local/share/nvim/ai_config_history.json` | Prompt/response history |
| `~/.local/share/nvim/ai_config_cache.json`   | Prompt → code cache     |
| `/tmp/nvim_ai_config.log`                    | Log file (debug)        |

---

## Privacy & Safety

No telemetry or analytics. Your prompts and configs are never stored or sent anywhere beyond OpenAI's API.

---

## Ideas for the Future

* Different models other than OpenAI
* Telescope integration for history
* Floating preview of generated code

---

#### 🖤 Created by [@psaia](https://github.com/psaia)

