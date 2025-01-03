local function handle_focus_gained()
  local new_theme_name = vim.fn.system("tinty current")
  local current_theme_name = vim.g.colors_name

  if current_theme_name ~= new_theme_name then
    vim.cmd("colorscheme " .. new_theme_name)
  end
end

return {
  {
    "tinted-theming/tinted-vim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.tinted_background_transparent = 1

      local new_theme_name = vim.fn.system("tinty current")
      vim.cmd("colorscheme " .. new_theme_name)
      vim.api.nvim_create_autocmd("FocusGained", {
        callback = handle_focus_gained,
      })
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
