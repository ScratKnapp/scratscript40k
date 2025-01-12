local PLUGIN = PLUGIN
PLUGIN.name = "Containers"
PLUGIN.author = "Chessnut"
PLUGIN.description = "Provides the ability to store items."
ix.container = ix.container or {}
ix.container.stored = ix.container.stored or {}
ix.config.Add("containerSave", true, "Whether or not containers will save after a server restart.", nil, {
  category = "Containers"
})

ix.config.Add("containerOpenTime", 0.7, "How long it takes to open a container.", nil, {
  data = {
    min = 0,
    max = 50
  },
  category = "Containers"
})

ix.command.Add("ContainerCreate", {
  description = "Creates a custom container.",
  adminOnly = true,
  arguments = {ix.type.string, ix.type.string, ix.type.number, ix.type.number, bit.bor(ix.type.bool, ix.type.optional)},
  OnRun = function(self, client, model, name, w, h, useKey)
    ix.inventory.Register("container:" .. model, w, h)
    if useKey == nil then useKey = false end
    timer.Simple(0.5, function() hook.Run("SpawnContainer", client, model, name, w, h, useKey) end)
  end
})

ix.command.Add("SaveContainers", {
  description = "Save all containers on the map.",
  adminOnly = true,
  OnRun = function(self, client) if SERVER then PLUGIN:SaveData() end end
})

