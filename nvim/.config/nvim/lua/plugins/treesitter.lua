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
      'astro', 'css', 'scss', 'toml', 'json', 'yaml', 'nix',
    }

    require('nvim-treesitter').setup { install_dir = vim.fn.stdpath('data') .. '/site' }
    require('nvim-treesitter').install(parsers)

    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)
        if vim.treesitter.get_parser(args.buf, nil, { error = false }) then
          vim.treesitter.start(args.buf)
        end
      end,
    })
  end,
}
