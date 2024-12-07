hook.Add("CreateCharacterInfo", "ClassCharacterInfo", function( PANEL )
	local character = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()

	if character:GetData("PrimaryClass") then 
		PANEL.primaryclass = PANEL:Add("ixListRow")
		PANEL.primaryclass:SetList(PANEL.list)
		PANEL.primaryclass:Dock(TOP)
	end 

	if character:GetData("SecondaryClass") then 
		PANEL.secondaryclass = PANEL:Add("ixListRow")
		PANEL.secondaryclass:SetList(PANEL.list)
		PANEL.secondaryclass:Dock(TOP)
	end 

	if character:GetData("TertiaryClass") then 
		PANEL.tertiaryclass = PANEL:Add("ixListRow")
		PANEL.tertiaryclass:SetList(PANEL.list)
		PANEL.tertiaryclass:Dock(TOP)
	end 
end)

hook.Add("UpdateCharacterInfo", "UpdateClassInfo", function( PANEL, character )
	
	if character:GetData("PrimaryClass") then 
		local classinfo = character:GetData("PrimaryClass")
		PANEL.primaryclass:SetLabelText(L("Primary Class"))
		PANEL.primaryclass:SetText((classinfo.name .. " - Level " .. classinfo.level))
		PANEL.primaryclass:SizeToContents()
	end

	if character:GetData("SecondaryClass") then 
		local classinfo = character:GetData("SecondaryClass")
		PANEL.secondaryclass:SetLabelText(L("Secondary Class"))
		PANEL.secondaryclass:SetText((classinfo.name .. " - Level " .. classinfo.level))
		PANEL.secondaryclass:SizeToContents()
	end

	if character:GetData("TertiaryClass") then 
		local classinfo = character:GetData("TertiaryClass")
		PANEL.tertiaryclass:SetLabelText(L("Tertiary Class"))
		PANEL.tertiaryclass:SetText((classinfo.name .. " - Level " .. classinfo.level))
		PANEL.tertiaryclass:SizeToContents()
	end





end)


