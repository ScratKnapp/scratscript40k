﻿ITEM.name = "PAC Outfit"
ITEM.description = "A PAC Outfit Base."
ITEM.category = "Outfit"
ITEM.model = "models/Gibs/HGIBS.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "hat"
ITEM.pacData = {}
ITEM.pacData = {
  [1] = {
    ["children"] = {
      [1] = {
        ["children"] = {},
        ["self"] = {
          ["Angles"] = Angle(12.919322967529, 6.5696062847564e-006, -1.0949343050015e-005),
          ["Position"] = Vector(-2.099609375, 0.019973754882813, 1.0180969238281),
          ["UniqueID"] = "4249811628",
          ["Size"] = 1.25,
          ["Bone"] = "eyes",
          ["Model"] = "models/Gibs/HGIBS.mdl",
          ["ClassName"] = "model",
        },
      },
    },
    ["self"] = {
      ["ClassName"] = "group",
      ["UniqueID"] = "907159817",
      ["EditorExpand"] = true,
    },
  },
}

ITEM.newSkin = 1
ITEM.replacements = {"group01", "group02"}
ITEM.replacements = "models/manhack.mdl"
ITEM.replacements = {{"male", "female"}, {"group01", "group02"}}
ITEM.bodyGroups = {
  ["blade"] = 1,
  ["bladeblur"] = 1
}

if CLIENT then
  function ITEM:PaintOver(item, w, h)
    if item:GetData("equip") then
      surface.SetDrawColor(110, 255, 110, 100)
      surface.DrawRect(w - 14, h - 14, 8, 8)
    end
  end
end

function ITEM:GetName()
  if self.health and self:GetData("d", 0) >= self.health then return "Broken " .. self.name end
  return self.name
end

function ITEM:RemovePart(client)
  local char = client:GetCharacter()
  self:SetData("equip", false)
  client:RemovePart(self.uniqueID)
  if self.attribBoosts then
    for k, _ in pairs(self.attribBoosts) do
      char:RemoveBoost(self.uniqueID, k)
    end
  end

  Schema:CalculateCharacterInventoryWeight(client, char)
  self:OnUnequipped(client)
  hook.Run("OnPlayerUnequippedItem", client, self, char)
end

ITEM:Hook("drop", function(item) if item:GetData("equip") then item:RemovePart(item:GetOwner()) end end)
ITEM.functions.EquipUn = {
  name = "Unequip",
  tip = "equipTip",
  icon = "icon16/cross.png",
  OnRun = function(item)
    item:RemovePart(item.player)
    item:OnUnequipped(item.player)
    return false
  end,
  OnCanRun = function(item)
    local client = item.player
    return not IsValid(item.entity) and IsValid(client) and item:GetData("equip") == true and hook.Run("CanPlayerUnequipItem", client, item) ~= false
  end
}

ITEM.functions.Equip = {
  name = "Equip",
  tip = "equipTip",
  icon = "icon16/tick.png",
  OnRun = function(item)
    local char = item.player:GetCharacter()
    local items = char:GetInventory():GetItems()
    for _, v in pairs(items) do
      if v.id ~= item.id then
        local itemTable = ix.item.instances[v.id]
        if itemTable and itemTable.pacData and v.outfitCategory == item.outfitCategory and itemTable:GetData("equip") then
          item.player:NotifyLocalized(item.equippedNotify or "outfitAlreadyEquipped")
          return false
        end
      end
    end

    item:SetData("equip", true)
    item.player:AddPart(item.uniqueID, item)
    Schema:CalculateCharacterInventoryWeight(item.player, item.player:GetCharacter())
    if item.attribBoosts then
      for k, v in pairs(item.attribBoosts) do
        char:AddBoost(item.uniqueID, k, v)
      end
    end

    item:OnEquipped(item.player)
    hook.Run("OnPlayerEquippedItem", item.player, item, char)
    return false
  end,
  OnCanRun = function(item)
    local client = item.player
    return not IsValid(item.entity) and IsValid(client) and item:GetData("equip") ~= true and hook.Run("CanPlayerEquipItem", client, item) ~= false
  end
}

function ITEM:CanTransfer(oldInventory, newInventory)
  if newInventory and self:GetData("equip") then return false end
  return true
end

function ITEM:OnRemoved()
  local inventory = ix.item.inventories[self.invID]
  local owner = inventory.GetOwner and inventory:GetOwner()
  if IsValid(owner) and owner:IsPlayer() then if self:GetData("equip") then self:RemovePart(owner) end end
end

function ITEM:OnEquipped(client)
  client:EmitSound("metro2033/actor/dress/mvt_strong_1.mp3")
end

function ITEM:OnUnequipped(client)
  client:EmitSound("metro2033/actor/dress/mvt_strong_2.mp3")
end
