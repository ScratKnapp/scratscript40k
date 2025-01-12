local PLUGIN = PLUGIN
ITEM.name = "FNUpgrade"
ITEM.description = "An attachment. It goes on a weapon."
ITEM.category = "Attachments"
ITEM.model = "models/Items/BoxSRounds.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.price = 1
ITEM.slot = 1
ITEM.quantity = 1
ITEM.isAttachment = true
local function attachment(item, data, combine)
  local client = item.player
  local char = client:GetChar()
  local inv = char:GetInv()
  local items = inv:GetItems()
  local target
  for k, invItem in pairs(items) do
    if data then
      if invItem:GetID() == data[1] then
        target = invItem
        break
      end
    end
  end

  if not target.isArmor then
    client:NotifyLocalized("noArmorTarget")
    return false
  else
    if target:GetData("equip", false) then
      client:NotifyLocalized("Unequip the armor before modifying it.")
      return false
    end

    local mods = target:GetData("mod", {})
    if mods[item.slot] then
      client:NotifyLocalized("Slot Filled")
      return false
    end

    curPrice = target:GetData("RealPrice")
    if not curPrice then curPrice = target.price end
    target:SetData("RealPrice", curPrice + item.price)
    mods[item.slot] = {item.uniqueID, item.name}
    target:SetData("mod", mods)
    target:RecalculateValues()
    client:EmitSound("cw/holster4.wav")
    return true
  end

  client:NotifyLocalized("noArmor")
  return false
end

local function RecalculateValues()
  local client = item.player
  local char = client:GetChar()
  local inv = char:GetInv()
  local items = inv:GetItems()
  local target
  for k, invItem in pairs(items) do
    if data then
      if invItem:GetID() == data[1] then
        target = invItem
        break
      end
    end
  end

  if not target.isArmor then
    client:NotifyLocalized("noArmorTarget")
    return false
  else
    if target:GetData("equip", false) then
      client:NotifyLocalized("Unequip the armor before modifying it.")
      return false
    end

    local mods = target:GetData("mod", {})
    if mods[item.slot] then
      client:NotifyLocalized("Slot Filled")
      return false
    end

    curPrice = target:GetData("RealPrice")
    if not curPrice then curPrice = target.price end
    target:SetData("RealPrice", curPrice + item.price)
    mods[item.slot] = {item.uniqueID, item.name}
    target:SetData("mod", mods)
    client:EmitSound("cw/holster4.wav")
    return true
  end

  char:setRPGValues()
  client:NotifyLocalized("noArmor")
  return false
end

ITEM.functions.Upgrade = {
  name = "Upgrade",
  tip = "Puts this upgrade on the specified piece of armor.",
  icon = "icon16/wrench.png",
  OnCanRun = function(item)
    if not item.player:GetCharacter():HasFlags("R") then return false end
    return not IsValid(item.entity)
  end,
  OnRun = function(item, data) return attachment(item, data, false) end,
  isMulti = true,
  multiOptions = function(item, client)
    local targets = {}
    local char = client:GetChar()
    if char then
      local inv = char:GetInv()
      if inv then
        local items = inv:GetItems()
        for k, v in pairs(items) do
          if not v.noUpgrade then
            if v.isBodyArmor and item.isArmorUpg then
              table.insert(targets, {
                name = L(v.name),
                data = {v:GetID()},
              })
            elseif v.isHelmet and item.isHelmetUpg then
              table.insert(targets, {
                name = L(v.name),
                data = {v:GetID()},
              })
            elseif v.isGasmask and item.isGasmaskUpg then
              table.insert(targets, {
                name = L(v.name),
                data = {v:GetID()},
              })
            elseif v.isMisc and item.isMiscUpg then
              table.insert(targets, {
                name = L(v.name),
                data = {v:GetID()},
              })
            else
              continue
            end
          end
        end
      end
    end
    return targets
  end,
}

function ITEM:GetDescription()
  local description = self.description
  if self.SP then description = description .. "\n+" .. self.SP .. " SP" end
  return description
end
