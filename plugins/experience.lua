local PLUGIN = PLUGIN
PLUGIN.name = "Experience"
PLUGIN.author = "Scrat Knapp"
PLUGIN.description = "Gain and spend Experience."

local charMeta = ix.meta.character

function charMeta:GetXP()
    return self:GetData("XP", 0)
end

function charMeta:AddXP(amount)
    self:SetData("XP", self:GetXP() + amount)
end 

function charMeta:RemoveXP(amount)
    self:SetData("XP", self:GetXP() - amount)
    if self:GetXP() < 0 then self:SetData("XP", 0) end 
end 

ix.command.Add("UpgradeAttribute", {
    arguments = {ix.type.string,},
	description = "Spend your XP and upgrade your attributes.",
	OnRun = function(self, client, att)
		local char = client:GetCharacter()
        local xp = char:GetXP()

        if not char:GetAttribute(att) then return "Invalid attribute!" end 
        if char:GetAttribute(att) >= 5 then return "You cannot upgrade an Attribute past 5." end

        local upgradecost = (char:GetAttribute(att) * 5)

        if xp < upgradecost then
            return "You need " .. upgradecost .. " XP to raise " .. att .. " from Level " .. char:GetAttribute(att) .. " to Level " .. char:GetAttribute(att) + 1 .. "."
        else 
            char:UpdateAttrib(att, 1)
            char:RemoveXP(upgradecost)
            return "Upgraded " .. att .. " to Level " .. char:GetAttribute(att) .. " for a cost of " .. upgradecost .. " XP."
        end 
	end
})


ix.command.Add("UpgradeSkill", {
    arguments = {ix.type.string,},
	description = "Spend your XP and upgrade your skills.",
	OnRun = function(self, client, skill)
		local char = client:GetCharacter()
        local xp = char:GetXP()

        if not char:GetSkill(skill) then return "Invalid skill!" end 
        if char:GetSkill(skill) >= 5 then return "You cannot upgrade a Skill past 5." end

        local upgradecost = (char:GetSkill(skill) * 5)

        if xp < upgradecost then
            return "You need " .. upgradecost .. " XP to raise " .. skill .. " from Level " .. char:GetSkill(skill) .. " to Level " .. char:GetSkill(skill) + 1 .. "."
        else 
            char:UpdateSkill(skill, 1)
            char:RemoveXP(upgradecost)
            return "Upgraded " .. skill .. " to Level " .. char:GetSkill(skill) .. " for a cost of " .. upgradecost .. " XP."
        end 
	end
})

ix.command.Add("UpgradeClass", {
    arguments = {ix.type.number},
	description = "Spend your XP and upgrade your class(es).",
	OnRun = function(self, client, slot)
		local char = client:GetCharacter()
        local xp = char:GetXP()

        if slot ~= 1 and slot ~= 2 and slot ~= 3 then
            return "Slot must be either 1, 2, or 3 for your Primary, Secondary, or Tertiary class."
        end 

       if slot == 1 then
            if not char:GetData("PrimaryClass") then return "You do not have a primary class!" end 


            local class =  char:GetData("PrimaryClass")
            local upgradecost = class.level * 7 

            if class.level >= 5 then return "You cannot upgrade a Class beyond level 5." end 

            if xp < upgradecost then 
                return "You need " .. upgradecost .. " XP to advance " .. class.name .. " to Level " .. class.level + 1 .. "." 
            else
                class.level = class.level + 1
                char:SetData("PrimaryClass", class)
                char:RemoveXP(upgradecost)
                return "You upgraded " .. class.name .. " to Level " .. class.level .. "."
            end 
        end 

        if slot == 2 then
            if not char:GetData("SecondaryClass") then return "You do not have a secondary class!" end 

            local class =  char:GetData("SecondaryClass")
            local upgradecost = class.level * 9 

            if class.level >= 5 then return "You cannot upgrade a Class beyond level 5." end 

            if xp < upgradecost then 
                return "You need " .. upgradecost .. " XP to advance " .. class.name .. " to Level " .. class.level + 1 .. "." 
            else
                class.level = class.level + 1
                char:SetData("SecondaryClass", class)
                char:RemoveXP(upgradecost)
                return "You upgraded " .. class.name .. " to Level " .. class.level .. "."
            end 
        end 

        if slot == 3 then
            if not char:GetData("TertiaryClass") then return "You do not have a tertiary class!" end 

            local class =  char:GetData("TertiaryClass")
            local upgradecost = class.level * 12

            if class.level >= 5 then return "You cannot upgrade a Class beyond level 5." end 

            if xp < upgradecost then 
                return "You need " .. upgradecost .. " XP to advance " .. class.name .. " to Level " .. class.level + 1 .. "." 
            else
                class.level = class.level + 1
                char:SetData("TertiaryClass", class)
                char:RemoveXP(upgradecost)
                return "You upgraded " .. class.name .. " to Level " .. class.level .. "."
            end 
        end 
	end
})


