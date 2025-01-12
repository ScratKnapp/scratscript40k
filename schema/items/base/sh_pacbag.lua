ITEM.invWidth = 4
ITEM.invHeight = 2
ITEM.category = "Storage"
ITEM.isBag = true
ITEM.functions.View = {
  icon = "icon16/briefcase.png",
  OnClick = function(item)
    local index = item:GetData("id", "")
    if index then
      local panel = ix.gui["inv" .. index]
      local inventory = ix.item.inventories[index]
      local parent = IsValid(ix.gui.menuInventoryContainer) and ix.gui.menuInventoryContainer or ix.gui.openedStorage
      if IsValid(panel) then panel:Remove() end
      if inventory and inventory.slots then
        panel = vgui.Create("ixInventory", IsValid(parent) and parent or nil)
        panel:SetInventory(inventory)
        panel:ShowCloseButton(true)
        panel:SetTitle(item.GetName and item:GetName() or L(item.name))
        if parent ~= ix.gui.menuInventoryContainer then
          panel:Center()
          if parent == ix.gui.openedStorage then panel:MakePopup() end
        else
          panel:MoveToFront()
        end

        ix.gui["inv" .. index] = panel
      else
        ErrorNoHalt("[Helix] Attempt to view an uninitialized inventory '" .. index .. "'\n")
      end
    end
    return false
  end,
  OnCanRun = function(item) return not IsValid(item.entity) and item:GetData("id") and not IsValid(ix.gui["inv" .. item:GetData("id", "")]) end
}

if CLIENT then
  function ITEM:PaintOver(item, width, height)
    local panel = ix.gui["inv" .. item:GetData("id", "")]
    if item:GetData("equip") then
      surface.SetDrawColor(110, 255, 110, 100)
      surface.DrawRect(width - 14, height - 14, 8, 8)
    end

    if not IsValid(panel) then return end
    if vgui.GetHoveredPanel() == self then
      panel:SetHighlighted(true)
    else
      panel:SetHighlighted(false)
    end
  end
end

function ITEM:RemovePart(client)
  local char = client:GetCharacter()
  self:SetData("equip", false)
  client:RemovePart(self.uniqueID)
  Schema:CalculateCharacterInventoryWeight(client, char)
  if self.attribBoosts then
    for k, _ in pairs(self.attribBoosts) do
      char:RemoveBoost(self.uniqueID, k)
    end
  end

  self:OnUnequipped(client)
  hook.Run("OnPlayerUnequippedItem", client, self, char)
end

ITEM:Hook("drop", function(item) if item:GetData("equip") then item:RemovePart(item:GetOwner()) end end)
ITEM.functions.EquipUn = {
  name = "Unequip",
  tip = "equipTip",
  icon = "icon16/cross.png",
  OnRun = function(item)
    local client = item.player
    item:RemovePart(client)
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
    local client = item.player
    local char = client:GetCharacter()
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
    client:AddPart(item.uniqueID, item)
    Schema:CalculateCharacterInventoryWeight(client, char)
    if item.attribBoosts then
      for k, v in pairs(item.attribBoosts) do
        char:AddBoost(item.uniqueID, k, v)
      end
    end

    item:OnEquipped(client)
    hook.Run("OnPlayerEquippedItem", client, item, char)
    return false
  end,
  OnCanRun = function(item)
    local client = item.player
    return not IsValid(item.entity) and IsValid(client) and item:GetData("equip") ~= true and hook.Run("CanPlayerEquipItem", client, item) ~= false
  end
}

function ITEM:OnRemoved()
  local inventory = ix.item.inventories[self.invID]
  local owner = inventory.GetOwner and inventory:GetOwner()
  if IsValid(owner) and owner:IsPlayer() then if self:GetData("equip") then self:RemovePart(owner) end end
  local index = self:GetData("id")
  if index then
    local query = mysql:Delete("ix_items")
    query:Where("inventory_id", index)
    query:Execute()
    query = mysql:Delete("ix_inventories")
    query:Where("inventory_id", index)
    query:Execute()
  end
end

function ITEM:OnEquipped(client)
  client:EmitSound("pixelaffection/misc/bag_equip.mp3")
end

function ITEM:OnUnequipped(client)
  client:EmitSound("pixelaffection/misc/bag_unequip.mp3")
end

function ITEM:OnInstanced(invID, x, y)
  local inventory = ix.item.inventories[invID]
  ix.inventory.New(inventory and inventory.owner or 0, self.uniqueID, function(inv)
    local client = inv:GetOwner()
    inv.vars.isBag = self.uniqueID
    self:SetData("id", inv:GetID())
    if IsValid(client) then inv:AddReceiver(client) end
  end)
end

function ITEM:GetInventory()
  local index = self:GetData("id")
  if index then return ix.item.inventories[index] end
end

ITEM.GetInv = ITEM.GetInventory
function ITEM:OnSendData()
  local index = self:GetData("id")
  if index then
    local inventory = ix.item.inventories[index]
    if inventory then
      inventory.vars.isBag = self.uniqueID
      inventory:Sync(self.player)
      inventory:AddReceiver(self.player)
    else
      local owner = self.player:GetCharacter():GetID()
      ix.inventory.Restore(self:GetData("id"), self.invWidth, self.invHeight, function(inv)
        inv.vars.isBag = self.uniqueID
        inv:SetOwner(owner, true)
        if not inv.owner then return end
        for client, character in ix.util.GetCharacters() do
          if character:GetID() == inv.owner then
            inv:AddReceiver(client)
            break
          end
        end
      end)
    end
  else
    ix.inventory.New(self.player:GetCharacter():GetID(), self.uniqueID, function(inv) self:SetData("id", inv:GetID()) end)
  end
end

ITEM.postHooks.drop = function(item, result)
  local index = item:GetData("id")
  local query = mysql:Update("ix_inventories")
  query:Update("character_id", 0)
  query:Where("inventory_id", index)
  query:Execute()
  net.Start("ixBagDrop")
  net.WriteUInt(index, 32)
  net.Send(item.player)
end

if CLIENT then
  net.Receive("ixBagDrop", function()
    local index = net.ReadUInt(32)
    local panel = ix.gui["inv" .. index]
    if panel and panel:IsVisible() then panel:Close() end
  end)
end

function ITEM:CanTransfer(oldInventory, newInventory)
  local index = self:GetData("id")
  if newInventory then
    if newInventory.vars and newInventory.vars.isBag then return false end
    local index2 = newInventory:GetID()
    if index == index2 then return false end
    for _, v in pairs(self:GetInventory():GetItems()) do
      if v:GetData("id") == index2 then return false end
    end
  end
  return not newInventory or newInventory:GetID() ~= oldInventory:GetID() or newInventory.vars.isBag
end

function ITEM:OnTransferred(curInv, inventory)
  local bagInventory = self:GetInventory()
  if isfunction(curInv.GetOwner) then
    local owner = curInv:GetOwner()
    if IsValid(owner) then bagInventory:RemoveReceiver(owner) end
  end

  if isfunction(inventory.GetOwner) then
    local owner = inventory:GetOwner()
    if IsValid(owner) then
      bagInventory:AddReceiver(owner)
      bagInventory:SetOwner(owner)
    end
  else
    bagInventory:SetOwner(nil)
  end
end

function ITEM:OnRegistered()
  ix.inventory.Register(self.uniqueID, self.invWidth, self.invHeight, true)
end
