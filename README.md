# ⚡️ QC-AI: Quick Config for Neovim with OpenAI

> Natural language Vim config powered by AI.

**QC-AI** is a Neovim plugin that lets you configure your editor using natural language prompts like:

```vim
:QC use a light theme and turn on line numbers
```

It uses OpenAI’s API to generate and apply valid Lua code that configures your Neovim environment on the fly. Think of it as your personal Vim butler.

![Demo](./qc.gif)

---

## ✨ Features

* Instantly apply settings via natural language (`:QC`)
* Caches responses to avoid redundant API calls
* Remembers previous conversations (limited to recent history)
* Saves history and cache to disk across sessions
* Configurable model, temperature, and history length
* Commands to clear history and cache

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

## 🛠 Usage

### 🧠 Configure with Natural Language

```vim
:QC use gruvbox with transparent background
```

### 🔄 Clear History

```vim
:QCClearHistory
```

### ♻️ Clear Cache

```vim
:QCClearCache
```

---

## 📂 Where Data is Stored

| File                                         | Purpose                 |
| -------------------------------------------- | ----------------------- |
| `~/.local/share/nvim/ai_config_history.json` | Prompt/response history |
| `~/.local/share/nvim/ai_config_cache.json`   | Prompt → code cache     |
| `/tmp/nvim_ai_config.log`                    | Log file (debug)        |

---

## 🔐 Privacy & Safety

No telemetry or analytics. Your prompts and configs are never stored or sent anywhere beyond OpenAI's API.

---

## 💡 Ideas for the Future

* Telescope integration for history
* Floating preview of generated code

---

#### 🖤 Created by [@psaia](https://github.com/psaia)

