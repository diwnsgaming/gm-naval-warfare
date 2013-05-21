include('shared.lua')
local PixVis = nil
local matLight 		= Material( "sprites/light_ignorez" )
local matBeam		= Material( "effects/lamp_beam" )
local basePos 		= Vector(0,0,0)
ENT.RenderGroup 		= RENDERGROUP_BOTH

function ENT:Initialize()
	--PixVis = util.GetPixelVisibleHandle()
end

/*---------------------------------------------------------
   Name: DrawTranslucent
   Desc: Draw translucent
---------------------------------------------------------*/
function ENT:DrawTranslucent()
	local c = Color(255,255,255,255)
	local isconnected = self:GetNWBool("isconnected")
	if isconnected==true then c = Color(0,255,0,255) elseif isconnected==false then c = Color(255,0,0,2555) end
	local LightNrm = self:GetAngles():Up()*(-1)
	local ViewDot = EyeVector():Dot( LightNrm )
	local LightPos = basePos + LightNrm * -10

	// glow sprite

	if ( ViewDot < 0 ) then return end

	render.SetMaterial( matLight )
	local Visible	= util.PixelVisible( LightPos, 16, PixVis )
	local Size = 0.1*math.Clamp( 512 * (1 - Visible*ViewDot),128, 512 )
	c.a = 200*Visible*ViewDot

	render.DrawSprite( LightPos, Size, Size, c, Visible * ViewDot )
end
function ENT:Think()
		if PixVis==nil then
			PixVis = util.GetPixelVisibleHandle()
			basePos = ((self:GetForward()*10) + self:GetPos() - (self:GetRight()*13))
		end
		local dlight = DynamicLight( self:EntIndex() )
		if ( dlight ) then
			local LightNrm = self:GetAngles():Up()*(-1)

			dlight.Pos = basePos + LightNrm * -10
			
			local c = self:GetColor()
			dlight.r = c.r
			dlight.g = c.g
			dlight.b = c.b
			
			dlight.Brightness = 5
			dlight.Decay = 10
			dlight.Size = 10
			dlight.DieTime = CurTime() + 1
	end
end
