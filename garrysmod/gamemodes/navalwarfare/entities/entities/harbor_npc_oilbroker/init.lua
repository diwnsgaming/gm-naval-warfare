AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
 
local schdChase = ai_schedule.New( SCHED_IDLE_STAND )


function ENT:Initialize()
	self:SetModel( "models/Humans/Group01/Female_01.mdl" )
	self:SetHullType( HULL_HUMAN );
	self:SetHullSizeNormal();
 
	self:SetSolid( SOLID_BBOX ) 
	self:SetMoveType( MOVETYPE_STEP )
 
	self:CapabilitiesAdd(  CAP_ANIMATEDFACE )
	self:CapabilitiesAdd(  CAP_TURN_HEAD )
	self:SetUseType(SIMPLE_USE)
	self:SetMaxYawSpeed( 5000 )
	//don't touch stuff above here
	self:SetHealth(100000000000000)
	
	local ent = ents.Create("harbor_rotatingtext") -- This creates our zombie entity
	ent:SetPos(self:GetPos()+Vector(0,0,85)) -- This positions the zombie at the place our trace hit.
	ent:SetAngles(Angle(0,0,0))
	ent:Spawn()
	ent:ChangeText("Oil Broker", "Press Use")
end

local randomCharSet = {"q", "w", "e", "r", "t", "y", "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "z", "x", "c", "v", "b", "n", "m", ",", ".", ";", "'", "[", "]", "}", "{", ">", "?", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "_", "=", "+", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S ", "D", "F", "G", "H", "J", "K", "L", "Z", "X", "C", "V", "B", "N", "M", "`", "~"}
 
function string.random(Length)
   -- Length (number)
   -- CharSet (string, optional); e.g. %l%d for lower case letters and digits

   local CharSet = CharSet or '.'

   if CharSet == '' then
      return ''
   else
      local Result = {}
      local Lookup = randomCharSet
	  local Range = #Lookup

      for Loop = 1,Length do
         Result[Loop] = Lookup[math.floor(math.random(1, Range))]
      end

      return table.concat(Result)
   end
end

function GetValidationString()
	return string.random(16)
end	
function ENT:AcceptInput(Name, Activator, Called)
	if(Name=="Use" and Activator.isAtHome) then
		local oil = 0
		local home = USSRPos
		if Activator:Team() == TEAM_USA then
			home = USAPos
		end
		local barrels = ents.FindByClass("harbor_oil-*");
		local inRangeBarrels = {}
		if barrels != nil then
			
			for k,v in pairs(barrels) do
				if v.Owner == Activator and (v:GetPos()-home):LengthSqr() < 21160000 then
					table.insert(inRangeBarrels,v)
				end
			end
		end
		Activator.validation = GetValidationString()
		umsg.Start("oilbrokermainmenu", Activator)
			for k,v in pairs(inRangeBarrels) do
				umsg.Short(v:EntIndex())
				umsg.Float(v.Oil)
			end
			umsg.Short(-1)
			umsg.String(Activator.validation)--need to send back a string
			--cannot do Client -> server umsgs, so we need use concommands
			--we will generate a random string, send it in the user message
			--and then send it back in the convar
			--if they match, validate the request (sell oil in this case)
		umsg.End()
	end
end
function ENT:OnTakeDamage(dmg)
	dmg:SetDamageType(DMG_GENERIC)
	dmg:ScaleDamage(0)
	dmg:SetDamage(0)
	self:SetHealth(1000000000000000)
	if self:Health() <= 0 then //run on death
		self:SetSchedule( SCHED_FALL_TO_GROUND ) //because it's given a new schedule, the old one will end.
	end
	return dmg
end 
 
 
/*---------------------------------------------------------
   Name: SelectSchedule
---------------------------------------------------------*/
function ENT:SelectSchedule()
	self:SetSchedule( SCHED_IDLE_STAND ) //run the schedule we created earlier
end



