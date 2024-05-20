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
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "openscad-lsp",
      },
    },
  },
}
