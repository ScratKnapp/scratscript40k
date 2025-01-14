ITEM.name = "Weapon Base"
ITEM.model = "models/props_lab/clipboard.mdl"
ITEM.description = "A weapon base"
ITEM.longdesc = "None"
ITEM.category = "weapons"
ITEM.noBusiness = true
function ITEM:GetDescription()
  local str = ""
  str = str .. self.description
  str = str .. "\n\n" .. self.longdesc
  local AmmoType = self:GetData("AmmoType", "normal")
  if AmmoType == "normal" then
    str = str .. "\n\nAmmo Loaded: Normal"
  elseif AmmoType == "ap" then
    str = str .. "\n\nAmmo Loaded: Armor Piercing"
  end

  if self.ROF then str = str .. "\nROF: " .. self.ROF end
  if self.auto then str = str .. "\nAutofire: " .. self.auto end
  return str
end

ITEM.functions.SwapAmmo = {
  name = "Change Ammo Type",
  tip = "Detach",
  icon = "icon16/wrench.png",
  OnCanRun = function(item) return not IsValid(item.entity) end,
  OnRun = function(item, data)
    local client = item:GetOwner()
    item:SetData("AmmoType", data[1])
    return false
  end,
  isMulti = true,
  multiOptions = function(item, client)
    local targets = {}
    table.insert(targets, {
      name = "Normal",
      data = {"normal"},
    })

    table.insert(targets, {
      name = "Armor Piercing",
      data = {"ap"},
    })
    return targets
  end,
}
