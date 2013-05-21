include( 'cl_alwaysdraw.lua' )
include( 'cl_animated.lua' )
include( 'cl_sometimesdraw.lua' )
include( 'cl_3d.lua' )
include( 'cl_motd.lua' )

surface.CreateFont( "HudText",
{
	font    = "DefaultBold",
	size = 25,
	weight  = 400,
	antialias = true,
	shadow = true
})
surface.CreateFont( "HudText-small",
{
	font    = "DefaultBold",
	size = 16,
	weight  = 400,
	antialias = true,
	shadow = true
})
surface.CreateFont( "HudText-noshad",
{
	font    = "DefaultBold",
	size = 25,
	weight  = 400,
	antialias = true,
	shadow = false
})
function getArc(x,y,radius,resolution,radians,rot)
	local arcVerts = {{},{}}
	for i = 1,resolution do
		arcVerts[i] = {}
		arcVerts[i]["x"] = math.sin(-i*radians/resolution + rot)*radius+x
		arcVerts[i]["y"] = math.cos(-i*radians/resolution + rot)*radius+y
		arcVerts[i]["u"] = math.sin(i*radians/resolution + rot)*0.05*radius
		arcVerts[i]["v"] = math.cos(i*radians/resolution + rot)*0.05*radius
	end
	return arcVerts
end
local clientsideplugrenders = {}
local clientsideplugrendersbitches = {}

