local PLUGIN = PLUGIN or {}
PLUGIN.name = "Infomation Markers"
PLUGIN.author = "Cosmos"
PLUGIN.description = "Adds a command to make environmental infomation markers."
ix.flag.Add("M", "Flag for permitting a character to create infomarkers.")
ix.command.Add("Infomarker", {
  description = "Creates an environmental infomation marker",
  adminOnly = true,
  OnRun = function(self, client, command)
    if client:GetCharacter():HasFlags("M") then
      local trace1 = client:GetEyeTrace()
      local pos_hit = trace1.HitPos
      local markerent = ents.Create("marker")
      markerent:SetPos(pos_hit)
      markerent:Spawn()
      markerent:SetOwner(client)
      client:Notify("Infomarker Created Successfully.")
    else
      client:Notify("You do not have permission to use this.")
    end
  end
})
