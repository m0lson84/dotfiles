--[[
Neogen (https://github.com/danymat/neogen)
--]]

--- The file types that Neogen will generate documentation for.
local file_types = { 'bash', 'cs', 'go', 'javascript', 'lua', 'python', 'rust', 'sh', 'typescript', 'zsh' }

--- Generate code annotations.
local gen_docs = function() require('neogen').generate({ type = 'any' }) end

return {
  {
    'danymat/neogen',
    cmd = 'Neogen',
    opts = {
      languages = {},
    },
    keys = {
      { '<leader>cn', gen_docs, ft = file_types, desc = 'Generate documentation' },
    },
  },
}
