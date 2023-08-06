return {
  {
    'zbirenbaum/copilot.lua',
    opts = {
      filetypes = {
        ['.'] = true,
      },
    },
  },
  {
    'zbirenbaum/copilot-cmp',
    -- TODO: Remove once error is fixed
    -- https://github.com/LazyVim/LazyVim/issues/1315
    commit = 'c2cdb3c0f5078b0619055af192295830a7987790',
  },
}
