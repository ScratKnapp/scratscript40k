local PLUGIN = PLUGIN
PLUGIN.name = "Stat Rolling"
PLUGIN.author = "Scrat Knapp"
PLUGIN.description = "cheese.wav"


----= Attributes =----


-- Chat type for rolls
ix.chat.Register("rollstat", {
    format = "** %s rolled for %s Difficulty %s with %sd10 %s: %s \nAmmo Used: %s \nSuccess: %s\nFail: %s",
    color = Color(155, 111, 176),
    CanHear = ix.config.Get("chatRange", 280),
    deadCanChat = true,
    OnChatAdd = function(self, speaker, text, bAnonymous, data)
        local translated = L2(self.uniqueID.."Format", speaker:Name(), text)
        chat.AddText(self.color, translated and "** "..translated or string.format(self.format, speaker:Name(), data.attname, data.difficulty, data.dicepool, data.modifierstring, data.rollstring, data.ammotype, data.pass, data.fail))
    end
})

 if (SERVER) then
    ix.log.AddType("rollStat", function(client, attname, dicepool, pass, fail, rollstring, difficulty)
        return string.format("%s rolled for %s Difficulty %s with %s d10: %s \nSuccess: %s\nFail: %s", client:Name(), attname, difficulty, dicepool, rollstring, pass, fail)
    end)
end

-- Go through each attribute and make a command of the same name
for k, v in pairs(ix.attributes.list) do

    ix.command.Add(string.lower(v.name), {
        description = "Roll a " .. v.name .. " check based on your Attribute's dice pool. Optional modifier.",
        arguments = {ix.type.number, bit.bor(ix.type.number, ix.type.optional)},
        OnRun = function(self, client, difficulty, modifier)

            if difficulty < 0 then return "Difficulty cannot be negative." end  

            local char = client:GetCharacter()
            local attname = v.name
            local dicepool = 0
            local pass = 0
            local fail = 0

            local attboost = char:GetAttribute(k)
            local raceboost = char:GetRaceBonus(k)
            local injurydebuff = char:GetHealthDebuff()

            dicepool = dicepool + attboost + raceboost + injurydebuff
            if modifier then dicepool = dicepool + modifier end

            local rollstring = ""

            for i=dicepool, 1 ,-1 do 

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

                rollstring = rollstring .. diceroll .. ", "
            end 

            ix.chat.Send(client, "rollStat", tostring(dicepool), nil, nil, {
               attname = attname,
               dicepool = dicepool,
               pass = pass,
               fail = fail,
               rollstring = rollstring,
               difficulty = difficulty
            })
    
           ix.log.Add(client, "rollStat", attname, dicepool, pass, fail, rollstring, difficulty)
        end
    })
end 


----= Skills =----

for k, v in pairs (ix.skills.list) do 
    ix.command.Add(k, {
        description = "Roll a " .. v.name .. " check based on your Skill and parent Attribute dice pool. Optional modifier.",
        arguments = {ix.type.number, bit.bor(ix.type.number, ix.type.optional)},
        OnRun = function(self, client, difficulty, modifier)

            if difficulty < 0 then return "Difficulty cannot be negative." end  

            local char = client:GetCharacter()
            local attname = v.name
            local dicepool = 0
            local pass = 0
            local fail = 0

            local skillboost = char:GetSkill(k)
            local attboost = char:GetAttribute(v.attribute)
            local raceboost = char:GetRaceBonus(k)
            local professionboost = 0
            local injurydebuff = char:GetHealthDebuff()

            
            if k == char:GetProfessionSkill() then 
                professionboost = 1
            end 

            dicepool = dicepool + skillboost + attboost + raceboost + professionboost + injurydebuff
            if modifier then dicepool = dicepool + modifier end

            local rollstring = ""
            local modifierstring = ""

            for i=dicepool, 1 ,-1 do 

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

                rollstring = rollstring .. diceroll .. ", "
            end 

            if modifier then
                modifierstring = "(Modifiier of " .. modifier .. ")"
            end 

            ix.chat.Send(client, "rollStat", tostring(dicepool), nil, nil, {
               attname = attname,
               dicepool = dicepool,
               pass = pass,
               fail = fail,
               rollstring = rollstring,
               difficulty = difficulty,
               modifier = modifier,
               modifierstring = modifierstring
            })
    
           ix.log.Add(client, "rollStat", attname, dicepool, pass, fail, rollstring, difficulty)
        end
    })

    
