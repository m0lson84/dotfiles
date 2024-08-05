--[[
Prettier (https://prettier.io/)
--]]

return {
  {
    'stevearc/conform.nvim',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'prettierd' } } },
    },
    opts = function(_, opts)
      opts.formatters_by_ft = util.table.extend_keys(
        opts.formatters_by_ft,
        { 'css', 'graphql', 'handlebars', 'html', 'less', 'scss', 'vue' },
        { 'prettierd' }
      )
    end,
  },
}
