-- lua/plugins/transparent.lua
return {
  "xiyaowong/transparent.nvim",
  config = function()
    require("transparent").setup({
      extra_groups = { -- Ensure these UI elements are also transparent
        "NormalFloat",
        "FloatBorder",
      },
    })
  end,
}
