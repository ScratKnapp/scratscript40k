ix.skills = ix.skills or {}
ix.skills.list = ix.skills.list or {}
function ix.skills.LoadFromDir(directory)
  for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
    local niceName = v:sub(4, -5)
    SKILL = ix.skills.list[niceName] or {}
    if PLUGIN then SKILL.plugin = PLUGIN.uniqueID end
    ix.util.Include(directory .. "/" .. v)
    SKILL.name = SKILL.name or "Unknown"
    SKILL.description = SKILL.description or "No description available."
    SKILL.attribute = SKILL.attribute or "None"
    ix.skills.list[niceName] = SKILL
    SKILL = nil
  end
end

function ix.skills.Setup(client)
  local character = client:GetCharacter()
  if character then
    for k, v in pairs(ix.skills.list) do
      if v.OnSetup then v:OnSetup(client, character:GetSkill(k, 0)) end
    end
  end
end

do
  local charMeta = ix.meta.character
  if SERVER then
    util.AddNetworkString("ixSkillUpdate")
    function charMeta:UpdateSkill(key, value)
      local skill = ix.skills.list[key]
      local client = self:GetPlayer()
      if skill then
        local skl = self:GetSkills()
        skl[key] = math.min((skl[key] or 0) + value, skill.maxValue or ix.config.Get("maxSkills", 30))
        if IsValid(client) then
          net.Start("ixSkillUpdate")
          net.WriteUInt(self:GetID(), 32)
          net.WriteString(key)
          net.WriteFloat(skl[key])
          net.Send(client)
          if skill.Setup then skill.Setup(skl[key]) end
        end

        self:SetSkills(skl)
      end

      hook.Run("CharacterSkillUpdated", client, self, key, value)
    end

    function charMeta:SetSkill(key, value)
      local skill = ix.skills.list[key]
      local client = self:GetPlayer()
      if skill then
        local skl = self:GetSkills()
        skl[key] = value
        if IsValid(client) then
          net.Start("ixSkillUpdate")
          net.WriteUInt(self:GetID(), 32)
          net.WriteString(key)
          net.WriteFloat(skl[key])
          net.Send(client)
          if skill.Setup then skill.Setup(skl[key]) end
        end

        self:SetSkills(skl)
      end

      hook.Run("CharacterSkillUpdated", client, self, key, value)
    end

    function charMeta:AddSkillBoost(boostID, sklID, boostAmount)
      local boosts = self:GetVar("boosts", {})
      boosts[sklID] = boosts[sklID] or {}
      boosts[sklID][boostID] = boostAmount
      hook.Run("CharacterSkillBoosted", self:GetPlayer(), self, sklID, boostID, boostAmount)
      return self:SetVar("boosts", boosts, nil, self:GetPlayer())
    end

    function charMeta:RemoveSkillBoost(boostID, sklID)
      local boosts = self:GetVar("boosts", {})
      boosts[sklID] = boosts[sklID] or {}
      boosts[sklID][boostID] = nil
      hook.Run("CharacterSkillBoosted", self:GetPlayer(), self, sklID, boostID, true)
      return self:SetVar("boosts", boosts, nil, self:GetPlayer())
    end
  else
    net.Receive("ixSkillUpdate", function()
      local id = net.ReadUInt(32)
      local character = ix.char.loaded[id]
      if character then
        local key = net.ReadString()
        local value = net.ReadFloat()
        character:GetSkills()[key] = value
      end
    end)
  end

  function charMeta:GetSkillBoost(sklID)
    local boosts = self:GetBoosts()
    return boosts[sklID]
  end

  function charMeta:GetSkillBoosts()
    return self:GetVar("boosts", {})
  end

  function charMeta:GetSkill(key, default)
    local skl = self:GetSkills()[key] or default
    local boosts = self:GetBoosts()[key]
    if boosts then
      for _, v in pairs(boosts) do
        skl = skl + v
      end
    end
    return skl
  end
end

do
  ix.char.RegisterVar("skills", {
    field = "skills",
    fieldType = ix.type.text,
    default = {},
    index = 5,
    category = "attributes",
    isLocal = true,
    OnDisplay = function(self, container, payload)
      local pointTotal = hook.Run("GetDefaultSkillPoints", LocalPlayer(), payload) or 10
      local maxPoints = hook.Run("GetMaximumSkillPoints", LocalPlayer(), payload) or 10
      if pointTotal < 1 then return end
      local skills = container:Add("DPanel")
      skills:Dock(TOP)
      local y
      local total = 0
      payload.skills = {}
      local totalBar = skills:Add("ixAttributeBar")
      totalBar:SetMax(pointTotal)
      totalBar:SetValue(pointTotal)
      totalBar:Dock(TOP)
      totalBar:DockMargin(2, 2, 2, 2)
      totalBar:SetText(L("attribPointsLeft"))
      totalBar:SetReadOnly(true)
      totalBar:SetColor(Color(20, 120, 20, 255))
      y = totalBar:GetTall() + 4
      for k, v in SortedPairsByMemberValue(ix.skills.list, "name") do
        payload.skills[k] = 0
        local bar = skills:Add("ixAttributeBar")
        bar:SetMax(ix.config.Get("startingSkillMax", 3))
        bar:Dock(TOP)
        bar:DockMargin(2, 2, 2, 2)
        bar:SetText(L(v.name))
        bar.OnChanged = function(this, difference)
          if total + difference > pointTotal then return false end
          total = total + difference
          payload.skills[k] = payload.skills[k] + difference
          totalBar:SetValue(totalBar.value - difference)
        end

        if v.noStartBonus then bar:SetReadOnly() end
        y = y + bar:GetTall() + 4
      end

      skills:SetTall(y)
      return skills
    end,
    OnValidate = function(self, value, data, client)
      if value ~= nil then
        if istable(value) then
          local count = 0
          for _, v in pairs(value) do
            count = count + v
          end

          if count > (hook.Run("GetDefaultSkillPoints", client, count) or 10) then return false, "unknownError" end
        else
          return false, "unknownError"
        end
      end
    end,
    ShouldDisplay = function(self, container, payload) return not table.IsEmpty(ix.skills.list) end
  })

  hook.Add("DoPluginIncludes", "HRPGLoadSkills", function(path, PLUGIN) ix.skills.LoadFromDir(path .. "/skills") end)
end
