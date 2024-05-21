--[[
csharpier (https://csharpier.com)
--]]

return {
  {
    'stevearc/conform.nvim',
    depends = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'csharpier' }) end,
      },
    },
    opts = {
      formatters = {
        csharpier = {
          command = 'dotnet-csharpier',
          args = { '--write-stdout' },
        },
      },
    },
  },
}
