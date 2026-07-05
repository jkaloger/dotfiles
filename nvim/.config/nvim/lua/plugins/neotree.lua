return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
    '3rd/image.nvim',
  },
  config = function()
    require('neo-tree').setup {
      enable_git_status = true,
      window = {
        position = 'float',
      },
      event_handlers = {

        {
          event = 'file_opened',
          handler = function(file_path)
            require('neo-tree.command').execute { action = 'close' }
          end,
        },
      },
      buffers = {
        follow_current_file = {
          enabled = true,
        },
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        hijack_netrw_behavior = 'open_current',
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    }
  end,
}
