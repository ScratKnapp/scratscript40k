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
    local WP = (self:GetCourage() + self:GetData("Willpower", 0)) - self:GetData("SpentWP", 0)
    if WP < 0 then WP = 0 end 

    return WP
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


ix.command.Add("WP", {
	description = "Spend some Willpower for the day.",
    arguments = {
		ix.type.number,
	},
	OnRun = function(self, client, amount)
		local char = client:GetCharacter()
        local WP = char:GetWillpower()

        if WP <= 0 then return "You have no Willpower left to spend." end
        if WP < amount then return "You don't have enough Willpower to spend " .. amount .. " points." end 

        char:SetData("SpentWP", char:GetData("SpentWP", 0) + amount)
        return "You spent " .. amount .. " points of Willpower. You have " ..char:GetWillpower() .. " remaining."
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