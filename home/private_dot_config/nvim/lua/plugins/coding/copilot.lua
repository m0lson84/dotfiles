--[[
GitHub Copilot (https://github.com/zbirenbaum/copilot.lua)
--]]

return {
  { import = 'lazyvim.plugins.extras.coding.copilot' },
  {
    'zbirenbaum/copilot.lua',
    opts = {
      filetypes = {
        markdown = true,
        ['.'] = false,
      },
    },
  },
}
