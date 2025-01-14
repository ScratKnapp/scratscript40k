local PLUGIN = PLUGIN
PLUGIN.name = "Professions"
PLUGIN.author = "Verne"
PLUGIN.desc = "Professions that can be added to a character.."
ix.command.Add("CharSetProfession", {
  description = "Assign a profession to a character. Wipes their old one.",
  privilege = "Manage Character Attributes",
  adminOnly = true,
  arguments = {ix.type.character, ix.type.string,},
  OnRun = function(self, client, target, professionName)
    for k, v in pairs(ix.professions.list) do
      if ix.util.StringMatches(L(v.name, client), professionName) or ix.util.StringMatches(k, professionName) then
        target:SetData("Profession", k)
        return "Assigned profession " .. k .. " to " .. target:GetName()
      end
    end
    return "Profession not found!"
  end
})

ix.command.Add("CharClearProfession", {
  description = "Clear Profession from a character, leaving it blank.",
  privilege = "Manage Character Attributes",
  adminOnly = true,
  arguments = {ix.type.character,},
  OnRun = function(self, client, target)
    target:SetData("Profession", nil)
    return "Cleared Profession from " .. target:GetName() .. "."
  end
})

ix.command.Add("ProfessionTest", {
  description = "Clear Profession from a character, leaving it blank.",
  privilege = "Manage Character Attributes",
  adminOnly = true,
  arguments = {ix.type.character,},
  OnRun = function(self, client, target)
    local boost = target:GetProfessionSkill()
    client:Notify(boost)
  end
})

ix.char.RegisterVar("professions", {
  field = "professions",
  fieldType = ix.type.text,
  default = {},
  index = 5,
  category = "attributes",
  isLocal = true,
  OnDisplay = function(self, container, payload)
    local maximum = hook.Run("GetDefaultProfessionPoints", LocalPlayer(), payload) or ix.config.Get("maxProfessions", 30)
    if maximum < 1 then return end
    local professions = container:Add("DScrollPanel")
    professions:Dock(TOP)
    local y
    local total = 0
    payload.professions = {}
    local totalBar = professions:Add("ixAttributeBar")
    totalBar:SetMax(2)
    totalBar:SetValue(2)
    totalBar:Dock(TOP)
    totalBar:DockMargin(2, 2, 2, 2)
    totalBar:SetText("Profession points left:" .. " (" .. totalBar:GetValue() .. ")")
    totalBar:SetReadOnly(true)
    totalBar:SetColor(Color(20, 120, 20, 255))
    y = totalBar:GetTall() + 4
    for k, v in SortedPairsByMemberValue(ix.professions.list, "name") do
      payload.professions[k] = 0
      local bar = professions:Add("ixAttributeBar")
      bar:SetMax(maximum)
      bar:Dock(TOP)
      bar:DockMargin(2, 2, 2, 2)
      bar:SetText(L(v.name))
      bar.OnChanged = function(this, difference)
        if total + difference > maximum then return false end
        total = total + difference
        payload.professions[k] = payload.professions[k] + difference
        totalBar:SetValue(totalBar.value - difference)
      end

      if v.noStartBonus then bar:SetReadOnly() end
    end

    professions:SetTall(y * 8 * ScrH() / 1080)
    return professions
  end,
  OnValidate = function(self, value, data, client)
    if value ~= nil then
      if istable(value) then
        local count = 0
        for _, v in pairs(value) do
          count = count + v
        end

        if count > (hook.Run("GetDefaultProfessionPoints", client, count) or ix.config.Get("maxProfessions", 30)) then return false, "unknownError" end
      else
        return false, "unknownError"
      end
    end
  end,
  ShouldDisplay = function(self, container, payload) return true end
})
