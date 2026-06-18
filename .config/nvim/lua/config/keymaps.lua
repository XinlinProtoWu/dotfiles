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

-- Compile and run the currently opened C++ file
vim.keymap.set("n", "<leader>cc", function()
  -- Safely save the file first
  vim.cmd("write")

  -- Get absolute paths (handles spaces in file paths cleanly)
  local file_path = vim.fn.expand("%:p")
  local output_path = vim.fn.expand("%:p:r")

  -- Construct the shell command
  -- Uses g++ -std=c++20, compiles the file, and runs it if compilation succeeds
  local compile_run_cmd = string.format(
    "g++ -std=c++20 %s -o %s && %s",
    vim.fn.shellescape(file_path),
    vim.fn.shellescape(output_path),
    vim.fn.shellescape(output_path)
  )

  -- Open a horizontal split and execute the command in a terminal buffer
  vim.cmd("split | term " .. compile_run_cmd)
end, { desc = "C++: Compile and Run" })

-- Toggle automatic multi-line comments
vim.keymap.set("n", "<leader>ct", function()
  local formatoptions = vim.bo.formatoptions

  if formatoptions:match("r") or formatoptions:match("o") then
    vim.opt_local.formatoptions:remove("cro")
    vim.notify("Auto-comment DISABLED", vim.log.levels.WARN, { title = "Format Options" })
  else
    vim.opt_local.formatoptions:append("cro")
    vim.notify("Auto-comment ENABLED", vim.log.levels.INFO, { title = "Format Options" })
  end
end, { desc = "Toggle Auto-Commenting" })
