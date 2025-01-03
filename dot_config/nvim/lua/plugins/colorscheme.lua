return {
  {
    "tinted-theming/tinted-vim",
    lazy = false,
    priority = 1000,
    config = function()
      local theme_name = vim.fn.system("tinty current")
      vim.g.tinted_background_transparent = 1
      vim.cmd("colorscheme " .. theme_name)
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() end,
    },
  },
  -- once the lualine fork is merged, we can remove this
  -- https://github.com/JamyGolden/lualine.nvim.git
  -- ~home/projects can then also be removed
  {
    "nvim-lualine/lualine.nvim",
    dev = true,
  },
}
