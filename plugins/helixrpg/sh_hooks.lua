function PLUGIN:GetMaximumAttributePoints()
  return ix.config.Get("maxAttributes", 5)
end

function PLUGIN:GetMaximumSkillPoints()
  return ix.config.Get("maxSkills", 10)
end

function PLUGIN:GetDefaultTraitPoints()
  return ix.config.Get("startingTraits", 3)
end

function PLUGIN:GetDefaultAttributePoints(client)
  return ix.config.Get("startingAttributePoints", 10)
end

function PLUGIN:GetDefaultSkillPoints(client)
  return ix.config.Get("startingSkillPoints", 20)
end
