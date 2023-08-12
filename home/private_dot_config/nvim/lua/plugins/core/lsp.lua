return {
  {
    'folke/neoconf.nvim',
    config = {
      local_settings = '.vim/neoconf.json',
    },
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      format_notify = false,
      inlay_hints = { enabled = true },
    },
  },
}
