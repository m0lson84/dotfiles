return {
  { import = 'lazyvim.plugins.extras.coding.copilot' },
  {
    'zbirenbaum/copilot.lua',
    opts = {
      filetypes = {
        ['.'] = true,
      },
    },
  },
  { 'zbirenbaum/copilot-cmp' },
}
