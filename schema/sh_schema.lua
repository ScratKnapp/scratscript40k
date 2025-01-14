Schema.name = "Scratscipt 40k"
Schema.author = "nebulous"
Schema.description = "A base schema for development."
ix.util.Include("cl_schema.lua")
ix.util.Include("sv_schema.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_hooks.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("libs/thirdparty/sh_netstream2.lua")
ix.util.Include("meta/sh_character.lua")
ix.util.Include("meta/sh_player.lua")
ix.flag.Add("N", "Event/Customization")
ix.flag.Add("1", "Trade")
