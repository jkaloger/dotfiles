return {
  'folke/snacks.nvim',
  ---@type snacks.Config
  opts = {
    image = {},
  },
  config = function(_, opts)
    require('snacks').setup(opts)

    require('snacks.image.doc').transforms.d2 = function(img)
      if not img.content then
        return
      end
      local cache = Snacks.image.config.cache
      vim.fn.mkdir(cache, 'p')
      local bg = vim.o.background
      local png = cache .. '/' .. vim.fn.sha256(img.content .. bg):sub(1, 8) .. '-d2.png'
      if vim.fn.filereadable(png) == 0 then
        local theme = bg == 'light' and 0 or 200
        local svg = vim.system({ 'd2', '--theme', tostring(theme), '--pad', '20', '-', '-' }, { stdin = img.content }):wait(10000)
        vim.system({ 'rsvg-convert', '-z', '2', '-o', png }, { stdin = svg.stdout or '' }):wait(10000)
        if vim.fn.filereadable(png) == 0 then
          return
        end
      end
      img.src = png
      img.content = nil
    end
  end,
}
