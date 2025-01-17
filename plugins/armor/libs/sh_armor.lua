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

function characterMeta:AblateArmor(amount)
  local armor = self:GetEquippedArmor()
  armor:SetData("AP", armor:GetData("AP", 0) - amount)
  if armor:GetData("AP") < 0 then armor:SetData("AP", 0) end 
end 

function characterMeta:RepairArmor(amount)
  local armor = self:GetEquippedArmor()
  armor:SetData("AP", armor:GetData("AP", 0) + amount)
  if armor:GetData("AP") > armor:GetData("MaxAP", 0) then armor:SetData("AP", armor:GetData("MaxAP"))  end 
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

function characterMeta:GetMaxAugmentSlots()
  local slots = self:GetSanity()

  if self:GetBackground() == "Adeptus Mechanicus" then
    slots = slots * 2
  end 

  if slots < 0 then slots = 0 end 

  return slots
end 

function characterMeta:GetFreeAugmentSlots()
  local maxslots = self:GetMaxAugmentSlots()

  local inventory = self:GetInventory()
  local usedslots = 0

  for k, v in pairs (inventory:GetItems()) do
    if v:GetData("equip", false) and v.isAugment then usedslots = usedslots + 1 end 
  end


  local freeslots = maxslots - usedslots
  if freeslots < 0 then freeslots = 0 end 

  return freeslots
end 


