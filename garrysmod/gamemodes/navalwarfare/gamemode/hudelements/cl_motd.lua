function DrawRULES( um )
	local MOTDFrame = vgui.Create( "DFrame" )
	MOTDFrame:SetTitle( "Rules, Regulations, and Tips" )
	MOTDFrame:SetSize( 800, surface.ScreenHeight()/10*9)
	MOTDFrame:ShowCloseButton( false )
	MOTDFrame:Center()
	
	MOTDFrame:SetBackgroundBlur( true )
	MOTDFrame:MakePopup()
	 
	local MOTDHTMLFrame = vgui.Create( "HTML", MOTDFrame )
	MOTDHTMLFrame:SetPos( 25, 25 )
	MOTDHTMLFrame:SetSize( MOTDFrame:GetWide() - 50, MOTDFrame:GetTall() - 64 )
	local html = 
	"<style type='text/css'>"..
		"p{"..
			"text-align:center;"..
		"}"..
		"h1{"..
			"text-align:center;"..
		"}"..	
	"</style>"..
	"<div style='background:white;overflow:auto;'>"..
		"<h1>Rules and Ship Building Regulations</h1>"..
		"<p>"..
			"<h2>Strick Rules:</h2> <br />"..
				"No sailing into enemy harbors<br />"..
				"No prop killing in harbors<br />"..
				"No minging<br />"..
				"Admins are always right where rules are not implicit. NOTE: Report abusive admins to SuperAdmins<br />"..
			"<br />"..
			"<h2>Rules:</h2><br />"..
				"Don't try to exploit the system, everybody should have a fair chance<br />"..
				"Make sure to use the ship designation tool on your ship before you leave the harbor!<br />"..
				"Using the ship designation tool allows admins and players to know you are not overstacking your ship<br />"..
				"Doing so will avoid quite a lot of trouble<br />"..
				"Raiding harbors is okay as long as it is in moderation. One raiding party of a few people is fine, but the whole team or continuous or large raiding parties are forbidden.<br />"..
				"Admins have final say on what makes raiding parties acceptable.<br />"..
			"<br />"..
			"<br />"..
			"<br />"..
			"<h2>Regulations:</h2><br />"..
				"Each type of boat has certain limmits placed apon it so that gameplay remains ballanced.<br />"..
				"Limmits are placed apon speed, oil tank capacity, and equiptable guns.<br />"..
				"Using the ship designation tool on your ship will let other players and admins know what class of ship you are sailing.<br />"..
				"The ship designations, limmits, and max speeds are as follows:<br />"..
					"<br />"..
					"<h4>Boat: 20k/h</h4> <br />"..
					"Any amount of small oil drums<br />"..
					"One machinegun and one cannon<br />"..
					"<br />"..
					"<h4>Speedboat: 40k/h</h4> <br />"..
					"One small oil drum<br />"..
					"one machinegun or pulse weapon<br />"..
					"<br />"..
					"<h4>Tanker: 15k/h</h4> <br />"..
					"Any amount of oil drum<br />"..
					"One cannon and three machineguns<br />"..
					"<br />"..
					"<h4>WarShip: 15k/h</h4><br />"..
					"No oiltanks<br />"..
					"As many guns as you can afford<br />"..
					"<br />"..
					"<h4>Submarine: 35k/h</h4><br />"..
					"Four small oil drums<br />"..
					"up to two torpedos and one machinegun or pulse weapon<br />"..
					"<br />"..
					"<h4>Airplane: 50k/h</h4><br />"..
					"This must recieve it's lift from a fin'd prop (wing)<br />"..
					"This must NOT be able to stop in the air<br />"..
					"One small oiltank<br />"..
					"Two machineguns or pulse weapons<br />"..
					"<br />"..
					"<h4>Blimp: 15k/h</h4><br />"..
					"This must recieve it's lift from balloons<br />"..
					"One large oil drum or four small oil drums<br />"..
					"One machinegun/pulse weapon OR cannon<br />"..
		"</p>"..
	"</div>"
	
	MOTDHTMLFrame:SetHTML( html )
	local CloseButton = vgui.Create( "DButton" )
	CloseButton:SetParent( MOTDFrame )
	CloseButton:SetText( "Click here to close")
	CloseButton:SetPos( MOTDFrame:GetWide()/2 - 100, MOTDFrame:GetTall() - 45 )
	CloseButton:SetSize( 200, 40 )
	CloseButton.DoClick = function ()
			MOTDFrame:Close()
	end
end
usermessage.Hook("draw_RULES", DrawRULES)

