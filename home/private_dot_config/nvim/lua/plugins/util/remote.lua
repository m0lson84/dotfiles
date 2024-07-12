--[[
remote.nvim (https://github.com/amitds1997/remote-nvim.nvim)
--]]

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

--- Cleanup Neovim installation from remote.
local cleanup_remote = function() return '<cmd>RemoteCleanup ' .. vim.fn.input('Workspace: ') .. '<cr>' end

--- Create a development container.
local create_container = function()
  local logger = util.get_logger()
  local command = 'devpod up %s --id %s --devcontainer-path .devcontainer/devcontainer.json --ide none'
  local result = vim.api.nvim_cmd({ (command):format(vim.fn.getcwd(), vim.fn.input('Workspace: ')) }, { output = true })
  for _, line in pairs(util.string.split(result, '\n')) do
    logger.debug(line)
  end
end

--- Delete workspace configuration.
local delete_config = function() return '<cmd>RemoteConfigDel ' .. vim.fn.input('Workspace: ') .. '<cr>' end

--- Path to the Neovim installation script.
local install_script = function() return util.path.join(vim.fn.stdpath('config'), 'scripts', 'neovim_install.sh') end

--- Stop remote session.
local stop_session = function() return '<cmd>RemoteStop ' .. vim.fn.input('Workspace: ') .. '<cr>' end

return {
  {
    'amitds1997/remote-nvim.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-telescope/telescope.nvim',
    },
    keys = {
      { '<leader>rn', create_container, desc = 'Create container' },
      { '<leader>rs', '<cmd>RemoteStart<cr>', desc = 'Start session' },
      { '<leader>rx', stop_session, desc = 'Stop session' },
      { '<leader>ri', '<cmd>RemoteInfo<cr>', desc = 'Remote session info' },
      { '<leader>rc', cleanup_remote, desc = 'Cleanup remote' },
      { '<leader>rd', delete_config, desc = 'Delete configuration' },
      { '<leader>rl', '<cmd>RemoteLog<cr>', desc = 'Open remote logs' },
    },
    opts = {
      client_callback = client_launch,
      neovim_install_script_path = install_script(),
      log = { level = 'debug' },
    },
  },
  {
    'folke/which-key.nvim',
    opts = {
      spec = {
        { '<leader>r', group = 'remote', icon = { icon = '󰢹', color = 'blue' } },
        { '<leader>rc', name = 'Cleanup remote', icon = { icon = '󰃢', color = 'yellow' } },
        { '<leader>rd', name = 'Delete configuration', icon = { icon = '', color = 'orange' } },
        { '<leader>ri', name = 'Remote session info', icon = { icon = '', color = 'azure' } },
        { '<leader>rl', name = 'Open remote logs', icon = { icon = '', color = 'blue' } },
        { '<leader>rn', name = 'Create container', icon = { icon = '', color = 'cyan' } },
        { '<leader>rs', name = 'Start session', icon = { icon = '', color = 'green' } },
        { '<leader>rx', name = 'Start session', icon = { icon = '', color = 'red' } },
      },
    },
  },
}
