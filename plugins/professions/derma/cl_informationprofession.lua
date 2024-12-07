hook.Add("CreateCharacterInfo", "ProfessionCharacterInfo", function( PANEL )
	local character = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()

	PANEL.profession = PANEL:Add("ixListRow")
	PANEL.profession:SetList(PANEL.list)
	PANEL.profession:Dock(TOP)
end)

hook.Add("UpdateCharacterInfo", "UpdateProfessionInfo", function( PANEL, character )
	PANEL.profession:SetLabelText(L("Profession"))
	PANEL.profession:SetText((character:GetProfessionName()))
	PANEL.profession:SizeToContents()
end)


