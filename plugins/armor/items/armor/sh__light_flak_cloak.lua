ITEM.name = "Light-Flak Cloak"
ITEM.model = "models/props_c17/BriefCase001a.mdl" -- On-ground model
ITEM.description = "A light-flak cloak." -- Shows up when looked at on ground and in inventory
ITEM.longdesc = "A relatively lightweight and fashionable cloak made from ablative and impact-absorbent materials, capable of deflecting and negating most small-arms, shrapnel and proximity blasts." -- Shows up when looked at in inventory
ITEM.height = 2
ITEM.width = 2
ITEM.isArmor = true
ITEM.isBodyArmor = true
ITEM.humanOnly = true -- Include if armor is only usable by Humans, Abhumans, or Amphii 
ITEM.AP = 5 --Amount of armor, do not add extra points from Good or Best quality
ITEM.type = "Light" -- Light, Medium, Heavy, or Power
ITEM.quality = "Normal" -- Poor, Normal, Good, Best
ITEM.specialQualities = { -- Remove all qualities except those the armor should have
    "Fashionable",
}