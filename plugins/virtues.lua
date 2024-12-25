local PLUGIN = PLUGIN
PLUGIN.name = "Virtues"
PLUGIN.author = "Scrat Knapp"
PLUGIN.description = "40k Virtues."

local charMeta = ix.meta.character

function charMeta:GetConscience()
    return self:GetData("Conscience", 0)
end

function charMeta:GetSelfControl()
    return self:GetData("SelfControl", 0)
end 

function charMeta:GetCourage()
    return self:GetData("Courage", 0)
end 

function charMeta:GetSanity()

    local sanity = self:GetConscience() + self:GetSelfControl()

    if self:GetBackground() == "Gland Warrior" then
        sanity = sanity - 2
    end

    return sanity 
end 

function charMeta:GetWillpower()
   return self:GetCourage() + self:GetData("Willpower", 0)
end 

ix.command.Add("Virtues", {
	description = "Display your virtues.",
	OnRun = function(self, client)
		local char = client:GetCharacter()
		client:Notify("Conscience: " .. char:GetConscience())
        client:Notify("Self Control: " .. char:GetSelfControl())
        client:Notify("Courage: " .. char:GetCourage())
        client:Notify("Sanity: " .. char:GetSanity())
        client:Notify("Willpower: " .. char:GetWillpower())
	end
})


ix.command.Add("CharGetVirtues", {
	description = "Display virtues of given character.",
    privilege = "Manage Character Attributes",
	adminOnly = true,
    arguments = {
		ix.type.character,
	},
	OnRun = function(self, client, target)
		local char = target
        client:Notify("Virtues for " .. target:GetName() .. ":")
		client:Notify("Conscience: " .. char:GetConscience())
        client:Notify("Self Control: " .. char:GetSelfControl())
        client:Notify("Courage: " .. char:GetCourage())
        client:Notify("Sanity: " .. char:GetSanity())
        client:Notify("Willpower: " .. char:GetWillpower())
	end
})

ix.command.Add("CharSetVirtue", {
	description = "Set virtue for given character.",
    privilege = "Manage Character Attributes",
	adminOnly = true,
    arguments = {
		ix.type.character,
		ix.type.string,
		ix.type.number,
	},
	OnRun = function(self, client, target, virtue, value)
		
        virtue = string.lower(virtue)

        if virtue == "conscience" then 
            target:SetData("Conscience", value)
            return "Set Conscience of " .. target:GetName() .. " to " ..value 

        elseif virtue == "courage" then 
            target:SetData("Courage", value)
            return "Set Courage of " .. target:GetName() .. " to " ..value 

        elseif virtue == "selfcontrol" then 
            target:SetData("SelfControl", value)
            return "Set Self Control of " .. target:GetName() .. " to " ..value 

        elseif virtue == "willpower" then 
            target:SetData("Willpower", value)
            return "Set Willpower of " .. target:GetName() .. " to " ..value .. ". Note that this will be added to their Courage for their full Willpower value."

        else
            return "Invalid virtue. Valid options are: conscience, courage, selfcontrol, willpower."

        end 


	end
})

ix.command.Add("CharSetVirtuePoints", {
	description = "Set virtue points for given character.",
    privilege = "Manage Character Attributes",
	adminOnly = true,
    arguments = {
		ix.type.character,
		ix.type.number,
	},
	OnRun = function(self, client, target, value)
        target:SetData("VirtuePoints", value)
        client:Notify("Set Virtue Points of " .. target:GetName() .. " to " .. value)
	end
})