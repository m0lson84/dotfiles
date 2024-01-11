--[[
Core debug adapter protocol configuration
--]]

return {
  {
    'mfussenegger/nvim-dap',
    keys = {
      { '<F5>', function() require('dap').continue() end, desc = 'Continue' },
      { '<F9>', function() require('dap').step_out() end, desc = 'Step Out' },
      { '<F10>', function() require('dap').step_over() end, desc = 'Step Over' },
      { '<F11>', function() require('dap').step_into() end, desc = 'Step Into' },
      { '<F12>', function() require('dap').terminate() end, desc = 'Terminate' },
    },
    opts = {
      defaults = {
        fallback = {
          external_terminal = {
            command = 'wezterm',
            args = { '-e' },
          },
        },
      },
    },
  },
  {
    'rcarriga/nvim-dap-ui',
    opts = {
      layouts = {
        {
          elements = {
            { id = 'breakpoints', size = 0.2 },
            { id = 'scopes', size = 0.4 },
            { id = 'stacks', size = 0.4 },
          },
          position = 'left',
          size = 40,
        },
        {
          elements = {
            { id = 'console', size = 0.65 },
            { id = 'repl', size = 0.35 },
          },
          position = 'bottom',
          size = 15,
        },
      },
    },
  },
}
