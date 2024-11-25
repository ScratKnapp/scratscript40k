local PLUGIN = PLUGIN

local characterMeta = ix.meta.character

function characterMeta:GetEquippedArmor()
    local inventory = self:GetInventory()
    local armor 
  
    for k, v in pairs (inventory:GetItems()) do
      if v:GetData("equip", false) and v.isArmor then armor = v end 
    end

    return armor
end 

