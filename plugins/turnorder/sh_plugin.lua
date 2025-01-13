local PLUGIN = PLUGIN
PLUGIN.name = "Initiative System"
PLUGIN.author = "Sherrogi"
PLUGIN.description = "Adds a turn-based initiative system to Helix."
ix.util.Include(PLUGIN.folder .. "/core/sh_turns.lua")
ix.util.Include(PLUGIN.folder .. "/core/sv_turns.lua")
ix.util.Include(PLUGIN.folder .. "/core/cl_turns.lua")