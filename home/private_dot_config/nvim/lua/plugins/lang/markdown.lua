return {

  -- Add markdown to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then vim.list_extend(opts.ensure_installed, { 'markdown' }) end
    end,
  },

  -- TODO: Configure language server
}
