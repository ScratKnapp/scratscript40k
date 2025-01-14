local PLUGIN = PLUGIN
PLUGIN.turnOrder = {}
PLUGIN.currentTurnIndex = 1
PLUGIN.initiativeActive = false
PLUGIN.playerStartPos = {}
PLUGIN.playerVisibility = {}
local function sortTurnOrder()
    table.sort(PLUGIN.turnOrder, function(a, b) return a.roll > b.roll end)
end

local function updateTurnOrderHUD()
    if SERVER then
        for _, client in ipairs(player.GetAll()) do
            if PLUGIN.playerVisibility[client] then
                net.Start("UpdateTurnOrderHUD")
                net.WriteBool(PLUGIN.initiativeActive)
                net.WriteTable(PLUGIN.turnOrder)
                net.WriteUInt(PLUGIN.currentTurnIndex, 8)
                net.Send(client)
            end
        end
    end
end

local function notifyTurn()
    if SERVER and PLUGIN.initiativeActive and #PLUGIN.turnOrder > 0 then
        local currentEntry = PLUGIN.turnOrder[PLUGIN.currentTurnIndex]
        local nextPlayerIndex = PLUGIN.currentTurnIndex % #PLUGIN.turnOrder + 1
        local nextEntry = PLUGIN.turnOrder[nextPlayerIndex]
        if currentEntry then
            if currentEntry.player then
                PLUGIN.playerStartPos[currentEntry.player] = currentEntry.player:GetPos()
                net.Start("PlayTurnSound")
                net.WriteString("ork/ork_alert3.mp3")
                net.Send(currentEntry.player)
                currentEntry.player:ChatPrint("It is your turn!")
            elseif currentEntry.entity then
                currentEntry.entity:SetNetVar("isTurn", true)
                currentEntry.entity:Fire("TurnStart", "", 0)
            end
        end

        if nextEntry then
            if nextEntry.player then
                net.Start("PlayTurnSound")
                net.WriteString("ork/ork_idle1.mp3")
                net.Send(nextEntry.player)
                nextEntry.player:ChatPrint("Your turn is next!")
            elseif nextEntry.entity then
                nextEntry.entity:SetNetVar("isNextTurn", true)
            end
        end
    end
end

ix.command.Add("initiativeon", {
    description = "Turns on the initiative system for everyone on the server (superadmin only).",
    superAdminOnly = true,
    OnRun = function(self, client)
        if PLUGIN.initiativeActive then return "Initiative system is already active." end
        PLUGIN.initiativeActive = true
        PLUGIN.turnOrder = {}
        PLUGIN.currentTurnIndex = 1
        for _, ply in ipairs(player.GetAll()) do
            PLUGIN.playerVisibility[ply] = true
        end

        updateTurnOrderHUD()
        return "Initiative system activated for everyone on the server."
    end
})

ix.command.Add("toggleinitiative", {
    description = "Join or leave the initiative system (players only).",
    OnRun = function(self, client)
        if not PLUGIN.initiativeActive then return "Initiative is not active." end
        PLUGIN.playerVisibility[client] = not PLUGIN.playerVisibility[client]
        if PLUGIN.playerVisibility[client] then
            updateTurnOrderHUD()
            return "You have joined the initiative."
        else
            return "You have left the initiative."
        end
    end
})

ix.command.Add("centslay", {
    description = "Kills the combat entity you are looking at and removes it from the turn order.",
    adminOnly = true,
    OnRun = function(self, client)
        local entity = client:GetEyeTrace().Entity
        if IsValid(entity) and entity.combat then
            local dmgInfo = DamageInfo()
            dmgInfo:SetDamage(100)
            dmgInfo:SetDamageType(DMG_GENERIC)
            dmgInfo:SetAttacker(client)
            dmgInfo:SetInflictor(client)
            entity:TakeDamageInfo(dmgInfo)
            entity:BecomeRagdoll(dmgInfo)
            for i, entry in ipairs(PLUGIN.turnOrder) do
                if entry.entity == entity then
                    table.remove(PLUGIN.turnOrder, i)
                    updateTurnOrderHUD()
                    break
                end
            end

            client:Notify(entity:GetNetVar("name", "The entity") .. " has been slain.")
        else
            client:Notify("You must be looking at a combat entity.")
        end
    end
})

ix.command.Add("initiative", {
    description = "Rolls initiative for the player.",
    OnRun = function(self, client)
        if not PLUGIN.initiativeActive then return "Initiative is not active." end
        local character = client:GetCharacter()
        local roll = math.random(1, 10) + character:GetAttribute("wits", 0) + character:GetAttribute("dexterity", 0)
        table.insert(PLUGIN.turnOrder, {
            name = character:GetName(),
            roll = roll,
            player = client
        })

        sortTurnOrder()
        updateTurnOrderHUD()
        return string.format("%s rolled %d for initiative.", character:GetName(), roll)
    end
})

ix.command.Add("pass", {
    description = "Pass your turn.",
    OnRun = function(self, client)
        if not PLUGIN.initiativeActive then return "Initiative is not active." end
        if PLUGIN.turnOrder[PLUGIN.currentTurnIndex].player ~= client then return "It is not your turn." end
        PLUGIN.currentTurnIndex = PLUGIN.currentTurnIndex % #PLUGIN.turnOrder + 1
        PLUGIN.playerStartPos[client] = nil
        updateTurnOrderHUD()
        notifyTurn()
        return "You have passed your turn."
    end
})

