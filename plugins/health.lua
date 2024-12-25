local PLUGIN = PLUGIN
PLUGIN.name = "Health"
PLUGIN.author = "Scrat Knapp"
PLUGIN.description = "40k Health."
PLUGIN.StatusToDebuff = {
    ["Healthy"] = 0,
    ["Bruised"] = 0,
    ["Scratched"] = 0,
    ["Hurt"] = -1, 
    ["Injured"] = -2,
    ["Wounded"] = -2,
    ["Mauled"] = -3,
    ["Maimed"] = -4,
    ["Crippled"] = -4,
    ["Critical Condition"] = -5,
    ["Incapacitated"] = 0

}

local charMeta = ix.meta.character



function charMeta:GetMaxHP()
    return 10 + self:GetAttribute("stamina", 0) + self:GetRaceBonus("stamina")
end

function charMeta:GetHP()
    return self:GetData("HP", self:GetMaxHP())
end

function charMeta:DamageHP(amount)
    self:SetData("HP", self:GetHP() - amount)
    if self:GetHP() < 0 then self:SetData("HP", 0) end
end

function charMeta:RestoreHP(amount)
    self:SetData("HP", self:GetHP() + amount)
    if self:GetHP() > self:GetMaxHP() then self:SetData("HP", self:GetMaxHP()) end 
end

function charMeta:GetHealthStatus()
    local hp = self:GetHP()

    -- Don't judge me I'm lazy
    if hp == self:GetMaxHP() then return "Healthy"
    elseif hp < self:GetMaxHP() and hp > 9 then return "Bruised"
    elseif hp == 8 then return "Scratched"
    elseif hp == 7 then return "Hurt"
    elseif hp == 6 then return "Injured"
    elseif hp == 5 then return "Wounded"
    elseif hp == 4 then return "Mauled"
    elseif hp == 3 then return "Maimed"
    elseif hp == 2 then return "Crippled"
    elseif hp == 1 then return "Critical Condition"
    elseif hp == 0 then return "Incapacitated"
    end 
end

function charMeta:GetHealthDebuff()
    local status = self:GetHealthStatus()
   return PLUGIN.StatusToDebuff[status]
end

ix.command.Add("Status", {
	description = "Check your current HP and other statuses.",
	OnRun = function(self, client)
		local char = client:GetCharacter()
        client:Notify("Health: " .. char:GetHP() .. "/" .. char:GetMaxHP() .. " - " .. char:GetHealthStatus())
        client:Notify("Damage Resistance: " .. char:GetDR())
	end
})

ix.command.Add("CharGiveHP", {
    arguments = {ix.type.character, ix.type.number},
    adminOnly = true,
	description = "Add HP to target.",
	OnRun = function(self, client, target, amount)
        if amount < 0 then return "Amount must be a positive number." end 
		target:RestoreHP(amount)
        return "Added " .. amount .. " HP to " .. target:GetName() .. "."
	end
})

ix.command.Add("CharTakeHP", {
    arguments = {ix.type.character, ix.type.number},
    adminOnly = true,
	description = "Take HP from target.",
	OnRun = function(self, client, target, amount)
        if amount < 0 then return "Amount must be a positive number." end 
		target:DamageHP(amount)
        return "Removed " .. amount .. " HP from " .. target:GetName() .. "."
	end
})








