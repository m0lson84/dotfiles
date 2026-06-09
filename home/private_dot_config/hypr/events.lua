--[[
EVENTS
--]]

-- Startup applications
hl.on('hyprland.start', function()
  hl.dispatch(hl.dsp.window.move({ workspace = '1' }))
  hl.exec_cmd('noctalia')
  hl.exec_cmd('1password --silent')
end)

-- Select workspace
hl.on('workspace.created', function(ws)
  if ws.id == 1 then hl.dispatch(hl.dsp.focus({ workspace = ws.id })) end
end)
