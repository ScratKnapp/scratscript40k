ITEM.name = "Flak Jacket"
ITEM.model = "models/props_c17/BriefCase001a.mdl" -- On-ground model
ITEM.description = "A flak jacket." -- Shows up when looked at on ground and in inventory
ITEM.longdesc = "A flak jacket made from a combination of ablative and blast-absorbent materials, covering the body, arms, and legs - it is effective in protecting against small-arms and shrapnel, moreso against explosives as it is very blast-resistant." -- Shows up when looked at in inventory
ITEM.height = 2
ITEM.width = 2
ITEM.isArmor = true
ITEM.isBodyArmor = true
ITEM.humanOnly = true -- Include if armor is only usable by Humans, Abhumans, or Amphii 
ITEM.AP = 7 --Amount of armor, do not add extra points from Good or Best quality
ITEM.type = "Medium" -- Light, Medium, Heavy, or Power
ITEM.quality = "Normal" -- Poor, Normal, Good, Best
ITEM.specialQualities = { -- Remove all qualities except those the armor should have
    "Blast-Resistant",
}