ix.command.Add("UpgradeVirtue", {
    arguments = {ix.type.string,},
	description = "Spend your XP and upgrade your Virtues.",
	OnRun = function(self, client, virtue)
		local char = client:GetCharacter()
        local xp = char:GetXP()

        virtue = string.lower(virtue)

        if virtue == "conscience" then

            local virtue = char:GetConscience()
            local upgradecost = virtue * 2

            if virtue >= 5 then return "You cannot upgrade Conscience above Level 5." end 

            if xp < upgradecost then 
                return "You need " .. upgradecost .. " XP to advance your Conscience to Level " .. virtue + 1 .. "." 
            else
                char:RemoveXP(upgradecost)
                char:SetData("Conscience", virtue + 1)
                return "You upgraded Conscience to Level " .. char:GetData("Conscience") .. "."
            end 


        elseif virtue == "selfcontrol" or virtue == "self-control" then
            local virtue = char:GetSelfControl()
            local upgradecost = virtue * 2

            if virtue >= 5 then return "You cannot upgrade Self-Control above Level 5." end 

            if xp < upgradecost then 
                return "You need " .. upgradecost .. " XP to advance your Self-Control to Level " .. virtue + 1 .. "." 
            else
                char:RemoveXP(upgradecost)
                char:SetData("SelfControl", virtue + 1)
                return "You upgraded Self Control to Level " .. char:GetData("SelfControl") .. "."
            end 


        elseif virtue == "courage" then 
            local virtue = char:GetCourage()
            local upgradecost = virtue * 2

            if virtue >= 5 then return "You cannot upgrade Courage above Level 5." end 

            if xp < upgradecost then 
                return "You need " .. upgradecost .. " XP to advance your Courage to Level " .. virtue + 1 .. "." 
            else
                char:RemoveXP(upgradecost)
                char:SetData("Courage", virtue + 1)
                return "You upgraded Courage to Level " .. char:GetData("Courage") .. "."
            end


            elseif virtue == "willpower" then 
                local virtue = char:GetData("Willpower")
                local upgradecost = virtue * 1
    
                if virtue >= 10 then return "You cannot upgrade Willpower above Level 10." end 
    
                if xp < upgradecost then 
                    return "You need " .. upgradecost .. " XP to advance your Willpower to Level " .. virtue + 1 .. "." 
                else
                    char:RemoveXP(upgradecost)
                    char:SetData("Willpower", virtue + 1)
                    return "You upgraded Willpower to Level " .. char:GetData("Willpower") .. "."
                end 
            else 
                return "Invalid virtue!"
            end 
       

	end
})


ix.command.Add("CharGiveXP", {
    arguments = {ix.type.character, ix.type.number},
    adminOnly = true,
	description = "Add XP to target.",
	OnRun = function(self, client, target, amount)
		target:AddXP(amount)
        return "Added " .. amount .. " XP to " .. target:GetName() .. "."
	end
})
