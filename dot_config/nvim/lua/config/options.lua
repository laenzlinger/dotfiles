-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

opt.spelllang = { "en", "de" }
opt.spellfile = { vim.fn.stdpath("config") .. "/spell/laenzi.utf8.add" }
