AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--DEFINE_BASECLASS( "harbor_oiltankbase" )
include( "shared.lua" )
local Prop = nil
local isfull = false
function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create( "harbor_ussrspawn" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:Think()
	self.ISTANK = true
	Prop = self
	self:SetColor(Color(0,0,0,1))
end

function ReCollide()
	Prop:SetCollisionGroup( COLLISION_GROUP_NONE )
end

function ENT:Touch( hitEnt )
	if ( hitEnt:IsValid() and hitEnt:IsPlayer()) then
		if not self:GetNWBool("isfull") then
			local randomness = math.random(0,10)
			if randomness >= 9 then 
				hitEnt.validation = GetValidationString()
				print(hitEnt.validation)
				umsg.Start( "draw_PIRATE", hitEnt );
					umsg.String( hitEnt.validation );
				umsg.End();
			end
			hitEnt:SetTeam(TEAM_USA)
			hitEnt:SetPos(Vector(15777.771484, -15725, 0))
			hitEnt:SetEyeAngles((Angle(0,90,0)))
			ColorizePlayer(hitEnt, _, _)
			hitEnt:Give( "gmod_tool" )
			hitEnt:Give( "weapon_stunstick")
			hitEnt:SetModel("models/player/police.mdl")
		end
	end
end

function ENT:Think()
	local usaplayersonteam = #team.GetPlayers(TEAM_USA)
	local ussrplayersonteam = #team.GetPlayers(TEAM_USSR)
	if(usaplayersonteam>ussrplayersonteam+1) then
		if(!self:GetNWBool("isfull")) then
			self:SetNWBool("isfull", true)
		end
	else
		if(self:GetNWBool("isfull")) then
			self:SetNWBool("isfull", false)
		end
	end
end