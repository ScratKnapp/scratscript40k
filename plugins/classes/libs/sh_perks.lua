if not ix.char then include("sh_character.lua") end
ix.charclasses = ix.charclasses or {}
ix.charclasses.list = ix.charclasses.list or {}
function ix.charclasses.LoadFromDir(directory)
  for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
    local niceName = v:sub(4, -5)
    CHARCLASS = ix.charclasses.list[niceName] or {}
    if PLUGIN then CHARCLASS.plugin = PLUGIN.uniqueID end
    ix.util.Include(directory .. "/" .. v)
    CHARCLASS.name = CHARCLASS.name or "Unknown"
    CHARCLASS.description = CHARCLASS.description or "No description availalble."
    CHARCLASS.race = CHARCLASS.race or nil
    ix.charclasses.list[niceName] = CHARCLASS
    CHARCLASS = nil
  end
end

do
  local charMeta = ix.meta.character
  hook.Add("DoPluginIncludes", "ixClassesLib", function(path) ix.charclasses.LoadFromDir(path .. "/charclasses") end)
end
