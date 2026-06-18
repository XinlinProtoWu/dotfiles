-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable auto-commenting by default for all filetypes-- Disable auto-commenting by default for all filetypes

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- Corrected: Pass a single string of flags
    vim.opt_local.formatoptions:remove("cro")
  end,
  desc = "Disable auto-commenting on new buffers",
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
  desc = "Disable auto-commenting on new buffers",
})
