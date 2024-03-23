--[[
Rust language support
--]]

return {

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts) opts.servers.rust_analyzer = nil end,
  },

  -- Code annotations and documentation
  {
    'danymat/neogen',
    opts = {
      languages = {
        rust = { template = { annotation_convention = 'rustdoc' } },
      },
    },
  },
}
