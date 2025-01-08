ITEM.name = "Nice name"
ITEM.description = "Nice desc"
ITEM.width = 2
ITEM.height = 2
ITEM.isArmor = true
ITEM.isMisc = true
ITEM.price = 1
ITEM.model = "models/props_c17/BriefCase001a.mdl"
ITEM.playermodel = nil
ITEM.isBodyArmor = true
ITEM.longdesc = "No longer description available."
ITEM.category = "Armor"
ITEM.skincustom = {}
ITEM.outfitCategory = "model"
ITEM.quality = "Normal"
ITEM.type = "Medium"
ITEM.AP = 0

ITEM:Hook("drop", function(item)
	if (item:GetData("equip")) then
		item.player.armor[item.armorclass] = nil
		local character = item.player:GetChar()
		item:SetData("equip", nil)
	
		item.player:SetNetVar(item.armorclass, nil)
		if (item.armorclass != "helmet") then
			item.player:SetModel(item.player:GetChar():GetModel())
		end
	end
end)

ITEM.functions.RemoveUpgrade = {
	name = "Remove Upgrade",
	tip = "Remove",
	icon = "icon16/wrench.png",
    isMulti = true,
    multiOptions = function(item, client)
	
	local targets = {}

	for k, v in pairs(item:GetData("mod", {})) do
		local attTable = ix.item.list[v[1]]
		local niceName = attTable:GetName()
		table.insert(targets, {
			name = niceName,
			data = {k},
		})
    end
    return targets
end,
	OnCanRun = function(item)
		if (table.Count(item:GetData("mod", {})) <= 0) then
			return false
		end
	    
		if item:GetData("equip") then
			return false
		end
		

		if not item.player:GetCharacter():HasFlags("R") then return false end 
		return (!IsValid(item.entity))

	end,
	OnRun = function(item, data)
		local client = item.player
		
		if (data) then
			local char = client:GetChar()

			if (char) then
				local inv = char:GetInv()

				if (inv) then
					local mods = item:GetData("mod", {})
					local attData = mods[data[1]]

					if (attData) then
						inv:Add(attData[1])
						mods[data[1]] = nil
                        
                        curPrice = item:GetData("RealPrice")
                	    if !curPrice then
                		    curPrice = item.price
                		end
                		
						local targetitem = ix.item.list[attData[1]]
						
                        item:SetData("RealPrice", (curPrice - targetitem.price))
                        
						if (table.Count(mods) == 0) then
							item:SetData("mod", nil)
						else
							item:SetData("mod", mods)
						end

						item:RecalculateValues()

						
						client:EmitSound("cw/holster4.wav")
					else
						client:NotifyLocalized("notAttachment")
					end
				end
			end
		else
			client:NotifyLocalized("detTarget")
		end
	return false
end,
}

