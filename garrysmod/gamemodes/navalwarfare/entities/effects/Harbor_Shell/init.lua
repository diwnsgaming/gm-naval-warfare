   
function EFFECT:Init( data )

	self.Index = data:GetAttachment()
	self:SetModel("models/munitions/round_100mm_shot.mdl") 
	self.Caliber = 203
	self.CreateTime = CurTime()
end

function EFFECT:Think()
end 

function EFFECT:Render()  
	self.Entity:SetModelScale( self.Caliber/10 , 0 )
	self.Entity:DrawModel()       // Draw the model. 
end 