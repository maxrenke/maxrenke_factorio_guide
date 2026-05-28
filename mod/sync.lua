local sync = {}
local phases_def = require("phases")

function sync.write_progress(player_index)
  local player = game.players[player_index]
  if not player or not storage.players[player_index] then return end

  local progress = storage.players[player_index]

  local safe_name = player.name:gsub('\\', '\\\\'):gsub('"', '\\"')

  local lines = {}
  table.insert(lines, '{')
  table.insert(lines, '  "version": "1.0.0",')
  table.insert(lines, '  "player": "' .. safe_name .. '",')
  table.insert(lines, '  "exported_tick": ' .. game.tick .. ',')
  table.insert(lines, '  "phases": {')

  local phase_entries = {}
  for _, phase in ipairs(phases_def) do
    local phase_tasks = progress.tasks[phase.id] or {}
    local tasks_parts = {}
    for _, task in ipairs(phase.tasks) do
      local done = phase_tasks[task.id] and "true" or "false"
      table.insert(tasks_parts, '      "' .. task.id .. '": ' .. done)
    end
    local phase_done = progress.phases[phase.id] and "true" or "false"
    local entry = '    "' .. phase.id .. '": {\n'
      .. '      "completed": ' .. phase_done .. ',\n'
      .. '      "tasks": {\n'
      .. table.concat(tasks_parts, ',\n') .. '\n'
      .. '      }\n'
      .. '    }'
    table.insert(phase_entries, entry)
  end

  table.insert(lines, table.concat(phase_entries, ',\n'))
  table.insert(lines, '  }')
  table.insert(lines, '}')

  local json_str = table.concat(lines, '\n')
  helpers.write_file("guide_progress.json", json_str, false)
  player.print("[Guide] Progress exported to script-output/guide_progress.json")
end

-- Heartbeat: written periodically so the local server / webpage can detect
-- whether Factorio is running and the mod is active. The mod cannot read files
-- or reach the network, so connection verification happens browser-side off the
-- freshness (mtime) of this file.
function sync.write_heartbeat()
  local n = 0
  for _, p in pairs(game.players) do
    if p.connected then n = n + 1 end
  end
  local hb = '{ "tick": ' .. game.tick .. ', "players_online": ' .. n .. ' }'
  helpers.write_file("guide_heartbeat.json", hb, false)
end

return sync
