return {
  'stevearc/conform.nvim',
  opts = {},
  config = function()
    require('conform').setup({
      formatters_by_ft = {
        javascript = { "eslint_d", "prettierd" },
        typescript = { "eslint_d", "prettierd" },
        typescriptreact = { "eslint_d", "prettierd" },
        javascriptreact = { "eslint_d", "prettierd" },
        astro = { "eslint_d", "prettierd" },
        json = { "prettierd" },
        html = { "prettierd" },
        css = { "prettierd" },
        scss = { "prettierd" },
        markdown = { "prettierd" },
      },
      format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 2000,
        lsp_fallback = true,
      },
    })

    -- Setup keybinding for manual formatting
    vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
      require('conform').format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 2000,
      })
    end, { desc = 'Format file or range (in visual mode)' })
  end
}
