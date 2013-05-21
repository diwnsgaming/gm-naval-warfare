AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
 
local schdChase = ai_schedule.New( SCHED_IDLE_STAND )


--[[
UPGRADE FORMAT
Upgrades[n] = 
	{Name of upgrade, Description, Player Attribute value being changed,
		FUNCTION TO DETERMINE PRICE
		end
		,
		FUNCTION TO DETERMINE LIMIT/CAN SPAWN/WHATTHEFUCKEVER FOR THAT PLAYER
			Currently only using this one for limits.  I'm sure we'll find another use eventually, so I'm leaving it as a function
		end
	}
--]]
Upgrades = {}
Upgrades[1] =
	{"Max Barrels", "Increase the maximum number of oil tanks you are allowed to own","barrel_limmit", 
		function(ply)
			return (ply.attr["barrel_limmit"])*0.5*6000
		end,
		function(ply)
			if ply.attr["barrel_limmit"] >= 10 then
				return false
			end
			return true
		end
	}
	
Upgrades[2] = 
	{"Merchant Level", "Allows you to use higher capacity oil tanks, there is currently no benefit for merchant level 2.  At 3, you can spawn Large Tanks.", "merch_level",
		function(ply)
			return 10000*ply.attr["merch_level"]
		end,
		function(ply)
			if ply.attr["merch_level"] >= 3 then
				return false
			end
			return true
		end
	}

Upgrades[3] =
	{"Oil Speed", "Increase the speed of oil pumps by 5%","oil_speed", 
		function(ply)
			return (ply.attr["oil_speed"]+1)^2*1000
		end,
		function(ply)
			if ply.attr["oil_speed"] >= 40 then
				return false
			end
			return true
		end
	}
function ENT:Initialize()
	self:SetModel( "models/gman_high.mdl" )
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
	for k,v in pairs(Upgrades) do
		self:SetNWString(k.."name",v[1])
		self:SetNWString(k.."desc",v[2])
		self:SetNWString(k.."type",v[3])
	end
	
	local ent = ents.Create("harbor_rotatingtext") -- This creates our zombie entity
	ent:SetPos(self:GetPos()+Vector(0,0,85)) -- This positions the zombie at the place our trace hit.
	ent:SetAngles(Angle(0,0,0))
	ent:Spawn()
	ent:ChangeText("Upgrade Shop", "Press Use")
	self:SetNWInt("numUpgrades",#Upgrades)

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
function SendUpgrades(self,Activator)
	Activator.validation = GetValidationString()
	umsg.Start("upgradeshopmainmenu", Activator)
		umsg.Entity(self)
		for k,v in pairs(Upgrades) do
			umsg.Float(v[4](Activator))
			umsg.Bool(v[5](Activator))
		end
		umsg.String(Activator.validation)--need to send back a string
		--cannot do Client -> server umsgs, so we need use concommands
		--we will generate a random string, send it in the user message
		--and then send it back in the convar
		--if they match, validate the request
	umsg.End()
end
function ENT:AcceptInput(Name, Activator, Called)
	if(Name=="Use" and Activator.isAtHome) then	
		SendUpgrades(self,Activator)		
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



