return {
  -- set up UI icons
  icons = {
    ActiveLSP = '',
    ActiveTS = ' ',
    BufferClose = '',
    DapBreakpoint = '',
    DapBreakpointCondition = '',
    DapBreakpointRejected = '',
    DapLogPoint = '',
    DapStopped = '',
    DefaultFile = '',
    Diagnostic = '',
    DiagnosticError = '',
    DiagnosticHint = '',
    DiagnosticInfo = '',
    DiagnosticWarn = '',
    Ellipsis = '',
    FileModified = '',
    FileReadOnly = '',
    FoldClosed = '',
    FoldOpened = '',
    FolderClosed = '',
    FolderEmpty = '',
    FolderOpen = '',
    Git = '',
    GitAdd = '',
    GitBranch = '',
    GitChange = '',
    GitConflict = '',
    GitDelete = '',
    GitIgnored = '',
    GitRenamed = '',
    GitStaged = '',
    GitUnstaged = '',
    GitUntracked = '',
    LSPLoaded = '',
    LSPLoading1 = '',
    LSPLoading2 = '',
    LSPLoading3 = '',
    MacroRecording = '',
    Paste = '',
    Search = '',
    Selected = '',
    TabClose = '',
  },
  plugins = {
    {
      'onsails/lspkind.nvim',
      opts = function(_, opts)
        -- use codicons preset
        opts.preset = 'codicons'
        -- set some missing symbol types
        opts.symbol_map = {
          Array = '',
          Boolean = '',
          Key = '',
          Namespace = '',
          Null = '',
          Number = '',
          Object = '',
          Package = '',
          String = '',
        }
        return opts
      end,
    },
  },
}
