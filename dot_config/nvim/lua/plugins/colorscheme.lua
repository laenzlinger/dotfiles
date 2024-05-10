return {
  {
    "tinted-theming/base16-vim",
    lazy = false,
    priority = 1000,
    config = function()
      local theme_name = vim.fn.system("tinty current")
      vim.g.base16_background_transparent = 1
      vim.cmd("colorscheme " .. theme_name)
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() end,
    },
  },
}
