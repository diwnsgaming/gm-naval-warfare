ENT.Type            = "anim"
ENT.Base 	    = "base_gmodentity"

ENT.PrintName       = "Propeller"
ENT.Author          = "Bzaraticus"
ENT.Contact         = ""
ENT.Purpose         = ""
ENT.Instructions    = ""

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

function ENT:SetOffset( v )
	self.Entity:SetNetworkedVector( "Offset", v, true )
end
function ENT:GetOffset( name )
	return self.Entity:GetNetworkedVector( "Offset" )
end


function ENT:NetSetForce( force )
	self.Entity:SetNetworkedInt(4, math.floor(force*100))
end
function ENT:NetGetForce()
	return self.Entity:GetNetworkedInt(4)/100
end


local Limit = .1
local LastTime = 0
local LastTimeA = 0

function ENT:GetOverlayText()
	local force = self:NetGetForce()
	local txt = "Thrust = "
	if (math.abs(self:NetGetForce()) < 10 ) then
		txt = txt .. "Off"
	else
		txt = txt .. math.Round( force * -1 )
	end
	local PlayerName = self:GetPlayerName()
	-- if (not SinglePlayer()) then
		-- txt = txt .. "\n(" .. PlayerName .. ")"
	-- end
	if(PlayerName and PlayerName ~= "") then
		if (txt == "") then
			return "- "..PlayerName.." -"
		end
		return "- "..PlayerName.." -\n"..txt
	end
	return txt
end