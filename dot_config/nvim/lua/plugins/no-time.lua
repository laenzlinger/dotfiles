return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.options.theme = require("lualine.themes.tinted")
      opts.sections.lualine_z = {}
    end,
  },
}