end 



---=Shooting=----

ix.command.Add("fire", {
    description = "Roll a ranged shooting check based on your Attribute's dice pool, split between however many shots as you wish. Optional modifier.",
    arguments = {ix.type.number, ix.type.number, bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, shots, difficulty, modifier)

        if difficulty < 0 then return "Difficulty cannot be negative." end  
        if shots <= 0 then return "Cannot have 0 or less shots." end 

        local char = client:GetCharacter()
        local attname = "Ranged Fire"
        local dicepool = 0

        local skillboost = char:GetSkill("marksmanship")
        local attboost = char:GetAttribute("dexterity")
        local raceboost = char:GetRaceBonus("marksmanship")
        local professionboost = 0
        local injurydebuff = char:GetHealthDebuff()

        if char:GetProfessionSkill() == "marksmanship" then 
            professionboost = 1
        end 

        dicepool = dicepool + skillboost + attboost + raceboost + injurydebuff
        if modifier then dicepool = dicepool + modifier end

        if shots > dicepool then return "Don't have enough die to roll " .. shots .. " shots." end 

        local weapon = client:GetActiveWeaponItem()

        if not weapon then return "You need to equip a ranged weapon." end 

        local ammotype = char:DeductAmmo(weapon:GetData("AmmoType", "normal"), shots)

        if not ammotype then return "Not enough ammo to fire this amount of shots!" end 

        local rollsplit = {}

        -- Only split dice pool if we're actually splitting it to begin with, else allocate entire pool to one roll
        if shots == 1 then 
            table.insert(rollsplit, dicepool)
        else
            rollsplit = splitdice(dicepool, shots)
        end 

        for _, group in ipairs(rollsplit) do 

            local pass = 0
            local fail = 0
            local rollstring = ""
            local modifierstring = ""

            for i=group, 1 ,-1 do 

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
    
                rollstring = rollstring .. diceroll .. ", "
            end 
    
            if modifier then
                modifierstring = "(Total Modifier of " .. modifier .. ")"
            end 

    
            ix.chat.Send(client, "rollStat", tostring(group), nil, nil, {
               attname = attname,
               dicepool = group,
               pass = pass,
               fail = fail,
               rollstring = rollstring,
               difficulty = difficulty,
               modifier = modifier,
               modifierstring = modifierstring,
               ammotype = ammotype 
            })
    
           ix.log.Add(client, "rollStat", attname, group, pass, fail, rollstring, difficulty)

        end 

       
    end
    
})

