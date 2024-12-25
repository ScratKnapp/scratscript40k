-- [[ COMMANDS ]] --

--[[
	COMMAND: /Roll
	DESCRIPTION: Allows the player to roll an arbitrary amount of dice and apply bonuses as needed.
]]--

ix.command.Add("Roll", {
	syntax = "<dice roll>",
	description = "Calculates a dice roll (e.g. 2d6 + 2) and shows the result.",
	arguments = {
		ix.type.text
	},
	OnRun = function(self, client, rolltext)
		result, rolltext = ix.dice.Roll( rolltext, client )

		ix.chat.Send( client, "rollgeneric", tostring( result ), nil, nil,{
			roll = "( "..rolltext.." )"
		} )
	end
})

ix.command.Add("CharAddTrait", {
    description = "Give trait to a character.",
    adminOnly = true,
    arguments = {
        ix.type.character, 
        ix.type.string},
    OnRun = function(self, client, target, trait)
        
        target:AddTrait(trait)

        return "Added " .. trait .. " to " .. target:GetName()

        
    end
})


ix.command.Add("CharRemoveTrait", {
    description = "Remove trait from a character.",
    adminOnly = true,
    arguments = {
        ix.type.character, 
        ix.type.string},
    OnRun = function(self, client, target, trait)
        
        target:RemoveTrait(trait)
        return "Removed " .. trait .. " from " .. target:GetName()

        
    end
})

ix.command.Add("CharGetSkills", {
	description = "Get all traits given character has.",
    adminOnly = true,
    arguments = {ix.type.character},
	OnRun = function(self, client, target)
		local str = target:GetName() .. " has the following traits:"
        local char = target
        local player = target:GetPlayer()
        local traitTable = char:GetTraits()

        for k, v in pairs(traitTable) do
            str = str .. "\n" .. k
        end 

        return str
	end
})

ix.command.Add("CharGetTraits", {
	description = "Get all traits given character has.",
    adminOnly = true,
    arguments = {ix.type.character},
	OnRun = function(self, client, target)
		local str = target:GetName() .. " has the following traits:"
        local char = target
        local player = target:GetPlayer()
        local traitTable = char:GetTraits()

        for k, v in pairs(traitTable) do
            str = str .. "\n" .. k
        end 

        return str
	end
})

ix.command.Add("CharShowSkills", {
	description = "Show skill values for given character.",
	privilege = "Manage Character Attributes",
	adminOnly = true,
	arguments = {
		ix.type.character
	},

	OnRun = function(self, client, target)

		local str = "Skills for " .. target:GetName() .. ":\n"
	
		for id, attribute in pairs(ix.skills.list) do
			str = str .. skill.name .. ": " .. target:GetSkill(id) .. "\n"
		end

		
		return str
	end 
})

ix.command.Add("CharSetSkill", {
    description = "Set given skill for character.",
    privilege = "Manage Character Attributes",
    adminOnly = true,
    arguments = {
        ix.type.character,
        ix.type.string,
        ix.type.number
    },

    OnRun = function(self, client, target, skill, amount)
        if not target:GetSkill(skill) then return "Invalid skill!" end
        target:SetSkill(skill, amount)
        return "Set " .. skill .. " skill of " .. target:GetName() .. " to " .. amount
    end 
})

