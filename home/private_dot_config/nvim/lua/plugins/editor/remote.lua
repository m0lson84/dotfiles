--[[
remote.nvim (https://github.com/amitds1997/remote-nvim.nvim)
--]]

-- Import utility functions
local util = require('util')

--- Remote startup callback.
---@param port number Port of the remote server.
---@param workspace table Configuration of the development workspace.
local client_launch = function(port, workspace)
  local spawn_client = ('wezterm cli spawn nvim --server localhost:%s --remote-ui'):format(port)
  local cmd = ('wezterm cli set-tab-title --pane-id $(%s) \'Remote: %s\''):format(spawn_client, workspace.host)
  vim.fn.jobstart(cmd, {
    detach = true,
    on_exit = function(job_id, exit_code, event_type)
      print('Job', job_id, 'exited with code', exit_code, 'Event type:', event_type)
    end,
  })
end

--- Create a development container.
local create_container = function()
  local logger = util.get_logger()
  local command = 'devpod up %s --id %s --devcontainer-path .devcontainer/devcontainer.json --ide none'
  local result = vim.api.nvim_cmd({ (command):format(vim.fn.getcwd(), vim.fn.input('Workspace: ')) }, { output = true })
  for _, line in pairs(util.string.split(result, '\n')) do
    logger.debug(line)
  end
end

return {
  {
    'amitds1997/remote-nvim.nvim',
    keys = {
      { '<leader>rc', function() create_container() end, desc = 'Create container' },
      { '<leader>rs', '<cmd>RemoteStart<cr>', desc = 'Start session' },
      {
        '<leader>rx',
        function() return '<cmd>RemoteStop ' .. vim.fn.input('Workspace: ') .. '<cr>' end,
        desc = 'Stop session',
      },
      { '<leader>ri', '<cmd>RemoteSessionInfo<cr>', desc = 'Remote session info' },
      {
        '<leader>rc',
        function() return '<cmd>RemoteCleanup ' .. vim.fn.input('Workspace: ') .. '<cr>' end,
        desc = 'Stop session',
      },
      {
        '<leader>rd',
        function() return '<cmd>RemoteConfigDel ' .. vim.fn.input('Workspace: ') .. '<cr>' end,
        desc = 'Delete configuration',
      },
      { '<leader>rl', '<cmd>RemoteLog<cr>', desc = 'Open remote logs' },
    },
    opts = {
      neovim_install_script_path = util.path.join(vim.fn.stdpath('config'), 'scripts', 'neovim_install.sh'),
      neovim_user_config_path = vim.fn.stdpath('config'),
      local_client_config = { callback = client_launch },
      log = { level = 'debug' },
    },
  },
  {
    'folke/which-key.nvim',
    opts = function(_, opts) opts.defaults['<leader>r'] = { name = '+remote' } end,
  },
}
