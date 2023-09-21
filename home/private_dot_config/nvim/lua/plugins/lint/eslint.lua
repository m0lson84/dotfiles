--[[
ESLint (https://eslint.org/)
--]]

return {
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'eslint-lsp', 'eslint_d' }) end,
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        eslint = {
          settings = { workingDirectory = { mode = 'auto' } },
        },
      },
      setup = {
        eslint = function()
          vim.api.nvim_create_autocmd('BufWritePre', {
            callback = function(event)
              if not require('lazyvim.plugins.lsp.format').enabled() then return end
              local client = vim.lsp.get_active_clients({ bufnr = event.buf, name = 'eslint' })[1]
              if not client then return end
              local diag = vim.diagnostic.get(event.buf, { namespace = vim.lsp.diagnostic.get_namespace(client.id) })
              if #diag > 0 then vim.cmd('EslintFixAll') end
            end,
          })
        end,
      },
    },
  },
  {
    'nvimtools/none-ls.nvim',
    opts = function(_, opts)
      vim.list_extend(opts.sources, {
        require('null-ls').builtins.formatting.eslint_d,
      })
    end,
  },
}
