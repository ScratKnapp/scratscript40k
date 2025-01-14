local PLUGIN = PLUGIN
PLUGIN.name = "Customization"
PLUGIN.author = ""
PLUGIN.desc = "Item Customization."
if SERVER then
  function PLUGIN:updateSWEP(client, item)
    local customData = item:GetData("custom", {})
    if item.class then
      local swep = weapons.Get(item.class)
      local itemInfo = {}
      itemInfo.class = item.class
      itemInfo.wepDmg = customData.wepDmg or swep and swep.Damage
      itemInfo.wepSpd = customData.wepSpd or swep and swep.FireDelay
      itemInfo.wepAcc = customData.wepAcc
      itemInfo.wepRec = customData.wepRec
      itemInfo.wepMag = customData.wepMag or swep and swep.Primary.ClipSize
      itemInfo.name = customData.name
      netstream.Start(client, "nut_swepUpdate", itemInfo)
    end
  end

  function PLUGIN:startCustom(client, item, extra)
    if not client:IsAdmin() then return end
    local customData = item:GetData("custom", {})
    local itemInfo = {}
    itemInfo.id = item.id
    itemInfo.name = item:GetName() or item.name
    itemInfo.description = customData.desc or item.description
    itemInfo.longdesc = customData.longdesc or item.longdesc or ""
    itemInfo.model = customData.model or item.model
    itemInfo.material = customData.material or item.material
    itemInfo.quality = customData.quality
    itemInfo.img = customData.img
    if item.isWeapon then
      itemInfo.weapon = true
      itemInfo.dura = item:GetData("condition", 100)
    end

    if item.isArmor then itemInfo.armor = true end
    if item.quantity or item.maxStack or item.ammoAmount then
      itemInfo.quantity = true
      itemInfo.quantity = item:GetData("quantity", item.maxStack or item.quantity or item.ammoAmount) or customData.quantity or 100
    end

    netstream.Start(client, "nut_custom", itemInfo)
  end

  function PLUGIN:startCustomA(client, item)
    if not client:GetCharacter():HasFlags("N") then return end
    local attribData = item:GetData("attrib", item.attribBoosts) or {}
    local itemInfo = {}
    itemInfo.id = item.id
    itemInfo.attrib = attribData
    netstream.Start(client, "nut_customA", itemInfo)
  end

  netstream.Hook("nut_customF", function(client, data)
    if not client:GetCharacter():HasFlags("N") then return end
    local id = data[1]
    local item = ix.item.instances[id]
    local customData = data[2]
    if customData.dura then item:SetData("condition", customData.dura) end
    if customData.quantity then item:SetData("quantity", customData.quantity) end
    if item then item:SetData("custom", customData) end
  end)

  netstream.Hook("nut_attribF", function(client, data)
    if not client:GetCharacter():HasFlags("N") then return end
    local id = data[1]
    local item = ix.item.instances[id]
    local attribData = data[2]
    if item then item:SetData("attrib", attribData) end
  end)
