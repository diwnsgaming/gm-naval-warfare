AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )
function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	local ent = ents.Create( "harbor_rotatingtext" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end
function ENT:Initialize()
	self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self.text1 = "Incorrect Initialization"
	self.text2 = "You're doing it wrong"
	self:SetNWString("text1",self.text1)
	self:SetNWString("text2",self.text2)
end
function ENT:ChangeText( text1, text2 )
	self:SetNWString("text1",text1)
	self:SetNWString("text2",text2)
	return true
end
