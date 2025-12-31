return {
  "tinted-theming/tinted-nvim",
  config = function()
    local tinted = require("tinted-colorscheme")
    tinted.setup(nil, {
      supports = {
        live_reload = true,
      },
      highlights = {
        telescope = true,
        telescope_borders = false,
        indentblankline = true,
        notify = true,
        cmp = true,
        ts_rainbow = true,
        illuminate = true,
        lsp_semantic = true,
        mini_completion = true,
        dapui = true,
      },
    })
  end,
}
