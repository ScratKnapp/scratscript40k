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
    if hp == self:GetMaxHP() then
        return "Healthy"
    elseif hp < self:GetMaxHP() and hp > 9 then
        return "Bruised"
    elseif hp == 8 then
        return "Scratched"
    elseif hp == 7 then
        return "Hurt"
    elseif hp == 6 then
        return "Injured"
    elseif hp == 5 then
        return "Wounded"
    elseif hp == 4 then
        return "Mauled"
    elseif hp == 3 then
        return "Maimed"
    elseif hp == 2 then
        return "Crippled"
    elseif hp == 1 then
        return "Critical Condition"
    elseif hp == 0 then
        return "Incapacitated"
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

ix.command.Add("rest", {
    description = "Heal yourself based on your Stamina and recover your Willpower. Can be used once every 20 hours.",
    OnRun = function(self, client)
        local character = client:GetCharacter()
        local currentTime = os.time()
        local lastUseTime = character:GetData("lastRest", 0)
        local timeSinceLastUse = currentTime - lastUseTime
        if timeSinceLastUse < 60 * 60 * 20 then
            local remainingTime = math.ceil((60 * 60 * 6 - timeSinceLastUse) / 60)
            return "You can only use this command once every 20 hours. Please wait " .. remainingTime .. " minutes."
        end

        local healamount = character:GetAttribute("stamina") + 1
        character:RestoreHP(healamount)
        character:SetData("SpentWP", 0)
        client:Notify("Restored " .. healamount .. "HP and filled Willpower.")
        if character:HasClass("Medic") then
            character:SetData("FreeHeals", 0)
            client:Notify("Gave free uses of /medicheal according to Medic class level.")
        end

        character:SetData("lastRest", currentTime)
    end
})

ix.command.Add("medicheal", {
    description = "Use your WP to heal an ally.",
    OnRun = function(self, client)
        local char = client:GetCharacter()
        local ply = client
        if not char:HasClass("Medic") then return "You need to have the Medic class to use this ability." end
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 96
        data.filter = client
        local target = util.TraceLine(data).Entity
        if not (IsValid(target) and target:IsPlayer() and target:GetCharacter()) then return "You need to be looking at another character." end
        local skill = char:GetSkill("medicine") + char:GetAttribute("intelligence")
        local classLevel = char:HasClass("Medic")
        if char:GetData("FreeHeals", 0) < classLevel then
            char:SetData("FreeHeals", char:GetData("FreeHeals", 0) + 1)
            client:Notify("Your current class level allows you to perform this heal for free. You can do this " .. classLevel - char:GetData("FreeHeals") .. " more times before your next Rest.")
        else
            if char:GetWillpower() == 0 then return "You need at least 1 Willpower to use this ability." end
            char:SetData("SpentWP", char:GetData("SpentWP", 0) + 1)
        end

        local difficulty = 6
        local pass = 0
        local fail = 0
        for i = skill, 1, -1 do
            local diceroll = math.random(1, 10)
            if diceroll == 10 then
                pass = pass + 2
            elseif diceroll == 1 then
                pass = pass - 1
            elseif diceroll >= difficulty then
                pass = pass + 1
            else
                fail = fail + 1
            end
        end

        if pass < 0 then pass = 0 end
        client:Notify("Rolling Medicine + Intelligence: " .. skill .. " dice against Diff 6")
        if pass == 0 then return "0 Successes! Roll Failed." end
        target:GetCharacter():RestoreHP(pass)
        client:Notify("Rolled " .. pass .. " successes. Healing " .. target:GetCharacter():GetName() .. " for " .. pass .. "HP.")
        target:Notify(char:GetName() .. " healed you for " .. pass .. "HP.")
    end
})

ix.command.Add("psykerheal", {
    description = "Use your WP to heal an ally.",
    OnRun = function(self, client)
        local char = client:GetCharacter()
        local ply = client
        if not char:HasClass("Combat Psyker") and not char:HasClass("Utility Psyker") then return "You need to be a Combat or Utility Psyker to use this ability." end
        if char:GetWillpower() == 0 then return "You need at least 1 Willpower to use this ability." end
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 96
        data.filter = client
        local target = util.TraceLine(data).Entity
        if not (IsValid(target) and target:IsPlayer() and target:GetCharacter()) then return "You need to be looking at another character." end
        local skill = char:GetSkill("warpattunement") + char:GetAttribute("manipulation")
        local difficulty = 6
        local pass = 0
        local fail = 0
        for i = skill, 1, -1 do
            local diceroll = math.random(1, 10)
            if diceroll == 10 then
                pass = pass + 2
            elseif diceroll == 1 then
                pass = pass - 1
            elseif diceroll >= difficulty then
                pass = pass + 1
            else
                fail = fail + 1
            end
        end

        if pass < 0 then pass = 0 end
        client:Notify("Rolling Warp Attunement + Manipulation: " .. skill .. " dice against Diff 6")
        if pass == 0 then return "0 Successes! Roll Failed." end
        target:GetCharacter():RestoreHP(pass * 3)
        client:Notify("Rolled " .. pass .. " successes. Healing " .. target:GetCharacter():GetName() .. " for " .. pass * 3 .. "HP.")
        target:Notify(char:GetName() .. " healed you for " .. pass * 3 .. "HP.")
    end
})