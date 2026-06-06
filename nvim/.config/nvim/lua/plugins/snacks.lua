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
      local png = cache .. '/' .. vim.fn.sha256(img.content .. bg .. 'jbmono-fc'):sub(1, 8) .. '-d2.png'
      if vim.fn.filereadable(png) == 0 then
        local theme = bg == 'light' and 0 or 200
        local fonts = vim.fn.expand '~/Library/Fonts'
        local svg = vim
          .system({
            'd2',
            '--theme',
            tostring(theme),
            '--pad',
            '20',
            '--font-regular',
            fonts .. '/JetBrainsMonoNerdFont-Regular.ttf',
            '--font-italic',
            fonts .. '/JetBrainsMonoNerdFont-Italic.ttf',
            '--font-bold',
            fonts .. '/JetBrainsMonoNerdFont-Bold.ttf',
            '--font-semibold',
            fonts .. '/JetBrainsMonoNerdFont-SemiBold.ttf',
            '--font-mono',
            fonts .. '/JetBrainsMonoNerdFontMono-Regular.ttf',
            '--font-mono-bold',
            fonts .. '/JetBrainsMonoNerdFontMono-Bold.ttf',
            '--font-mono-italic',
            fonts .. '/JetBrainsMonoNerdFontMono-Italic.ttf',
            '--font-mono-semibold',
            fonts .. '/JetBrainsMonoNerdFontMono-SemiBold.ttf',
            '-',
            '-',
          }, { stdin = img.content })
          :wait(10000)

        local families = {
          { 'mono%-semibold', 'JetBrainsMono Nerd Font Mono', '600', 'normal' },
          { 'mono%-bold', 'JetBrainsMono Nerd Font Mono', 'bold', 'normal' },
          { 'mono%-italic', 'JetBrainsMono Nerd Font Mono', 'normal', 'italic' },
          { 'mono', 'JetBrainsMono Nerd Font Mono', 'normal', 'normal' },
          { 'semibold', 'JetBrainsMono Nerd Font', '600', 'normal' },
          { 'bold', 'JetBrainsMono Nerd Font', 'bold', 'normal' },
          { 'italic', 'JetBrainsMono Nerd Font', 'normal', 'italic' },
          { 'regular', 'JetBrainsMono Nerd Font', 'normal', 'normal' },
        }
        local out = svg.stdout or ''
        for _, m in ipairs(families) do
          out =
            out:gsub('font%-family:%s*"?d2%-%d+%-font%-' .. m[1] .. '"?;', "font-family:'" .. m[2] .. "';font-weight:" .. m[3] .. ';font-style:' .. m[4] .. ';')
        end
        vim.system({ 'rsvg-convert', '-z', '2', '-o', png }, { stdin = out }):wait(10000)
        if vim.fn.filereadable(png) == 0 then
          return
        end
      end
      img.src = png
      img.content = nil
    end
  end,
}
