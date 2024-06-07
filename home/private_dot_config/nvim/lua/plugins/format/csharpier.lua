--[[
csharpier (https://csharpier.com)
--]]

return {
  {
    'stevearc/conform.nvim',
    depends = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'csharpier' } } },
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