if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		if (item:GetData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end

	function ITEM:PopulateTooltip(tooltip)
		if (self:GetData("equip")) then
			local name = tooltip:GetRow("name")
			name:SetBackgroundColor(derma.GetColor("Success", tooltip))
		end
	end
end

function ITEM:RemoveOutfit(client)
	local character = client:GetCharacter()
	local bgroups = {}

	self:SetData("equip", false)

	
	for k, _ in pairs(self:GetData("outfitAttachments", {})) do
		self:RemoveAttachment(k, client)
	end

	self:OnUnequipped()
end


-- makes another outfit depend on this outfit in terms of requiring this item to be equipped in order to equip the attachment
-- also unequips the attachment if this item is dropped
function ITEM:AddAttachment(id)
	local attachments = self:GetData("outfitAttachments", {})
	attachments[id] = true

	self:SetData("outfitAttachments", attachments)
end

function ITEM:RemoveAttachment(id, client)
	local item = ix.item.instances[id]
	local attachments = self:GetData("outfitAttachments", {})

	if (item and attachments[id]) then
		item:OnDetached(client)
	end

	attachments[id] = nil
	self:SetData("outfitAttachments", attachments)
end

function ITEM:OnInstanced()

	self:SetData("AP", self.AP)
	self:SetData("MaxAP", self:GetData("AP"))
	self:SetData("Type", self.type)
	self:SetData("Quality", self.quality)

	local AP = self:GetData("AP")
	local MaxAP = self:GetData("MaxAP")


	if self.quality == "Good" then
		self:SetData("AP", AP + 5)
		self:SetData("MaxAP", MaxAP + 5)
	end 

	if self.quality == "Best" then
		self:SetData("AP", AP + 6)
		self:SetData("MaxAP", MaxAP + 6)
	end 
end


ITEM:Hook("drop", function(item)
	local client = item.player
	local character = client:GetCharacter()
	item:RemoveOutfit(item:GetOwner())
end)

function ITEM:RemovePart(client)
	local char = client:GetCharacter()

	self:SetData("equip", false)




end

ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/cancel.png",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
				
		item:RemoveOutfit(item.player)
		
		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") == true and
			hook.Run("CanPlayerUnequipItem", client, item) != false and item.invID == client:GetCharacter():GetInventory():GetID()
	end
}

ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/accept.png",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local items = character:GetInventory():GetItems()

		if item.humanOnly and character:IsHuman() == false then
			client:Notify("Only Humans and Abhumans can equip this armor.")
			return false
		end 

		if item.race and item.race ~= character:GetBackground() then
			client:Notify("This armor can only be equipped by a " .. item.race .. ".")
			return false 
		end 





		
		for _, v in pairs(items) do
			if (v.id != item.id) then
				local itemTable = ix.item.instances[v.id]
				if itemTable then
					if (v.outfitCategory == item.outfitCategory and itemTable:GetData("equip")) then
						print("Success")
						item.player:Notify("You're already equipping this kind of outfit")
						return false
					end

					if (v.isHelmet == true and item.isHelmet == true and itemTable:GetData("equip")) then
						item.player:Notify("You are already equipping a helmet!")
						return false
					end

					if (v.isGasmask == true and item.isGasmask == true and itemTable:GetData("equip")) then
						item.player:Notify("You are already equipping a gasmask!")
						return false
					end
				end
			end
		end

		item:SetData("equip", true)
	
		local mods = item:GetData("mod")
		
		if mods then
			for k,v in pairs(mods) do
				local upgitem = ix.item.Get(v[1])
			end
		end
		
	
		item:OnEquipped()
		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true and
			hook.Run("CanPlayerEquipItem", client, item) != false and item.invID == client:GetCharacter():GetInventory():GetID()
	end
}

function ITEM:OnLoadout()
	if (self:GetData("equip")) then
		local client = self.player
		local character = client:GetCharacter()
	
		local mods = self:GetData("mod")
		
		if mods then
			for k,v in pairs(mods) do
				local upgitem = ix.item.Get(v[1])
			end
		end
		
	end
end

function ITEM:CanTransfer(oldInventory, newInventory)
	if (newInventory and self:GetData("equip")) then
		return false
	end

	return true
end

function ITEM:OnRemoved()
	local inventory = ix.item.inventories[self.invID]
	local owner = inventory.GetOwner and inventory:GetOwner()

	if (IsValid(owner) and owner:IsPlayer()) then
		if (self:GetData("equip")) then
		end
	end
end

function ITEM:OnEquipped()
	self:ApplyWeightBuffs()
	self:ApplySpecialQualityBuffs()
end

function ITEM:OnUnequipped()
	self:ClearBuffs()
end


function ITEM:GetDescription()
	local quant = self:GetData("quantity", 1)
	local str = self.description.."\n\n"..self.longdesc or ""
	local cc = false

	local customData = self:GetData("custom", {})
	if(customData.desc) then
		str = customData.desc
	end

	if (customData.longdesc) then
		str = str.. "\n\n" ..customData.longdesc 
	end

	if self.humanOnly then 
		str = str .. "\n\nOnly usable by Humans and Abhumans"
	end 

	if self.race then 
		str = str .. "\nOnly usable by " .. self.race .. " Race"
	end 

	if self:GetData("AP") then 
		str = str .. "\n\nArmor Points: " .. self:GetData("AP") .. "/" .. self:GetData("MaxAP")
	end 

	if self:GetData("Type") then
		str = str .. "\nArmor Type: " .. self:GetData("Type")
	end 

	if self:GetData("Quality") then 
		str = str .. "\n" .. self:GetData("Quality") .. " Craftmanship"
	end 

	if self.specialQualities then 
		str = str .. "\nSpecial Qualities:"

		for _, v in pairs(self.specialQualities) do
			str = str .. "\n• " .. v
		end 
	end 

	

	if self.noUpgrade then 
		str = str .."\n\n Does not take armor upgrades"
	end 
	
	
	
	
	local mods = self:GetData("mod", {})

	if mods then
		str = str .. "\n\nModifications:"
		for _,v in pairs(mods) do
			local moditem = ix.item.Get(v[1])
			str = str .. "\n" .. moditem.name
		end
	end


	if (self.entity) then
		return (self.description)
	else
        return (str)
	end
