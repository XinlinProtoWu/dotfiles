-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- PlatformIO Shortcuts (Always runs from project root)
-- <leader>cb to Build/Compile
vim.keymap.set("n", "<leader>cb", function()
  Snacks.terminal.open({ "pio", "run" }, { cwd = LazyVim.root() })
end, { desc = "PlatformIO: Build Project" })

-- <leader>cu to Upload/Flash
vim.keymap.set("n", "<leader>cu", function()
  Snacks.terminal.open({ "pio", "run", "-t", "upload" }, { cwd = LazyVim.root() })
end, { desc = "PlatformIO: Upload to Board" })

-- <leader>cm to Open Serial Monitor
vim.keymap.set("n", "<leader>cm", function()
  Snacks.terminal.open({ "pio", "device", "monitor" }, { cwd = LazyVim.root() })
end, { desc = "PlatformIO: Serial Monitor" })

-- Emacs M-x compile clone: Prompts for a command and pipes errors to Quickfix
vim.keymap.set("n", "<leader>cc", function()
  vim.ui.input({ prompt = "Compile command: ", default = "" }, function(input)
    if not input or input == "" then
      return
    end

    local overseer = require("overseer")
    local task = overseer.new_task({
      name = "Compiler: " .. input,
      cmd = input, -- Executes your manual string directly
      shell = true,
      components = {
        -- This component grabs the output text and feeds it to Neovim's error system
        { "on_output_quickfix", open_on_exit = "failure", tail = false },
        "default",
      },
      -- Tells Neovim to parse using the standard C/C++ compiler error format
      errorformat = vim.o.errorformat,
    })
    task:start()
  end)
end, { desc = "Compile (Emacs style)" })

-- Toggle the compilation buffer/window
vim.keymap.set("n", "<leader>cx", "<cmd>OverseerToggle<cr>", { desc = "Toggle Compilation Window" })

-- Toggle automatic multi-line comments
vim.keymap.set("n", "<leader>ct", function()
  local formatoptions = vim.bo.formatoptions

  if formatoptions:match("r") or formatoptions:match("o") then
    -- Remove flags individually to avoid substring matching issues
    vim.opt_local.formatoptions:remove("c")
    vim.opt_local.formatoptions:remove("r")
    vim.opt_local.formatoptions:remove("o")
    vim.notify("Auto-comment DISABLED", vim.log.levels.WARN, { title = "Format Options" })
  else
    -- Appending as a single string is perfectly safe
    vim.opt_local.formatoptions:append("cro")
    vim.notify("Auto-comment ENABLED", vim.log.levels.INFO, { title = "Format Options" })
  end
end, { desc = "Toggle Auto-Commenting" })

-- Paste from system clipboard (browser) using Space + p
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })

-- Yank to system clipboard using Space + y
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })

-- Duplicate current line and move cursor to the same column on the new line
vim.keymap.set("n", "<leader>cd", function()
  -- Get current cursor position: {line_number, column_byte}
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1]
  local col = cursor_pos[2]

  -- Get the text of the current line
  local current_line = vim.api.nvim_get_current_line()

  -- Insert the line directly underneath
  vim.api.nvim_buf_set_lines(0, row, row, false, { current_line })

  -- Snap the cursor to the exact same column, but on the next line (row + 1)
  vim.api.nvim_win_set_cursor(0, { row + 1, col })
end, { desc = "Duplicate line and follow cursor" })
