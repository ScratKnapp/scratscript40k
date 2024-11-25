--  ___                     
-- / __|___ ____ __  ___ ___
-- | (__/ _ (_-< '  \/ _ (_-<
-- \___\___/__/_|_|_\___/__/


AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )  
include( "shared.lua" )

util.AddNetworkString("markartextchange")
util.AddNetworkString("markercolor")
util.AddNetworkString("markarmenu")
util.AddNetworkString("deletemarker")

net.Receive("markartextchange", function(len, ply)
    local sign = net.ReadEntity()
    local newText = net.ReadString()
    sign:SetRPText(newText)
end)


net.Receive("markercolor", function(len, ply)
  local signcolor = net.ReadEntity()
  local newcolor = net.ReadColor()
  local newvectorstore = newcolor:ToVector()
  signcolor:Setrpcolor(newvectorstore)
end)


function ENT:Initialize()
    self:SetRenderMode(RENDERMODE_TRANSALPHA)
    self:DrawShadow(false)
    self:SetModel("models/squad/sf_plates/sf_plate1x1.mdl")
    self:SetMaterial("models/effects/vol_light001")
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetRPText("EDIT ME")
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end
end


net.Receive("deletemarker", function()
  local markerent = net.ReadEntity()
  markerent:Remove()
end)


