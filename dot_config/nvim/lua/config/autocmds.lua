-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = { "*" },
  command = "silent! wall",
  nested = true,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.textwidth = 100
    -- 't' auto-wraps text using textwidth
    -- 'c' auto-wraps comments
    vim.opt_local.formatoptions:append("t")
  end,
})
-- Auto-install plugin updates when checker finds them.
-- To disable: remove this autocmd and set checker.notify=true in lazy.lua
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyCheck",
  callback = function() require("lazy").update({ show = false }) end,
})
