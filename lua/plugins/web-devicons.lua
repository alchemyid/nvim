-- lua/plugins/web-devicons.lua
-- Provider ikon visual untuk file-explorer, statusline, tab, & UI elements
return {
  "nvim-tree/nvim-web-devicons",
  lazy = true,
  opts = {
    default = true,
  },
  config = function(_, opts)
    local devicons = require("nvim-web-devicons")
    devicons.setup(opts)

    -- Override ikon yaml & yml ke glyph gear (U+E615) yang kompatibel 100% dengan semua versi Nerd Fonts
    devicons.set_icon({
      yaml = { icon = "", color = "#e5c07b", name = "Yaml" },
      yml  = { icon = "", color = "#e5c07b", name = "Yml" },
    })
  end,
}