MIDX = nil
MIDY = nil
scrWidth = -1
scrHeight = -1
ply = nil
currentClip = -1
alternateClip = -1
totalAmmo = -1
hitPoints = -1
armor = -1
stamina = -1
credits = -1
zone = -1
lastZone = -1
teamColor = Color(255, 255, 255, 255)
shouldDrawPlugs = false
oldShouldDrawPlugs = false
transOn = false
teamCol = nil
teamCol2 = nil
zoneTable = { 
	[0] =      	"Open Water",
	[1] =      	"Combine Harbor",
	[2] =      	"Rebel Harbor",
	[3] =      	"Oil Rig",
	[4] = 		"Copperhead Island"
}
zoneWidths = { 
	[0] =      	90,
	[1] =      	150,
	[2] =       100,
	[3] =      	300,
	[4] = 		200
}
zoneTimeUp= { 
	[0] =      	10,
	[1] =      	10,
	[2] =      	10,
	[3] =      	-1,
	[4] = 		10	
}
local oTeam = nil
function GM:HUDPaint()
	if ply == nil or ply:Team() != oTeam then
		ply = LocalPlayer()
		oTeam = ply:Team()
		scrWidth = surface.ScreenWidth()
		scrHeight = surface.ScreenHeight()
		MIDX = scrWidth/2
		MIDY = scrHeight/2
		transitionAmmo = 0
		transitionStamina = 0
		teamCol = team.GetColor(ply:Team())
		teamCol.a = 200
		teamCol2 = Color(teamCol.r,teamCol.g,teamCol.b,teamCol.a)
		teamCol2.r = teamCol2.r/3
		teamCol2.g = teamCol2.g/3
		teamCol2.b = teamCol2.b/3
		--[------------------------------------------------------]
		HudElementDefaults = { 
			["DefaultLowY"] 		= scrHeight*0.90,
			["DefaultHighY"] 		= 20
		}
		--[------------------------------------------------------]
		mainHudPosition = { 
			["X"]			= 20,
			["Y"]			= HudElementDefaults["DefaultLowY"]
		}
		mainHudElements = {
			["outerCircle"] = getArc(40,scrHeight-40,100,32,math.pi*0.9,math.pi*1.465),
			["innerCircle"] = getArc(40,scrHeight-40,90,32,math.pi*0.96,math.pi*1.495),
			
			["outerSquare"] = {
				{
					["x"] = 0,
					["y"] = scrHeight-60,
					["u"] = 0.5,
					["v"] = 0.5
				},
				{
					["x"] = 420,
					["y"] = scrHeight-60,
					["u"] = 1,
					["v"] = 0.5
				},
				{
					["x"] = 460,
					["y"] = scrHeight,
					["u"] = 1,
					["v"] = 1
				},
				{
					["x"] = 0,
					["y"] = scrHeight,
					["u"] = 0.5,
					["v"] = 1,
				
				}
			},

			["innerSquare"] = {
				{
					["x"] = 0,
					["y"] = scrHeight-50,
					["u"] = 0.5,
					["v"] = 0.5
				},
				{
					["x"] = 410,
					["y"] = scrHeight-50,
					["u"] = 1,
					["v"] = 0.5
				},
				{
					["x"] = 450,
					["y"] = scrHeight+10,
					["u"] = 1,
					["v"] = 1
				},
				{
					["x"] = 120,										
					["y"] = scrHeight,
					["u"] = 0.5,
					["v"] = 1,
				},
				{
					["x"] = 0,					
					["y"] = scrHeight,
					["u"] = 0.55,								
					["v"] = 0.95,
				}
			},

			["healthOutline"] = {
				{
					["x"] = 138,
					["y"] = scrHeight-45,
					["u"] = 0.5,
					["v"] = 0.5
				},
				{
					["x"] = 405,
					["y"] = scrHeight-45,
					["u"] = 1,
					["v"] = 0.5
				},
				{
					["x"] = 430,
					["y"] = scrHeight-5,
					["u"] = 1,
					["v"] = 1
				},
				{
					["x"] = 138,
					["y"] = scrHeight-5,
					["u"] = 0.5,
					["v"] = 1
				}
			},
			
			["healthBar"] = {
				{
					["x"] = 10,
					["y"] = scrHeight-40,
					["u"] = 0.5,
					["v"] = 0.5,
				},
				{
					["x"] = 292,
					["y"] = scrHeight-40,
					["u"] = 1,
					["v"] = 0.5,
				},
				{
					["x"] = 292,
					["y"] = scrHeight-10,
					["u"] = 1,
					["v"] = 1,
				},
				{
					["x"] = 10,
					["y"] = scrHeight-10,
					["u"] = 0.5,
					["v"] = 1
				}
				
			},
			
			["xMod"] = 133
			
		}
		--[------------------------------------------------------]
		creditHudPosition = { 
			["X"]			= 20,
			["Y"]			= HudElementDefaults["DefaultHighY"]+30
		}	
		creditHudElements = { 
			["X"]			= creditHudPosition["X"],
			["Y"]			= creditHudPosition["Y"],
			["TextX"] 		= creditHudPosition["X"],
			["TextY"]		= creditHudPosition["Y"]-48,
			["outerSquare"] = {
				{
					["x"] = 0,
					["y"] = 35,
					["u"] = 0.5,
					["v"] = 0.5
				},
				{
					["x"] = 390,
					["y"] = 35,
					["u"] = 1,
					["v"] = 0.5
				},
				{
					["x"] = 430,
					["y"] = 0,
					["u"] = 1,
					["v"] = 1
				},
				{
					["x"] = 0,
					["y"] = 0,
					["u"] = 0.5,
					["v"] = 1,
				
				}
			},

			["innerSquare"] = {
				{
					["x"] = 0,
					["y"] = 30,
					["u"] = 0.5,
					["v"] = 0.5
				},
				{
					["x"] = 410,
					["y"] = 30,
					["u"] = 1,
					["v"] = 0.5
				},
				{
					["x"] = 445,
					["y"] = 0,
					["u"] = 1,
					["v"] = 1
				},
				{
					["x"] = 120,										
					["y"] = 0,
					["u"] = 0.5,
					["v"] = 1,
				},
				{
					["x"] = 0,					
					["y"] =0,
					["u"] = 0.55,								
					["v"] = 0.95,
				}
			},
		}
		--[------------------------------------------------------]
		staminaHudPosition = {
			["X"]			= 20,
			["Y"]			= HudElementDefaults["DefaultLowY"]-75
		}
		staminaHudElements = { 
			["X"]			= staminaHudPosition["X"],
			["Y"]			= staminaHudPosition["Y"],
			["TextX"] 		= staminaHudPosition["X"]+10,
			["TextY"]		= staminaHudPosition["Y"]+11,
			["BoxWidth"] 	= 300,
			["BoxHeight"] 	= 50,
			["square"] = {
				{
					["x"] = 420,
					["y"] = scrHeight-60,
					["u"] = 0.5,
					["v"] = 0.5
				},
				{
					["x"] = 420,
					["y"] = scrHeight-60,
					["u"] = 1,
					["v"] = 0.5
				},
				{
					["x"] = 460,
					["y"] = scrHeight,
					["u"] = 1,
					["v"] = 1
				},
				{
					["x"] = 460,
					["y"] = scrHeight,
					["u"] = 0.5,
					["v"] = 1
				
				}
			},
			["bar"] = {
				{
					["x"] = 295,
					["y"] = scrHeight-45,
					["u"] = 0.5,
					["v"] = 0.5
				},
				{
					["x"] = 325,
					["y"] = scrHeight-45,
					["u"] = 1,
					["v"] = 0.5
				},
				{
					["x"] = 351,
					["y"] = scrHeight-5,
					["u"] = 1,
					["v"] = 1
				},
				{
					["x"] = 321,
					["y"] = scrHeight-5,
					["u"] = 0.5,
					["v"] = 1
				
				}
			},
			["stam"] = {
				{
					["x"] = 300,
					["y"] = scrHeight-40,
					["u"] = 0.5,
					["v"] = 0.5
				},
				{
					["x"] = 320,
					["y"] = scrHeight-40,
					["u"] = 1,
					["v"] = 0.5
				},
				{
					["x"] = 346,
					["y"] = scrHeight-10,
					["u"] = 1,
					["v"] = 1
				},
				{
					["x"] = 326,
					["y"] = scrHeight-10,
					["u"] = 0.5,
					["v"] = 1
				}
			}
		}
		--[------------------------------------------------------]
		clip1HudPosition = {
			["X"]			= 20,
			["Y"]			= HudElementDefaults["DefaultLowY"] + 40
		}
		clip1HudElements = { 
			["X"]			= clip1HudPosition["X"],
			["Y"]			= clip1HudPosition["Y"],
			["TextX"] 		= clip1HudPosition["X"],
			["TextY"]		= clip1HudPosition["Y"],
			["BoxWidth"] 	= 175,
			["BoxHeight"] 	= 50,
			["TextCircle"]  = getArc(45,scrHeight - 45,40, 24,math.pi*2,0)
		}
		--[------------------------------------------------------]
		clip2HudPosition = {
			["X"]			= 350,
			["Y"]			= HudElementDefaults["DefaultLowY"]-75
		}
		clip2HudElements = { 
			["X"]			= clip2HudPosition["X"],
			["Y"]			= clip2HudPosition["Y"],
			["TextX"] 		= clip2HudPosition["X"]+10,
			["TextY"]		= clip2HudPosition["Y"]+11,
			["BoxWidth"] 	= 100,
			["BoxHeight"] 	= 50
		}
		--[------------------------------------------------------]
		adminHudPosition = {
			["X"]			= mainHudPosition["X"],
			["Y"]			= mainHudPosition["Y"]
		}
		adminHudElements = { 
			["X"]			= adminHudPosition["X"],
			["Y"]			= adminHudPosition["Y"],
			["TextX"] 		= adminHudPosition["X"]+120,
			["TextY"]		= adminHudPosition["Y"]+11,
			["BoxWidth"] 	= mainHudElements["BoxWidth"],
			["BoxHeight"] 	= 50
		}
		--[------------------------------------------------------]
		TextLocationHudPosition = {
			["X"]			= scrWidth/2,
			["Y"]			= HudElementDefaults["DefaultHighY"]+30
		}
		TextLocationHudElements = { 
			["X"]			= TextLocationHudPosition["X"],
			["Y"]			= TextLocationHudPosition["Y"],
			["TextX"] 		= TextLocationHudPosition["X"]+20,
			["TextY"]		= TextLocationHudPosition["Y"]+11,
			["BoxWidth"] 	= mainHudElements["BoxWidth"],
			["BoxHeight"] 	= 50
		}
	end
	self:PaintWorldTips()
	DoHUDDecisions()
