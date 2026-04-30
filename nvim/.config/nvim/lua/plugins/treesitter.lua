return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local parsers = {
      'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx',
      'javascript', 'typescript', 'vimdoc', 'vim', 'bash',
      'svelte', 'markdown', 'markdown_inline', 'latex',
    }

    require('nvim-treesitter').install(parsers)

    vim.treesitter.language.register('vimdoc', 'vim')

    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)
        local ft = vim.bo[args.buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)
        if lang and pcall(vim.treesitter.language.add, lang) then
          pcall(vim.treesitter.start, args.buf, lang)
        end
      end,
    })
  end,
}
