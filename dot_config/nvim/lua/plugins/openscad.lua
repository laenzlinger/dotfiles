return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        openscad_lsp = {},
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "openscad-lsp",
      },
    },
  },
  {
    "salkin-mada/openscad.nvim",
    config = function()
      vim.g.openscad_load_snippets = true
      require("openscad")
    end,
    dependencies = { "L3MON4D3/LuaSnip", "junegunn/fzf.vim" },
  },
}