end

function hidehud(name)
	for k, v in pairs({"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", })do
		if name == v then return false end
	end
end
hook.Add("HUDShouldDraw", "navalwarfare_hidedefualthud", hidehud)

local function CreatePlugs(data)
	for k,v in pairs(clientsideplugrenders) do
		v:Remove()
	end
	clientsideplugrendersbitches = {}
	clientsideplugrenders = {}
	local orgin_ents = ents.FindInSphere(LocalPlayer():GetPos(),1208)
	for k,v in pairs(orgin_ents) do
		if v:GetClass()=="harbor_oil-small" or v:GetClass()=="harbor_oil-large" or v:GetClass() == "harbor_oiltransfer" then
			local plug = ClientsideModel("models/props_lab/tpplug.mdl", RENDERMODE_NONE)
			clientsideplugrenders[table.Count(clientsideplugrenders)+1] = plug
			plug:Spawn()
			plug:SetColor(Color(0,0,0,0))
			plug:SetPos(v:GetNWVector("connectionpoint")+v:GetPos())
			plug:SetAngles(v:GetNWAngle("connectionangle"))
			plug:SetMaterial("models/vortigaunt/pupil")
			plug.Parent = v
			plug:SetParent(v)
		end
	end
end
usermessage.Hook( "CreatePlugs", CreatePlugs);