ix.command.Add("autofire", {
    description = "Dump all your dice plus your weapon's autofire rating into one burst. Optional modifier.",
    arguments = {ix.type.number, bit.bor(ix.type.number, ix.type.optional), bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, difficulty, rofmodifier, modifier)

        if not rofmodifier then rofmodifier = 0 end 

        if difficulty < 0 then return "Difficulty cannot be negative." end  

        local char = client:GetCharacter()
        local attname = "Automatic Fire"
        local dicepool = 0

        local skillboost = char:GetSkill("marksmanship")
        local attboost = char:GetAttribute("dexterity")
        local raceboost = char:GetRaceBonus("marksmanship")
        local professionboost = 0
        local injurydebuff = char:GetHealthDebuff()

        if char:GetProfessionSkill() == "marksmanship" then 
            professionboost = 1
        end 

        local weapon = client:GetActiveWeaponItem()

        if not weapon then return "You need to equip a ranged weapon." end 
        if not weapon.auto then return "Your current weapon is not capable of automatic fire." end

        local shots = weapon.auto + rofmodifier

        if shots <= 0 then return "Cannot fire 0 or less shots." end 

        dicepool = dicepool + skillboost + attboost + raceboost + injurydebuff + shots
        if modifier then dicepool = dicepool + modifier end

    
    

        local ammotype = char:DeductAmmo(weapon:GetData("AmmoType", "normal"), shots)

        if not ammotype then return "Not enough ammo to fire this amount of shots!" end 
  

        local rollsplit = {dicepool}

        for _, group in ipairs(rollsplit) do 

            local pass = 0
            local fail = 0
            local rollstring = ""
            local modifierstring = ""

            for i=group, 1 ,-1 do 

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
    
                rollstring = rollstring .. diceroll .. ", "
            end 
    
            if modifier then
                modifierstring = "(Modifier of " .. modifier .. ")"
            end 

    
            ix.chat.Send(client, "rollStat", tostring(group), nil, nil, {
               attname = attname,
               dicepool = group,
               pass = pass,
               fail = fail,
               rollstring = rollstring,
               difficulty = difficulty,
               modifier = modifier,
               modifierstring = modifierstring,
               ammotype = ammotype
            })
    
           ix.log.Add(client, "rollStat", attname, group, pass, fail, rollstring, difficulty)

        end 

       
    end
    
})


ix.command.Add("Rollstatmodifier", {
    description = "Roll a number out of the given maximum and add the given amount to it.",
    arguments = {ix.type.number, bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, modifier, maximum)
        maximum = math.Clamp(maximum or 100, 0, 1000000)

        local value = math.random(0, maximum)
        local modifier = modifier or 0
        local total = value + modifier
     
        
        ix.chat.Send(client, "rollStatModifier", tostring(value), nil, nil, {
            val = value,
            mod = modifier,
            max = maximum,
            tot = total
            
        })
    end
})

ix.chat.Register("rollStatModifier", {
    format = "** %s rolled %s + %s = %s out of %s",
    color = Color(155, 111, 176),
    CanHear = ix.config.Get("chatRange", 280),
    deadCanChat = true,
    OnChatAdd = function(self, speaker, text, bAnonymous, data)
        local max = data.max or 100
        local mod = data.mod or 0
        local val = data.val
        local tot = data.tot
     
        --local total = add + data.initialroll
        local translated = L2(self.uniqueID.."Format", speaker:Name(), text, max)

        chat.AddText(self.color, translated and "** "..translated or string.format(self.format,speaker:Name(), val, mod, tot, max))
    end
})


function splitdice(total, group_size)
    local groups = {}
    local remainder = total % group_size
    local base_size = math.floor(total / group_size)
    local extra = total - (base_size * group_size)

    for i = 1, group_size do
        if i <= extra then
            table.insert(groups, base_size + 1)
        else
            table.insert(groups, base_size)
        end
    end

    return groups
end


local charMeta = ix.meta.character

function charMeta:DeductAmmo(type, amt)


    local client = self:GetPlayer()
    local ammotype = "ammo_" .. type
    local founditem = false 



    for k,v in pairs(self:GetInv():GetItemsByUniqueID(ammotype)) do

        local ammoItem = v
        if ammoItem:GetData("stacks", 0) < amt then continue end

        ammoItem:SetData("stacks", ammoItem:GetData("stacks") - amt)
        if ammoItem:GetData("stacks", 0) <= 0 then ammoItem:Remove() end
        founditem = v.name 
        break 


			
	end

    return founditem 
end 



local playerMeta = FindMetaTable("Player")

function playerMeta:GetActiveWeaponItem()

	local swep = self:GetActiveWeapon()
	if not swep then return false end 
	local weaponItem
	local wepclass = swep:GetClass()

	for k,v in pairs(self:GetChar():GetInv():GetItems()) do
        if v:GetData("equip",false) == true then
            if wepclass == v.class then
                weaponItem = v
            end
        end
	end

	return weaponItem
end 