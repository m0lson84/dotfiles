return {
  {
    {
      'mofiqul/vscode.nvim',
      as = 'vscode',
      config = function()
        require('vscode.colors').get_colors()
        require('vscode').setup {}
        require('vscode').load()
      end,
    },
  },
}