local function DestroyPlugs(data)
	for k,v in pairs(clientsideplugrenders) do
		v:Remove()
	end
end
usermessage.Hook( "DestroyPlugs", DestroyPlugs )

local function RenderPlugs()
	effects.halo.Add(clientsideplugrenders, Color(255, 127, 0), 4, 4, 2, true, true)
end

function DoHUDDecisions()
	if ply:Alive() then
		currentClip = -1
		alternateClip = -1
		totalAmmo = -1
		hitPoints  = ply:Health()
		armor = ply:Armor()
		stamina = ply:GetNetworkedInt("stamina")
		credits = ply:GetNetworkedInt("credits")
		zone = ply:GetNetworkedInt("zone")
		teamColor = team.GetColor(ply:Team())
		adminMode = ply:GetNWBool("adminmode")
		isAFag = LocalPlayer():GetNWBool("faggot")
		shouldDrawPlugs = LocalPlayer():GetNWBool("shouldDrawPlugs")
		--Stamina--
		if(adminMode) then
			DrawAdminBox()
		else
			if(ply:WaterLevel() >= 1 || stamina!=100) then
				if transitionStamina < 1 then
					transitionStamina = transitionStamina + 0.02
					stransOn = true
				else
					stransOn = false
				end
			else
				if transitionStamina > 0 then
					transitionStamina = transitionStamina - 0.02
					stransOn = true
				else
					transitionStamina = 0
					stransOn = false
				end
			end
			if isAFag then
				navalwarfare_DrawFaggot()
			end
			DrawMainHud()
		end
		if(transitionStamina != 0) then DrawStaminaBar() end
		--ammo counter--
		local drawAmmo = false
		currentClip = -1
		totalAmmo = -1
		if(ply:GetActiveWeapon().Clip1!=nil and LocalPlayer():GetActiveWeapon():Clip1() != -1) then
			currentClip = ply:GetActiveWeapon():Clip1()
			totalAmmo = ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType())
			if(totalAmmo+currentClip+alternateClip>0) then
				drawAmmo = true
				--DrawAmmoCounter(currentClip, totalAmmo)
				if(ply:GetActiveWeapon().Clip2!=nil and LocalPlayer():GetActiveWeapon():Clip2() != -1) then
					alternateClip = ply:GetActiveWeapon():Clip2()
					if(alternateclip>0) then
						DrawAmmoCounterAlt(alternateClip)
					end
				end
			end
		end
		--zone display logic--
		if zone != lastZone then
			lastZone = zone
			local timeout = zoneTimeUp[zone]
			if timeout == -1 then
				zoneTimeOut = timeout
			else
				zoneTimeOut = zoneTimeUp[zone] + CurTime()
			end
		end
		if zoneTimeOut > CurTime() or zoneTimeOut == -1 then
			DrawTextLocation()
		end
		--always draw--
		if totalAmmo+currentClip+alternateClip>0 then
			if transitionAmmo < 1 then
				transitionAmmo = transitionAmmo + 0.02
				transOn = true
			else
				transOn = false
			end
		else
			if transitionAmmo > 0 then
				transitionAmmo = transitionAmmo - 0.02
				transOn = true
			else
				transitionAmmo = 0
				transOn = false
			end
		end
		if drawAmmo or transitionAmmo != 0 then
			DrawAmmoCounter(currentClip, totalAmmo)
		end
	
		DrawCreditCounter()
		DrawPlayerNames()
		RenderPlugs()
		DoHealthMeter()
		DrawCompass()
	end
end

function GM:RenderScreenspaceEffects()
	if LocalPlayer():GetNWBool("adminmode") then
		DrawMaterialOverlay("effects/combine_binocoverlay.vmt", 0.1)
	end
	DrawMaterialOverlay("", 0.1)
	render.UpdateScreenEffectTexture()
end