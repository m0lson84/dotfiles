--[[
Core UI configuration
--]]

return {
  {
    'akinsho/bufferline.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = function(_, opts)
      local bufferline = require('bufferline')
      opts.options = require('util').table.merge(opts.options, {
        groups = { items = { bufferline.groups.builtin.pinned:with({ icon = '' }) } },
        hover = { enabled = true, delay = 100, reveal = { 'close' } },
        always_show_bufferline = false,
        sort_by = 'relative_directory',
        buffer_close_icon = '󰖭',
      })
      return opts
    end,
  },
  {
    'echasnovski/mini.icons',
    opts = {
      extension = {
        bash = { glyph = '', hl = 'MiniIconsGray' },
        kdl = { glyph = '', hl = 'MiniIconsYellow' },
        tmpl = { glyph = '󰟓', hl = 'MiniIconsGray' },
        zsh = { glyph = '', hl = 'MiniIconsGray' },
        ['bash.tmpl'] = { glyph = '', hl = 'MiniIconsGray' },
        ['kdl.tmpl'] = { glyph = '', hl = 'MiniIconsGray' },
        ['ps1.tmpl'] = { glyph = '󰨊', hl = 'MiniIconsGray' },
        ['sh.tmpl'] = { glyph = '', hl = 'MiniIconsGray' },
        ['toml.tmpl'] = { glyph = '', hl = 'MiniIconsGray' },
        ['yaml.tmpl'] = { glyph = '', hl = 'MiniIconsGray' },
        ['zsh.tmpl'] = { glyph = '', hl = 'MiniIconsGray' },
      },
      file = {
        ['.chezmoiroot'] = { glyph = '', hl = 'MiniIconsGray' },
        ['.chezmoiversion'] = { glyph = '', hl = 'MiniIconsGray' },
        ['.eslintrc.js'] = { glyph = '󰱺', hl = 'MiniIconsYellow' },
        ['.gitkeep'] = { glyph = '󰊢', hl = 'MiniIconsGray' },
        ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGray' },
        ['.node-version'] = { glyph = '', hl = 'MiniIconsGreen' },
        ['.prettierrc'] = { glyph = '', hl = 'MiniIconsPurple' },
        ['.yarnrc.yml'] = { glyph = '', hl = 'MiniIconsBlue' },
        ['CODEOWNERS'] = { glyph = '', hl = 'MiniIconsGreen' },
        ['devcontainer.json'] = { glyph = '', hl = 'MiniIconsAzure' },
        ['eslint.config.js'] = { glyph = '󰱺', hl = 'MiniIconsYellow' },
        ['go.mod'] = { glyph = '', hl = 'MiniIconsAzure' },
        ['go.sum'] = { glyph = '', hl = 'MiniIconsCyan' },
        ['package.json'] = { glyph = '', hl = 'MiniIconsGreen' },
        ['tsconfig.json'] = { glyph = '', hl = 'MiniIconsAzure' },
        ['tsconfig.build.json'] = { glyph = '', hl = 'MiniIconsAzure' },
        ['yarn.lock'] = { glyph = '', hl = 'MiniIconsBlue' },
      },
    },
  },
  {
    'folke/noice.nvim',
    opts = function(_, opts) opts.presets.lsp_doc_border = true end,
  },
  {
    'nvimdev/dashboard-nvim',
    dependencies = { 'MaximilianLloyd/ascii.nvim' },
    opts = function(_, opts)
      local logo = table.concat(require('ascii').get_random('text', 'neovim'), '\n')
      opts.config.header = vim.split(string.rep('\n', 8) .. logo .. '\n\n', '\n')
    end,
  },
}
