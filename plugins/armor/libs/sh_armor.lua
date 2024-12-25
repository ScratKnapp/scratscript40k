local PLUGIN = PLUGIN

local characterMeta = ix.meta.character

function characterMeta:GetEquippedArmor()
    local inventory = self:GetInventory()
    local armor 
  
    for k, v in pairs (inventory:GetItems()) do
      if v:GetData("equip", false) and v.isArmor then armor = v break end 
    end

    return armor
end 

function characterMeta:GetDR()
  local inventory = self:GetInventory()
  local AP = 0
  local DR = 0
  
  if self:GetEquippedArmor() then
    local armor = self:GetEquippedArmor()
    AP = AP + armor:GetData("AP", 0)
  end 

  local strength = self:GetAttribute("strength", 0)
  local racebonus = 0

  if self:GetBackground() == "Tarellian" then racebonus = 2 end 

  DR = AP + strength + racebonus

  return DR
end 

