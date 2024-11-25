PLUGIN.name = "Attributes"
PLUGIN.author = "Scrat Knapp"
PLUGIN.desc = "RPG Attributes"

ix.config.Add("attributeStartingPoints", 15, "The amount of attribute points a new character can distibute upon creation.", nil, {
	data = {min = 1, max = 100},
	category = "Characters"
})

ix.command.Add("CharShowAttribs", {
	description = "List the perks the given character currently has.",
	privilege = "Manage Character Attributes",
	adminOnly = true,
	arguments = {
		ix.type.character
	},

	OnRun = function(self, client, target)

		local str = "Attributes for " .. target:GetName() .. ":\n"
	
		for id, attribute in pairs(ix.attributes.list) do
			str = str .. attribute.name .. ": " .. target:GetAttribute(id) .. "\n"
		end

		
		return str
	end 
	})
