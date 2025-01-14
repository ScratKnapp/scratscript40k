if not ix.char then include("sh_character.lua") end
ix.professions = ix.professions or {}
ix.professions.list = ix.professions.list or {}
function ix.professions.LoadFromDir(directory)
  for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
    local niceName = v:sub(4, -5)
    PROFESSION = ix.professions.list[niceName] or {}
    if PLUGIN then PROFESSION.plugin = PLUGIN.uniqueID end
    ix.util.Include(directory .. "/" .. v)
    PROFESSION.name = PROFESSION.name or "Unknown"
    PROFESSION.description = PROFESSION.description or "No description availalble."
    ix.professions.list[niceName] = PROFESSION
    PROFESSION = nil
  end
end

do
  local charMeta = ix.meta.character
  function charMeta:GetProfessionSkill()
    if not self:GetData("Profession") then return "None" end
    local skill = ix.professions.list[self:GetData("Profession")].skill
    if not skill then skill = "None" end
    return skill
  end

  function charMeta:GetProfessionName()
    if not self:GetData("Profession") then return "None" end
    local name = ix.professions.list[self:GetData("Profession", "None")].name
    if not name then name = "None" end
    return name
  end

  hook.Add("DoPluginIncludes", "ixProfessionsLib", function(path) ix.professions.LoadFromDir(path .. "/professions") end)
end