if SERVER then
  util.AddNetworkString("ixContainerPassword")
  function PLUGIN:SpawnContainer(client, model, name, width, height, usekey)
    local trace = client:GetEyeTraceNoCursor()
    local hitpos = trace.HitPos
    local container = ents.Create("ix_container")
    container:SetPos(hitpos)
    container:SetAngles(client:GetAngles())
    container:SetModel(model)
    container:SetSolid(SOLID_VPHYSICS)
    container:PhysicsInit(SOLID_VPHYSICS)
    container:SetDisplayName(name)
    container:Spawn()
    container:SetNetVar("width", width)
    container:SetNetVar("height", height)
    container:SetNetVar("useKey", usekey)
    ix.inventory.New(0, "container:" .. model, function(inventory)
      inventory.vars.isBag = true
      inventory.vars.isContainer = true
      if IsValid(container) then
        container:SetInventory(inventory)
        self:SaveContainer()
      end
    end)
  end

  function PLUGIN:CanSaveContainer(entity, inventory)
    return ix.config.Get("containerSave", true)
  end

  function PLUGIN:SaveContainer()
    local data = {}
    for _, v in ipairs(ents.FindByClass("ix_container")) do
      if hook.Run("CanSaveContainer", v, v:GetInventory()) ~= false then
        local inventory = v:GetInventory()
        if inventory then data[#data + 1] = {v:GetPos(), v:GetAngles(), inventory:GetID(), v:GetModel(), v.password, v:GetDisplayName(), v:GetMoney(), v:GetNetVar("width", nil), v:GetNetVar("height", nil), v:GetMaterial(), v:GetSkin(), v:GetColor(), v:GetRenderMode(), v:GetNetVar("desc", ""), v:GetNetVar("useKey", false), v.spawnCategory, v:GetNetVar("openSound", "Pathos.OpenDrawer"), v:GetNetVar("closeSound", "Pathos.CloseDrawer"), v:GetNetVar("lockedSound", "games/ue4/horrorengine/handlerelease04.wav"), v:GetNetVar("multipleUsers", false)} end
      else
        local index = v:GetID()
        local query = mysql:Delete("ix_items")
        query:Where("inventory_id", index)
        query:Execute()
        query = mysql:Delete("ix_inventories")
        query:Where("inventory_id", index)
        query:Execute()
      end
    end

    self:SetData(data)
  end

  function PLUGIN:SaveData()
    if not ix.shuttingDown then self:SaveContainer() end
  end

  function PLUGIN:ContainerRemoved(entity, inventory)
    self:SaveContainer()
  end

  function PLUGIN:LoadData()
    local data = self:GetData()
    if data then
      for _, v in ipairs(data) do
        local inventoryID = tonumber(v[3])
        local entity = ents.Create("ix_container")
        entity:SetPos(v[1])
        entity:SetAngles(v[2])
        entity:SetModel(v[4])
        entity:SetSolid(SOLID_VPHYSICS)
        entity:PhysicsInit(SOLID_VPHYSICS)
        entity:Spawn()
        if v[5] then
          entity.password = v[5]
          entity:SetLocked(true)
          entity.Sessions = {}
        end

        if v[6] then entity:SetDisplayName(v[6]) end
        if v[7] then entity:SetMoney(v[7]) end
        if v[8] then entity:SetNetVar("width", v[8]) end
        if v[9] then entity:SetNetVar("height", v[9]) end
        if v[10] then entity:SetMaterial(v[10]) end
        if v[11] then entity:SetSkin(v[11]) end
        if v[12] then entity:SetColor(v[12]) end
        if v[13] then entity:SetRenderMode(v[13]) end
        if v[14] then entity:SetNetVar("desc", v[14]) end
        if v[15] then entity:SetNetVar("useKey", v[15]) end
        if v[16] then entity.spawnCategory = v[16] end
        if v[17] then entity:SetNetVar("openSound", v[17]) end
        if v[18] then entity:SetNetVar("closeSound", v[18]) end
        if v[19] then entity:SetNetVar("lockedSound", v[19]) end
        if v[20] then entity:SetNetVar("multipleUsers", v[20]) end
        ix.inventory.Restore(inventoryID, tonumber(v[8]), tonumber(v[9]), function(inventory)
          inventory.vars.isBag = true
          inventory.vars.isContainer = true
          if IsValid(entity) then entity:SetInventory(inventory) end
        end)

        local physObject = entity:GetPhysicsObject()
        if IsValid(physObject) then physObject:EnableMotion() end
      end
    end
  end

  net.Receive("ixContainerPassword", function(length, client)
    if (client.ixNextContainerPassword or 0) > RealTime() then return end
    local entity = net.ReadEntity()
    local password = net.ReadString()
    local dist = entity:GetPos():DistToSqr(client:GetPos())
    if dist < 16384 and password then
      if entity.password and entity.password == password then
        entity:OpenInventory(client)
      else
        client:NotifyLocalized("wrongPassword")
      end
    end

    client.ixNextContainerPassword = RealTime() + 0.5
  end)

  ix.log.AddType("containerPassword", function(client, ...)
    local arg = {...}
    return string.format("%s has %s the password for '%s'.", client:Name(), arg[3] and "set" or "removed", arg[1], arg[2])
  end)

  ix.log.AddType("containerName", function(client, ...)
    local arg = {...}
    if arg[3] then
      return string.format("%s has set container %d name to '%s'.", client:Name(), arg[2], arg[1])
    else
      return string.format("%s has removed container %d name.", client:Name(), arg[2])
    end
  end)

  ix.log.AddType("openContainer", function(client, ...)
    local arg = {...}
    return string.format("%s opened the '%s' #%d container.", client:Name(), arg[1], arg[2])
  end, FLAG_NORMAL)

  ix.log.AddType("closeContainer", function(client, ...)
    local arg = {...}
    return string.format("%s closed the '%s' #%d container.", client:Name(), arg[1], arg[2])
  end, FLAG_NORMAL)
else
  net.Receive("ixContainerPassword", function(length)
    local entity = net.ReadEntity()
    Derma_StringRequest(L("containerPasswordWrite"), L("containerPasswordWrite"), "", function(val)
      net.Start("ixContainerPassword")
      net.WriteEntity(entity)
      net.WriteString(val)
      net.SendToServer()
    end)
  end)
end

properties.Add("container_setpassword", {
  MenuLabel = "Set Password",
  Order = 300,
  MenuIcon = "icon16/lock_edit.png",
  Filter = function(self, entity, client)
    if not client:IsAdmin() then return false end
    if entity:GetClass() ~= "ix_container" then return false end
    return true
  end,
  Action = function(self, entity)
    Derma_StringRequest(L("containerPasswordWrite"), "", "", function(text)
      self:MsgStart()
      net.WriteEntity(entity)
      net.WriteString(text)
      self:MsgEnd()
    end)
  end,
  Receive = function(self, length, client)
    local entity = net.ReadEntity()
    if not IsValid(entity) then return end
    if not self:Filter(entity, client) then return end
    local password = net.ReadString()
    entity.Sessions = {}
    if password:len() ~= 0 then
      entity:SetLocked(true)
      entity.password = password
      client:NotifyLocalized("containerPassword", password)
    else
      entity:SetLocked(false)
      entity.password = nil
      client:NotifyLocalized("containerPasswordRemove")
    end

    local name = entity:GetDisplayName()
    local inventory = entity:GetInventory()
    ix.log.Add(client, "containerPassword", name, inventory:GetID(), password:len() ~= 0)
  end
})

properties.Add("container_usekey", {
  MenuLabel = "Use Key",
  Order = 400,
  MenuIcon = "icon16/lock_edit.png",
  Filter = function(self, entity, client)
    if not client:IsAdmin() then return false end
    if entity:GetClass() ~= "ix_container" then return false end
    if entity:GetNetVar("useKey", false) then return false end
    return true
  end,
  Action = function(self, entity)
    self:MsgStart()
    net.WriteEntity(entity)
    self:MsgEnd()
  end,
  Receive = function(self, length, client)
    local entity = net.ReadEntity()
    if not IsValid(entity) then return end
    if not self:Filter(entity, client) then return end
    entity:SetNetVar("useKey", true)
  end
})

properties.Add("container_usecode", {
  MenuLabel = "Use Code",
  Order = 400,
  MenuIcon = "icon16/lock_edit.png",
  Filter = function(self, entity, client)
    if not client:IsAdmin() then return false end
    if entity:GetClass() ~= "ix_container" then return false end
    if not entity:GetNetVar("useKey", false) then return false end
    return true
  end,
  Action = function(self, entity)
    self:MsgStart()
    net.WriteEntity(entity)
    self:MsgEnd()
  end,
  Receive = function(self, length, client)
    local entity = net.ReadEntity()
    if not IsValid(entity) then return end
    if not self:Filter(entity, client) then return end
    entity:SetNetVar("useKey", false)
  end
})

properties.Add("container_allowmulti", {
  MenuLabel = "Allow Multiple Users",
  Order = 500,
  MenuIcon = "icon16/table_multiple.png",
  Filter = function(self, entity, client)
    if not client:IsAdmin() then return false end
    if entity:GetClass() ~= "ix_container" then return false end
    if entity:GetNetVar("multipleUsers", false) then return false end
    return true
  end,
  Action = function(self, entity)
    self:MsgStart()
    net.WriteEntity(entity)
    self:MsgEnd()
  end,
  Receive = function(self, length, client)
    local entity = net.ReadEntity()
    if not IsValid(entity) then return end
    if not self:Filter(entity, client) then return end
    entity:SetNetVar("multipleUsers", true)
  end
})

properties.Add("container_disallowmulti", {
  MenuLabel = "Disallow Multiple Users",
  Order = 500,
  MenuIcon = "icon16/table.png",
  Filter = function(self, entity, client)
    if not client:IsAdmin() then return false end
    if entity:GetClass() ~= "ix_container" then return false end
    if not entity:GetNetVar("multipleUsers", false) then return false end
    return true
  end,
  Action = function(self, entity)
    self:MsgStart()
    net.WriteEntity(entity)
    self:MsgEnd()
  end,
  Receive = function(self, length, client)
    local entity = net.ReadEntity()
    if not IsValid(entity) then return end
    if not self:Filter(entity, client) then return end
    entity:SetNetVar("multipleUsers", false)
  end
})

properties.Add("container_setname", {
  MenuLabel = "Set Name",
  Order = 200,
  MenuIcon = "icon16/tag_blue_edit.png",
  Filter = function(self, entity, client)
    if not client:IsAdmin() then return false end
    if entity:GetClass() ~= "ix_container" then return false end
    return true
  end,
  Action = function(self, entity)
    Derma_StringRequest("Set Name", "", entity:GetDisplayName() or "", function(text)
      self:MsgStart()
      net.WriteEntity(entity)
      net.WriteString(text)
      self:MsgEnd()
    end)
  end,
  Receive = function(self, length, client)
    local entity = net.ReadEntity()
    if not IsValid(entity) then return end
    if not self:Filter(entity, client) then return end
    local name = net.ReadString()
    if name:len() ~= 0 then
      entity:SetDisplayName(name)
      client:NotifyLocalized("containerName", name)
    else
      local definition = ix.container.stored[entity:GetModel():lower()]
      entity:SetDisplayName(definition.name)
      client:NotifyLocalized("containerNameRemove")
    end

    local inventory = entity:GetInventory()
    ix.log.Add(client, "containerName", name, inventory:GetID(), name:len() ~= 0)
  end
})

properties.Add("container_setdesc", {
  MenuLabel = "Set Description",
  Order = 200,
  MenuIcon = "icon16/tag_blue_edit.png",
  Filter = function(self, entity, client)
    if not client:IsAdmin() then return false end
    if entity:GetClass() ~= "ix_container" then return false end
    return true
  end,
  Action = function(self, entity)
    Derma_StringRequest("Set Description", "", entity:GetNetVar("desc", ""), function(text)
      self:MsgStart()
      net.WriteEntity(entity)
      net.WriteString(text)
      self:MsgEnd()
    end)
  end,
  Receive = function(self, length, client)
    local entity = net.ReadEntity()
    if not IsValid(entity) then return end
    if not self:Filter(entity, client) then return end
    local desc = net.ReadString()
    if desc:len() ~= 0 then
      entity:SetNetVar("desc", desc)
    else
      entity:SetNetVar("desc", "")
    end
  end
})

properties.Add("container_setopensound", {
  MenuLabel = "Set Opening Sound",
  Order = 600,
  MenuIcon = "icon16/tag_blue_edit.png",
  Filter = function(self, entity, client)
    if entity:GetClass() ~= "ix_container" then return false end
    if not client:IsAdmin() then return false end
    return true
  end,
  Action = function(self, entity)
    Derma_StringRequest("Set Opening Sound", "", entity:GetNetVar("openSound", "Pathos.OpenDrawer"), function(text)
      self:MsgStart()
      net.WriteEntity(entity)
      net.WriteString(text)
      self:MsgEnd()
    end)
  end,
  Receive = function(self, length, client)
    local entity = net.ReadEntity()
    if not IsValid(entity) then return end
    if not self:Filter(entity, client) then return end
    local str = net.ReadString()
    if str:len() ~= 0 then
      entity:SetNetVar("openSound", str)
    else
      entity:SetNetVar("openSound", "Pathos.OpenDrawer")
    end
  end
})

properties.Add("container_setclosesound", {
  MenuLabel = "Set Closing Sound",
  Order = 600,
  MenuIcon = "icon16/tag_blue_edit.png",
  Filter = function(self, entity, client)
    if entity:GetClass() ~= "ix_container" then return false end
    if not client:IsAdmin() then return false end
    return true
  end,
  Action = function(self, entity)
    Derma_StringRequest("Set Closing Sound", "", entity:GetNetVar("closeSound", "Pathos.CloseDrawer"), function(text)
      self:MsgStart()
      net.WriteEntity(entity)
      net.WriteString(text)
      self:MsgEnd()
    end)
  end,
  Receive = function(self, length, client)
    local entity = net.ReadEntity()
    if not IsValid(entity) then return end
    if not self:Filter(entity, client) then return end
    local str = net.ReadString()
    if str:len() ~= 0 then
      entity:SetNetVar("closeSound", str)
    else
      entity:SetNetVar("closeSound", "Pathos.CloseDrawer")
    end
  end
})

properties.Add("container_setlockedsound", {
  MenuLabel = "Set Locked Sound",
  Order = 600,
  MenuIcon = "icon16/tag_blue_edit.png",
  Filter = function(self, entity, client)
    if entity:GetClass() ~= "ix_container" then return false end
    if not client:IsAdmin() then return false end
    return true
  end,
  Action = function(self, entity)
    Derma_StringRequest("Set Locked Sound", "", entity:GetNetVar("lockedSound", "games/ue4/horrorengine/handlerelease04.wav"), function(text)
      self:MsgStart()
      net.WriteEntity(entity)
      net.WriteString(text)
      self:MsgEnd()
    end)
  end,
  Receive = function(self, length, client)
    local entity = net.ReadEntity()
    if not IsValid(entity) then return end
    if not self:Filter(entity, client) then return end
    local str = net.ReadString()
    if str:len() ~= 0 then
      entity:SetNetVar("lockedSound", str)
    else
      entity:SetNetVar("lockedSound", "games/ue4/horrorengine/handlerelease04.wav")
    end
  end
})
-- ix.log.Add(client, "containerDesc", name, inventory:GetID(), name:len() ~= 0)