ix.command.Add("forcepass", {
    description = "Forces the turn order to pass to the next player or entity.",
    adminOnly = true,
    OnRun = function(self, client)
        if #PLUGIN.turnOrder == 0 then return "No one is in the turn order." end
        local currentEntry = PLUGIN.turnOrder[PLUGIN.currentTurnIndex]
        if currentEntry.player then
            PLUGIN.playerStartPos[currentEntry.player] = nil
        elseif currentEntry.entity then
            currentEntry.entity:SetNetVar("isTurn", false)
        end

        PLUGIN.currentTurnIndex = PLUGIN.currentTurnIndex % #PLUGIN.turnOrder + 1
        updateTurnOrderHUD()
        notifyTurn()
        return "Turn passed to the next player or entity."
    end
})

ix.command.Add("removeinitiative", {
    description = "Removes a player from the initiative order.",
    adminOnly = true,
    arguments = ix.type.character,
    OnRun = function(self, client, target)
        for i, entry in ipairs(PLUGIN.turnOrder) do
            if entry.name == target:GetName() then
                table.remove(PLUGIN.turnOrder, i)
                updateTurnOrderHUD()
                return target:GetName() .. " has been removed from the turn order."
            end
        end
        return "Player not found in the turn order."
    end
})

ix.command.Add("centinitiative", {
    description = "Rolls initiative for the combat entity you are looking at.",
    adminOnly = true,
    OnRun = function(self, client)
        local entity = client:GetEyeTrace().Entity
        if not IsValid(entity) or not entity.combat then
            client:Notify("You must be looking at a combat entity.")
            return
        end

        if not PLUGIN.initiativeActive then return "Initiative is not active." end
        for _, entry in ipairs(PLUGIN.turnOrder) do
            if entry.entity == entity then return "This entity is already in the turn order." end
        end

        local roll = math.random(1, 10)
        table.insert(PLUGIN.turnOrder, {
            name = entity:GetNetVar("name", entity.PrintName or "CENT"),
            roll = roll,
            entity = entity
        })

        sortTurnOrder()
        updateTurnOrderHUD()
        return string.format("%s rolled %d for initiative.", entity:GetNetVar("name", entity.PrintName or "CENT"), roll)
    end
})

ix.command.Add("initiativeoff", {
    description = "Turns off the initiative system (admin only).",
    adminOnly = true,
    OnRun = function(self, client)
        PLUGIN.initiativeActive = false
        PLUGIN.turnOrder = {}
        PLUGIN.currentTurnIndex = 1
        updateTurnOrderHUD()
        return "Initiative system deactivated."
    end
})

ix.command.Add("findrange", {
    description = "Find the range to a player or CENT in the turn order.",
    arguments = ix.type.text,
    OnRun = function(self, client, targetName)
        local target = nil
        for _, entry in ipairs(PLUGIN.turnOrder) do
            if entry.name == targetName then
                target = entry.player or entry.entity
                break
            end
        end

        if not target then return "Player or CENT not found in the turn order." end
        local distanceUnits = client:GetPos():Distance(target:GetPos())
        local distanceMeters = math.Round(distanceUnits / 50, 2)
        net.Start("UpdateRangeFinder")
        net.WriteString(targetName)
        net.WriteFloat(distanceMeters)
        net.Send(client)
        return string.format("The distance to %s is %.2f meters.", targetName, distanceMeters)
    end
})

ix.command.Add("rangeclear", {
    description = "Clears the rangefinder target and distance.",
    OnRun = function(self, client)
        net.Start("UpdateRangeFinder")
        net.WriteString("")
        net.WriteFloat(0)
        net.Send(client)
        return "Rangefinder target cleared."
    end
})

ix.command.Add("centattack", {
    description = "Makes the CENT entity you are looking at attack the specified target.",
    adminOnly = true,
    arguments = ix.type.text,
    OnRun = function(self, client, targetName)
        local cent = client:GetEyeTrace().Entity
        if not IsValid(cent) or not cent.combat then
            client:Notify("You must be looking at a valid combat-enabled CENT entity.")
            return
        end

        local target = nil
        for _, entry in ipairs(PLUGIN.turnOrder) do
            if entry.name == targetName then
                target = entry.player or entry.entity
                break
            end
        end

        if not target then
            client:Notify("Target not found in the turn order.")
            return
        end

        if cent.PrimaryAttack then
            cent:PrimaryAttack()
        else
            client:Notify("This CENT does not have a valid attack function.")
            return
        end

        local message = string.format("<color=red>%s</color> attacks <color=red>%s</color>", cent:GetNetVar("name", "CENT"), targetName)
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():Distance(cent:GetPos()) <= 1500 then ply:ChatPrint(message) end
        end
        return string.format("%s has attacked %s.", cent:GetNetVar("name", "CENT"), targetName)
    end
})

ix.command.Add("findrangecent", {
    description = "Find the range to a CENT entity in the turn order.",
    arguments = ix.type.text,
    OnRun = function(self, client, targetName)
        local target = nil
        for _, entry in ipairs(PLUGIN.turnOrder) do
            if entry.entity and entry.name == targetName then
                target = entry.entity
                break
            end
        end

        if not target then return "CENT entity not found in the turn order." end
        local distanceUnits = client:GetPos():Distance(target:GetPos())
        local distanceMeters = math.Round(distanceUnits / 50, 2)
        net.Start("UpdateRangeFinder")
        net.WriteString(targetName)
        net.WriteFloat(distanceMeters)
        net.Send(client)
        return string.format("The distance to %s is %.2f meters.", targetName, distanceMeters)
    end
})