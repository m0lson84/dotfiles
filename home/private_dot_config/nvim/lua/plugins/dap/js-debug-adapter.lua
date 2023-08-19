--[[
js-debug-adapter (https://github.com/mxsdev/nvim-dap-vscode-js)
--]]

return {
  {
    'mfussenegger/nvim-dap',
    optional = true,
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          table.insert(opts.ensure_installed, 'js-debug-adapter')
        end,
      },
    },
    opts = function()
      local dap = require('dap')
      if not dap.adapters.node then
        require('dap').adapters.node = {
          type = 'server',
          host = 'localhost',
          port = '${port}',
          executable = {
            command = 'node',
            args = {
              require('mason-registry').get_package('js-debug-adapter'):get_install_path()
                .. '/js-debug/src/dapDebugServer.js',
              '${port}',
            },
          },
        }
      end
      local languages = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }
      require('dap.ext.vscode').load_launchjs(nil, { node = languages })
      for _, language in ipairs(languages) do
        if not dap.configurations[language] then
          dap.configurations[language] = {
            {
              type = 'node',
              request = 'launch',
              name = 'Launch file',
              program = '${file}',
              cwd = '${workspaceFolder}',
            },
            {
              type = 'node',
              request = 'attach',
              name = 'Attach',
              processId = require('dap.utils').pick_process,
              cwd = '${workspaceFolder}',
            },
          }
        end
      end
    end,
  },
}
