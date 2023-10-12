--[[
GitHub Copilot (https://github.com/zbirenbaum/copilot.lua)
--]]

return {
  {
    'zbirenbaum/copilot.lua',
    keys = {
      { '<leader>cC', '<cmd>Copilot disable<cr>', desc = 'Disable Copilot', mode = { 'n', 'v' } },
      { '<leader>cc', '<cmd>Copilot enable<cr>', desc = 'Enable Copilot', mode = { 'n', 'v' } },
    },
    opts = {
      filetypes = {
        dotenv = false,
        ['*'] = true,
      },
    },
  },
}