end

function ITEM:GetName()
	local name = self.name
	
	local customData = self:GetData("custom", {})
	if(customData.name) then
		name = customData.name
	end
	
	return name
end

ITEM.functions.Clone = {
	name = "Clone",
	tip = "Clone this item",
	icon = "icon16/wrench.png",
	OnRun = function(item)
		local client = item.player	
	
		client:requestQuery("Are you sure you want to clone this item?", "Clone", function(text)
			if text then
				local inventory = client:GetCharacter():GetInventory()
				
				if(!inventory:Add(item.uniqueID, 1, item.data)) then
					client:Notify("Inventory is full")
				end
			end
		end)
		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		return client:GetCharacter():HasFlags("N") and !IsValid(item.entity)
	end
}

ITEM.functions.Custom = {
	name = "Customize",
	tip = "Customize this item",
	icon = "icon16/wrench.png",
	OnRun = function(item)		
		ix.plugin.list["customization"]:startCustom(item.player, item)
		
		return false
	end,
	
	OnCanRun = function(item)
		local client = item.player
		return client:GetCharacter():HasFlags("N") and !IsValid(item.entity)
	end
}

function ITEM:HasQuality(qualityname)
	local hasQuality = false
	local qualities = self.specialQualities
	if qualities then
		for k,v in pairs(qualities) do
			if qualityname == v then
				hasQuality = true
				break
			end 

		end 
	end
    return hasQuality
end

function ITEM:ApplyWeightBuffs()
	local client = self.player
	local character = client:GetCharacter()
	local weight = self:GetData("Type", "Medium")

	if weight == "Light" then
		character:AddBoost("Weight", "dexterity", 1)
	elseif weight == "Heavy" then
		character:AddBoost("Weight", "stamina", 1)
	elseif weight == "Power" then
		character:AddBoost("Weight", "strength", 3)
	end 
end 

function ITEM:ApplySpecialQualityBuffs()
	local client = self.player
	local character = client:GetCharacter()
	
	if self:HasQuality("Fashionable") then
		character:AddBoost("Fashionable", "appearance", 1)
	end 

	if self:HasQuality("Medicae") then
		character:AddSkillBoost("Medicae", "medicine", 2)
	end 

	if self:HasQuality("Wraithbone") then
		character:AddBoost("Wraithbone", "dexterity", 1)
	end 

	if self:HasQuality("Asuryani-Runes") then
		character:AddSkillBoost("Asuryani-Runes", "warpattunement", 2)
	end 

	if self:HasQuality("Intimidating") then
		character:AddSkillBoost("Intimidating", "intimidation", 2)
	end 
	
	if self:HasQuality("Disgusting") then
		character:AddBoost("Disgusting", "appearance", -1)
	end 
	
	if self:HasQuality("Deus Mechanicus") then
		character:AddBoost("Deus Mechanicus", "intelligence", 1)
		character:AddSkillBoost("Deus Mechanicus", "tech", 1)
	end 

	if self:HasQuality("Psi-Enhancing") then
		character:AddSkillBoost("Psi-Enhancing", "warpattunement", 1)
	end 

	if self:HasQuality("Navis-Nobilite") then
		character:AddBoost("Navis-Nobilite", "charisma", 1)
		character:AddSkillBoost("Navis-Nobilite", "navigation", 1)
	end 

	if self:HasQuality("Astartes") then
		character:AddBoost("Astartes", "stamina", 2)
		character:AddBoost("Astartes", "strength", 1)
	end 

	
	if self:HasQuality("Minor-Runes") then
		character:AddSkillBoost("Minor-Runes", "warpattunement", 1)
	end 


	


end 


function ITEM:ClearBuffs()
	local client = self.player
	local character = client:GetCharacter()
	
	local boosts = character:GetBoosts()
	for attribID, v in pairs(boosts) do
		for boostID, _ in pairs(v) do
			character:RemoveBoost(boostID, attribID)
		end
	end

	local skillboosts = character:GetSkillBoosts()
	for attribID, v in pairs(skillboosts) do
		for boostID, _ in pairs(v) do
			character:RemoveSkillBoost(boostID, attribID)
		end
	end



	
end 