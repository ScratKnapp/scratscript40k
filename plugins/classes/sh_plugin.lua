local PLUGIN = PLUGIN
PLUGIN.name = "classes"
PLUGIN.author = "Verne"
PLUGIN.desc = "classes that can be added to a character.."

ix.command.Add("CharSetClass", {
	description = "Assign a class to a character. Wipes their old one.",
	privilege = "Manage Character Attributes",
	adminOnly = true,
	arguments = {
		ix.type.character,
		ix.type.string,
		ix.type.number,
		ix.type.number
	},
	OnRun = function(self, client, target, className, slot, level)

		if slot ~= 1 and slot ~= 2 and slot ~= 3 then
			return "You must assign the class to slot 1, 2, or 3 for Primary, Secondary, and Tertiary."
		end

		if slot == 1 then

			local Class = {}
			Class.level = level 

			for k, v in pairs(ix.charclasses.list) do
				if (ix.util.StringMatches(L(v.name, client), className) or ix.util.StringMatches(k, className)) then

					if v.race then
						if v.race ~= target:GetBackground() then return "Target's Race cannot have this Class." end 
					end

					Class.name = v.name

					target:SetData("PrimaryClass", {
						name = Class.name,
						level = Class.level,
					})
			
					return "Assigned Primary class " .. Class.name .. " to " .. target:GetName() .. " at Level " .. Class.level
				end
			end
			
			return "Class not found!"
		end 
		

		if slot == 2 then

			local Class = {}
			Class.level = level 

			for k, v in pairs(ix.charclasses.list) do
				if (ix.util.StringMatches(L(v.name, client), className) or ix.util.StringMatches(k, className)) then

					if v.race then
						if v.race ~= target:GetBackground() then return "Target's Race cannot have this Class."  end 
					end

					Class.name = v.name

					target:SetData("SecondaryClass", {
						name = Class.name,
						level = Class.level,
					})

					return "Assigned Secondary class " .. Class.name .. " to " .. target:GetName() .. " at Level " .. Class.level
				end 
			end

			return "Class not found!"			
		end 

		if slot == 3 then

			local Class = {}
			Class.level = level 

			for k, v in pairs(ix.charclasses.list) do
				if (ix.util.StringMatches(L(v.name, client), className) or ix.util.StringMatches(k, className)) then

					if v.race then
						if v.race ~= target:GetBackground() then return "Target's Race cannot have this Class." end 
					end

					Class.name = v.name

						target:SetData("TertiaryClass", {
						name = Class.name,
						level = Class.level,
					})
					return "Assigned Tertiary class " .. Class.name .. " to " .. target:GetName() .. " at Level " .. Class.level
				end
			end
			
			return "Class not found!"
		end 
	end 
})

ix.command.Add("CharClearClass", {
	description = "Clear a class slot from a character, leaving it blank.",
	privilege = "Manage Character Attributes",
	adminOnly = true,
	arguments = {
		ix.type.character,
		ix.type.number
	},
	OnRun = function(self, client, target, slot)

		if slot ~= 1 and slot ~= 2 and slot ~= 3 then
			return "Slot must be 1, 2, or 3 for Primary, Secondary, and Tertiary class."
		end

		
		if slot == 1 then
			target:SetData("PrimaryClass", nil)
			target:SetData("ClassPoints", target:GetData("ClassPoints", 3) + 1)
			return "Primary class of " .. target:GetName() .. " has been cleared."
		end

			
		if slot == 2 then
			target:SetData("SecondaryClass", nil)
			target:SetData("ClassPoints", target:GetData("ClassPoints", 3) + 1)
			return "Secondary class of " .. target:GetName() .. " has been cleared."
		end

		if slot == 3 then
			target:SetData("TertiaryClass", nil)
			target:SetData("ClassPoints", target:GetData("ClassPoints", 3) + 1)
			return "Tertiary class of " .. target:GetName() .. " has been cleared."
		end
	end
})

ix.command.Add("CharGetClasses", {
	description = "Clear Class from a character, leaving it blank.",
	privilege = "Manage Character Attributes",
	adminOnly = true,
	arguments = {
		ix.type.character,
	},
	OnRun = function(self, client, target)

		local primary = target:GetData("PrimaryClass", "None")
		local secondary = target:GetData("SecondaryClass", {})
		local tertiary = target:GetData("TertiaryClass", {})

		
		client:Notify("Primary: " .. primary.name  .. ": " .. primary.level or 0)
		client:Notify("Secondary: " .. secondary.name .. ": " .. secondary.level or 0)
		client:Notify("Tertiary: " .. tertiary.name  .. ": " .. tertiary.level or 0)
	end
})