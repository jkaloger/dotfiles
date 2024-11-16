-- return {
--   "catppuccin/nvim",
--   name = "catppuccin",
--   priority = 1000,
--   opts = {
--     transparent_background = true
--   }
-- }
return {
  "rebelot/kanagawa.nvim",
  name = "kanagawa",
  lazy = false,
  priority = 1000,
  config = "require",
  opts = {
    transparent = true
  }
}
