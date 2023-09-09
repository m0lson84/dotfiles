--[[
GitHub Copilot (https://github.com/zbirenbaum/copilot.lua)
--]]

return {
  { import = 'lazyvim.plugins.extras.coding.copilot' },
  {
    'zbirenbaum/copilot.lua',
    keys = {
      { '<leader>cc', '<cmd>Copilot! attach<cr>', desc = 'Enable Copilot', mode = { 'n', 'v' } },
      { '<leader>cC', '<cmd>Copilot disable<cr>', desc = 'Disable Copilot', mode = { 'n', 'v' } },
    },
    opts = {
      filetypes = {
        markdown = true,
        ['*'] = false,
      },
    },
  },
}
