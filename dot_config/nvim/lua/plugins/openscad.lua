return {
  {
    "neovim/nvim-lspconfig",
    servers = {
      openscad_lsp = {},
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "openscad-lsp",
      },
    },
  },
}
