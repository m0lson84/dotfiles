--[[
taplo (https://taplo.tamasfe.dev/)
--]]

return {
  {
    'stevearc/conform.nvim',
    depends = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'taplo' } } },
    },
    opts = {
      formatters = {
        taplo = {
          args = {
            'format',
            '--option',
            'column_width=120',
            '--option',
            'align_entries=true',
            '--option',
            'reorder_keys=true',
            '--option',
            'reorder_arrays=true',
            '-',
          },
        },
      },
    },
  },
}
