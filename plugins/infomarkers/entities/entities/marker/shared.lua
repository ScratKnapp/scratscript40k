--  ___                     
-- / __|___ ____ __  ___ ___
-- | (__/ _ (_-< '  \/ _ (_-<
-- \___\___/__/_|_|_\___/__/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Marker"
ENT.Author = "Cosmos"
ENT.Category = "Helix"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:Use(activator, caller)
	if activator == self:GetOwner() then
    net.Start("markarmenu")
        net.WriteEntity(self)
    net.Send(activator)
end
end

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "RPText")
	self:NetworkVar("Vector", 0, "rpcolor")
end