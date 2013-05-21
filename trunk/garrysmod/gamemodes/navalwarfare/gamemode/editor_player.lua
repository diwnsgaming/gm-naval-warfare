
AddCSLuaFile()

list.Set( "DesktopWindows", "PlayerEditor",
{
	title		= "Player Model",
	icon		= "icon64/playermodel.png",
	width		= 960,
	height		= 700,
	onewindow	= true,
	init		= function( icon, window )

		local mdl = window:Add( "DModelPanel" )
			mdl:Dock( FILL )
			mdl:SetFOV(45)
			mdl:SetCamPos(Vector(90,0,60))

		local sheet = window:Add( "DPropertySheet" )
			sheet:Dock( RIGHT )
			sheet:SetSize( 370, 0 )

			local PanelSelect = sheet:Add( "DPanelSelect" )
	
				for name, model in SortedPairs( list.Get( "PlayerOptionsModel" ) ) do
	
					local icon = vgui.Create( "SpawnIcon" )
					icon:SetModel( model )
					icon:SetSize( 64, 64 )
					icon:SetTooltip( name )
		
					PanelSelect:AddPanel( icon, { cl_playermodel = name } )
	
				end

		sheet:AddSheet( "Model", PanelSelect )

		local controls = window:Add( "DPanel" )
			controls:DockPadding( 8, 8, 8, 8 )

		local lbl = controls:Add( "DLabel" )
			lbl:SetText( "Player Color: UNAVAILIBLE" )
			lbl:SetTextColor( Color( 0, 0, 0, 255 ) )
			lbl:Dock( TOP )

		--local plycol = controls:Add( "DColorMixer" )
			-- plycol:SetAlphaBar( false )
			-- plycol:SetPalette( false )
			-- plycol:Dock( TOP )
			-- plycol:SetSize( 200, 250 )
			

		local lbl = controls:Add( "DLabel" )
			lbl:SetText( "Weapon Color:" )
			lbl:SetTextColor( Color( 0, 0, 0, 255 ) )
			lbl:DockMargin( 0, 32, 0, 0 )
			lbl:Dock( TOP )

		local wepcol = controls:Add( "DColorMixer" )
			wepcol:SetAlphaBar( false )
			wepcol:SetPalette( false )
			wepcol:Dock( TOP )
			wepcol:SetSize( 200, 250 )
			wepcol:SetVector( Vector( GetConVarString( "cl_weaponcolor" ) ) );
			
		sheet:AddSheet( "Colors", controls )

		local function UpdateFromConvars()

			local modelname = player_manager.TranslatePlayerModel( LocalPlayer():GetInfo( "cl_playermodel" ) )
			util.PrecacheModel( modelname )
			mdl:SetModel( modelname )
			mdl.Entity.GetPlayerColor = function() return Vector( GetConVarString( "cl_playercolor" ) ) end

			--plycol:SetVector( Vector( GetConVarString( "cl_playercolor" ) ) );
			wepcol:SetVector( Vector( GetConVarString( "cl_weaponcolor" ) ) );

		end
			
		local function UpdateFromControls()

			--RunConsoleCommand( "cl_playercolor", tostring( plycol:GetVector() ) )
			RunConsoleCommand( "cl_weaponcolor", tostring( wepcol:GetVector() ) )

		end

		UpdateFromConvars();

		--plycol.ValueChanged					= UpdateFromControls
		wepcol.ValueChanged					= UpdateFromControls
		PanelSelect.OnActivePanelChanged	= function() timer.Simple( 0.1, UpdateFromConvars ) end

	end
} )