function DrawMOTD( um )
	local MOTDFrame = vgui.Create( "DFrame" )
	MOTDFrame:SetTitle( "Message of The day" )
	MOTDFrame:SetSize( 800, surface.ScreenHeight()/10*9)
	MOTDFrame:ShowCloseButton( false )
	MOTDFrame:Center()
	
	MOTDFrame:SetBackgroundBlur( true )
	MOTDFrame:MakePopup()
	 
	local MOTDHTMLFrame = vgui.Create( "HTML", MOTDFrame )
	MOTDHTMLFrame:SetPos( 25, 25 )
	MOTDHTMLFrame:SetSize( MOTDFrame:GetWide() - 50, MOTDFrame:GetTall() - 64 )
	local html = 
	"<style type='text/css'>"..
		"p{"..
			"text-align:center;"..
		"}"..
		"h1{"..
			"text-align:center;"..
		"}"..	
	"</style>"..
	"<div style='background:white;overflow:auto;'>"..
		"<h1>Welcome to Naval Warfare 1.1</h1>"..
		"<p>"..
			"This is a free to play/host version of a gamemode called \"Naval Play\"<br />"..
			"<br />"..
			"Objective:<br />"..
			"There are two objectives somewhere on the map to be fought over,<br />"..
			"Holding these places will offer a resource advantage over the other team.<br /><br />"..

			"Oil Platform:<br />"..
			"This raised platform provides oil to the team that captures it, oil barrels brought<br />"..
			"here can be filled and brought home for a profit.<br />"..
			"Beware, the other team will try to take the platform from you.<br /><br />"..

			"Copperhead Island:<br />"..
			"Holding control of this island will boost your team's periodic income.<br />"..
			"This feature may be removed in the beta.<br /><br />"..

			"Your Harbor:<br />"..
			"Upon joining a team you will be assigned a Harbor.<br />"..
			"This is a safe place for anybody on your team to build, purchase upgrades, and sell oil.<br />"..
			"You will not be safe in your enemy's harbor.  <br />"..
			"If you joined the wrong harbor by mistake, simply rejoin and you can choose the other harbor.<br /><br />"..

			"Stamina:<br />"..
			"Remember, outside your harbor you are not safe in the water.<br />"..
			"Your stamina will gradually drain if you are in the water.<br />"..
			"Going under water will cause it to drain faster.<br />"..
			"Sprinting will also consume stamina.<br />"..
			"If your stamina reaches zero while in the water, you will begin to drown.<br /><br />"..
			"<br /><hr /><br />"..
			"<div style='margin-left:5px;float:left;width:50%;'>"..
				"This Server uses:<br />"..
				"Wiremod: https://github.com/wiremod/wire<br />"..
				"UWSVN: https://github.com/wiremod/wire-extras<br />"..
																									"</p>"..
																								"</div>"
	
	MOTDHTMLFrame:SetHTML( html )
	local CloseButton = vgui.Create( "DButton" )
	CloseButton:SetParent( MOTDFrame )

	local timeLeft = 15
	local canClose = um:ReadBool()
	--print(canClose)
	if not canClose then
		CloseButton:SetText( "Close in "..timeLeft )
		timer.Create("navalwarfare_canclose",1,timeLeft,function() 
			timeLeft = timeLeft - 1
			local closeText = "Close in "..timeLeft
			if timeLeft == 0 then
				canClose = true
				closeText = "Click here to close"
			end	
			CloseButton:SetText( closeText )				
		end)
	else
		CloseButton:SetText( "Click here to close")
	end
	CloseButton:SetPos( MOTDFrame:GetWide()/2 - 100, MOTDFrame:GetTall() - 45 )
	CloseButton:SetSize( 200, 40 )
	CloseButton.DoClick = function ()
		if canClose then
			MOTDFrame:Close()
		end
	end
end
usermessage.Hook("draw_MOTD", DrawMOTD)

function DrawPirate( um )
	local MOTDFrame = vgui.Create( "DFrame" )
	MOTDFrame:SetTitle( "Message of The day" )
	MOTDFrame:SetSize( 800, surface.ScreenHeight()/10*9)
	MOTDFrame:ShowCloseButton( false )
	MOTDFrame:Center()
	
	MOTDFrame:SetBackgroundBlur( true )
	MOTDFrame:MakePopup()
	 
	local MOTDHTMLFrame = vgui.Create( "HTML", MOTDFrame )
	MOTDHTMLFrame:SetPos( 25, 25 )
	MOTDHTMLFrame:SetSize( MOTDFrame:GetWide() - 50, MOTDFrame:GetTall() - 64 )
	local html = 
	"<style type='text/css'>"..
		"p{"..
			"text-align:center;"..		
		"}"..
		"h1{"..
			"text-align:center;"..
		"}"..	
	"</style>"..
	"<div style='background:white;overflow:auto;height:100%;'>"..
		"<h1>Welcome to Naval Warfare Alpha 0.1</h1>"..
		"<p>"..
			"YOU ARE A PIRATE<br />"..
			"YAR HAR DIDDLY DEE<br />"..
			"Your mission, should you choose to accept:<br />"..
			"Blow up the enemy ships and kill thier crew!<br />"..
			"You will be rewarded by a 100x multiplier tward ship destruction.<br />"..
		"</p>"..
	"</div>"
	
	MOTDHTMLFrame:SetHTML( html )
	
	local AcceptButton = vgui.Create( "DButton" )
	AcceptButton:SetParent( MOTDFrame )
	AcceptButton:SetText( "ACCEPT PIRACY" )
	AcceptButton:SetPos( MOTDFrame:GetWide()/3 - 100, MOTDFrame:GetTall() - 45 )
	AcceptButton:SetSize( 200, 40 )
	local s =  um:ReadString()
	AcceptButton.DoClick = function ()
		MOTDFrame:Close()
		RunConsoleCommand("navalwarfare_beapirate", s) -- FIX ME
	end
	
	local CloseButton = vgui.Create( "DButton" )
	CloseButton:SetParent( MOTDFrame )
	CloseButton:SetText( "DECLINE PIRACY" )
	CloseButton:SetPos( MOTDFrame:GetWide()/2, MOTDFrame:GetTall() - 45 )
	CloseButton:SetSize( 200, 40 )
	local s =  um:ReadString()
	CloseButton.DoClick = function ()
		MOTDFrame:Close()
	end
end
usermessage.Hook("draw_PIRATE", DrawPirate)