--[[
Core debug adapter protocol configuration
--]]

--- Load all configurations from any found VS Code launch.json files.
---@param path string|nil Path to the directory to start searching in. Defaults to the current working directory.
local load_launchjs = function(path)
  local dap = require('dap')
  local vscode = require('dap.ext.vscode')

  -- Get the path to the configuration directory
  local root_dir = util.config.dir(path)
  if not root_dir then
    vim.notify('Unable to load launch.json: config directory not found.', vim.log.levels.WARN)
    return
  end
  if not util.file.exists(root_dir .. '/' .. 'launch.json') then
    vim.notify('Unable to load launch.json: file not found.', vim.log.levels.WARN)
    return
  end

  -- Clear any existing configurations
  dap.configurations = {}

  -- Load DAP configurations from launch.json
  vscode.load_launchjs(root_dir .. '/' .. 'launch.json')

  -- Convert any 'node' configurations to 'pwa-node'
  for _, filetype in ipairs(vscode.type_to_filetypes.node) do
    if not dap.configurations[filetype] then goto continue end
    for _, config in ipairs(dap.configurations[filetype]) do
      config.console = 'integratedTerminal'
      if config.type == 'node' then config.type = 'pwa-node' end
    end
    ::continue::
  end

  vim.notify('Reloaded configurations from launch.json', vim.log.levels.INFO, { title = 'nvim-dap' })
end

return {
  {
    'mfussenegger/nvim-dap',
    keys = {
      { '<F5>', function() require('dap').continue() end, desc = 'Continue' },
      { '<F9>', function() require('dap').step_out() end, desc = 'Step Out' },
      { '<F10>', function() require('dap').step_over() end, desc = 'Step Over' },
      { '<F11>', function() require('dap').step_into() end, desc = 'Step Into' },
      { '<F12>', function() require('dap').terminate() end, desc = 'Terminate' },
      { '<leader>dv', load_launchjs, desc = 'Load launch.json' },
    },
    opts = function(_, opts)
      local vscode = require('dap.ext.vscode')

      -- Configure adapter client
      opts.defaults = {
        fallback = {
          external_terminal = {
            command = 'wezterm',
            args = { '-e' },
          },
        },
      }

      -- Map debug adapters to filetypes
      vscode.type_to_filetypes = {
        delve = { 'go' },
        go = { 'go' },
        lldb = { 'cpp', 'c', 'rust' },
        node = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        ['pwa-node'] = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        python = { 'python' },
      }

      -- Load configurations from launch.json
      vscode.load_launchjs()

      return opts
    end,
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
            { id = 'repl', size = 0.5 },
            { id = 'console', size = 0.5 },
          },
          position = 'bottom',
          size = 15,
        },
      },
    },
  },
}
