--[[
Go language support
--]]

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, { 'templ' })
      vim.treesitter.language.register('gotmpl', 'tmpl')
    end,
  },

  -- Configure debug adapter
  {
    'mfussenegger/nvim-dap',
    opts = function(_, opts)
      for _, config in ipairs(require('dap').configurations.go) do
        config.console = 'integratedTerminal'
      end
      return opts
    end,
  },

  -- Code annotations and documentation
  {
    'danymat/neogen',
    opts = {
      languages = {
        go = { template = { annotation_convention = 'godoc' } },
      },
    },
  },
}