else
  netstream.Hook("nut_custom", function(data)
    local item = data
    local name = item.name
    local desc = item.description
    local longdesc = item.longdesc
    local model = item.model
    local material = item.material or ""
    local quality = item.quality or "None"
    local img = item.img
    local impact = item.impact
    local shock = item.shock
    local burn = item.burn
    local toxic = item.toxic
    local dura = item.dura
    local quantity = item.maxStack or item.ammoAmount or item.quantity
    local dmg = item.wepDmg
    local spd = item.wepSpd
    local acc = item.wepAcc
    local rec = item.wepRec
    local mag = item.wepMag
    local frame = vgui.Create("DFrame")
    frame:SetSize(450, 600)
    frame:Center()
    frame:SetTitle(name or "")
    frame:MakePopup()
    frame:ShowCloseButton(true)
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    local nameL = vgui.Create("DLabel", scroll)
    nameL:SetText("Name:")
    nameL:Dock(TOP)
    local nameC = vgui.Create("DTextEntry", scroll)
    nameC:SetText(name or "")
    nameC:Dock(TOP)
    local descL = vgui.Create("DLabel", scroll)
    descL:SetText("Description:")
    descL:Dock(TOP)
    local descC = vgui.Create("DTextEntry", scroll)
    descC:SetText(desc or "")
    descC:Dock(TOP)
    local longdescL = vgui.Create("DLabel", scroll)
    longdescL:SetText("Long Description:")
    longdescL:Dock(TOP)
    local longdescC = vgui.Create("DTextEntry", scroll)
    longdescC:SetText(longdesc or "")
    longdescC:Dock(TOP)
    local modelL = vgui.Create("DLabel", scroll)
    modelL:SetText("Model:")
    modelL:Dock(TOP)
    local modelC = vgui.Create("DTextEntry", scroll)
    modelC:SetText(model)
    modelC:Dock(TOP)
    local pictureL = vgui.Create("DLabel", scroll)
    pictureL:SetText("Image:")
    pictureL:Dock(TOP)
    local pictureC = vgui.Create("DTextEntry", scroll)
    pictureC:SetToolTip("Use an image URL.")
    pictureC:SetText(img or "")
    pictureC:Dock(TOP)
    local wepC
    local duraC
    local dmgC
    local rpmC
    local accC
    local recC
    local magC
    if item.weapon then
      local duraL = vgui.Create("DLabel", scroll)
      duraL:SetText(" Condition:")
      duraL:Dock(TOP)
      duraC = vgui.Create("DTextEntry", scroll)
      duraC:SetText(dura or 100)
      duraC:Dock(TOP)
      wepC = vgui.Create("DCheckBoxLabel", scroll)
      wepC:SetText("SWEP Modifiers")
      wepC:SetValue(0)
      wepC:SetToolTip("Toggle this if you want any of the stuff below to apply.")
      wepC:Dock(TOP)
      local dmgL = vgui.Create("DLabel", scroll)
      dmgL:SetText(" Damage:")
      dmgL:Dock(TOP)
      dmgC = vgui.Create("DTextEntry", scroll)
      dmgC:SetText(dmg or 1)
      dmgC:Dock(TOP)
      local rpmL = vgui.Create("DLabel", scroll)
      rpmL:SetText(" Fire Delay Multiplier:")
      rpmL:Dock(TOP)
      rpmC = vgui.Create("DTextEntry", scroll)
      rpmC:SetText(spd or 1)
      rpmC:Dock(TOP)
      local accL = vgui.Create("DLabel", scroll)
      accL:SetText(" Accuracy Multiplier:")
      accL:Dock(TOP)
      accC = vgui.Create("DTextEntry", scroll)
      accC:SetToolTip("Higher is worse.")
      accC:SetText(acc or 1)
      accC:Dock(TOP)
      local recL = vgui.Create("DLabel", scroll)
      recL:SetText(" Recoil Multiplier:")
      recL:Dock(TOP)
      recC = vgui.Create("DTextEntry", scroll)
      recC:SetText(rec or 1)
      recC:Dock(TOP)
      local magL = vgui.Create("DLabel", scroll)
      magL:SetText(" Magazine Size:")
      magL:Dock(TOP)
      magC = vgui.Create("DTextEntry", scroll)
      magC:SetText(mag or 1)
      magC:Dock(TOP)
    end

    local finishB = vgui.Create("DButton", scroll)
    finishB:SetSize(60, 20)
    finishB:SetText("Complete")
    finishB:Dock(TOP)
    finishB.DoClick = function()
      local customData = {}
      customData[1] = item.id
      customData[2] = {}
      customData[2].longdesc = longdescC:GetValue()
      customData[2].name = nameC:GetValue()
      customData[2].desc = descC:GetValue()
      customData[2].model = modelC:GetValue()
      --[[if(materialC:GetValue() != "") then
				customData[2].material = materialC:GetValue()
			end]]
      if pictureC:GetValue() ~= "" then customData[2].img = pictureC:GetValue() end
      if item.weapon and wepC:GetChecked() then
        customData[2].wepDmg = math.Clamp(tonumber(dmgC:GetValue()), 0, 100000)
        customData[2].wepSpd = math.Clamp(tonumber(rpmC:GetValue()), 1, 1000000000)
        customData[2].wepAcc = math.Clamp(tonumber(accC:GetValue()), 0.0001, 100)
        customData[2].wepRec = math.Clamp(tonumber(recC:GetValue()), 0, 1000)
        customData[2].wepMag = math.Clamp(tonumber(magC:GetValue()), 0, 10000)
      end

      if item.quantity or item.maxStack or item.ammoAmount then customData[2].quantity = tonumber(quantityC:GetValue()) end
      netstream.Start("nut_customF", customData)
      frame:Remove()
    end

    local cancelB = vgui.Create("DButton", scroll)
    cancelB:SetSize(60, 20)
    cancelB:SetText("Cancel")
    cancelB:Dock(TOP)
    cancelB.DoClick = function() frame:Remove() end
  end)

  netstream.Hook("nut_customA", function(data)
    local item = data
    local attribData = item.attrib
    local frame = vgui.Create("DFrame")
    frame:SetSize(450, 600)
    frame:Center()
    frame:SetTitle("Attributes")
    frame:MakePopup()
    frame:ShowCloseButton(true)
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    local attribs = {}
    for k, v in pairs(ix.attributes.list) do
      local attribL = vgui.Create("DLabel", scroll)
      attribL:SetText(v.name)
      attribL:Dock(TOP)
      local attribC = vgui.Create("DNumberWang", scroll)
      attribC.attrib = k
      attribC:SetDecimals(2)
      attribC:Dock(TOP)
      attribC:SetMax(200)
      attribC:SetMin(-200)
      attribC:SetValue(attribData[k] or 0)
      attribs[k] = attribC
    end

    local finishB = vgui.Create("DButton", scroll)
    finishB:SetSize(60, 20)
    finishB:SetText("Complete")
    finishB:Dock(TOP)
    finishB.DoClick = function()
      local customData = {}
      customData[1] = item.id
      customData[2] = {}
      for k, v in pairs(attribs) do
        local value = v:GetValue()
        if value ~= 0 then customData[2][k] = value end
      end

      netstream.Start("nut_attribF", customData)
      frame:Remove()
    end

    local cancelB = vgui.Create("DButton", scroll)
    cancelB:SetSize(60, 20)
    cancelB:SetText("Cancel")
    cancelB:Dock(TOP)
    cancelB.DoClick = function() frame:Remove() end
  end)

  netstream.Hook("nut_swepUpdate", function(data)
    local item = data
    local weapon = LocalPlayer():GetWeapon(item.class)
    if weapon and IsValid(weapon) then
      if item.name then weapon.PrintName = item.name end
      if item.wepDmg then weapon.Damage = tonumber(item.wepDmg) end
      if item.wepSpd then
        weapon.FireDelay = weapon.FireDelay * tonumber(item.wepSpd)
        print(weapon.FireDelay)
      end

      if item.wepRec then weapon.Recoil = weapon.Recoil * item.wepRec end
      if item.wepAcc then
        weapon.MaxSpreadInc = weapon.MaxSpreadInc * item.wepAcc
        weapon.AimSpread = weapon.AimSpread * item.wepAcc
      end

      if item.wepMag then weapon.Primary.ClipSize = tonumber(item.wepMag) end
    end
  end)
end
