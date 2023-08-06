return {
  {
    'mxsdev/nvim-dap-vscode-js',
    dependencies = { 'mfussenegger/nvim-dap' },
    -- Make sure that vscode-js-debug is installed
    -- https://github.com/mxsdev/nvim-dap-vscode-js#debugger
    -- TODO: Investigate how this differs from https://www.lazyvim.org/extras/lang/typescript#nvim-dap
  },
}
