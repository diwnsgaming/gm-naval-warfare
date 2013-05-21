ENT.Base 		= "base_ai"
ENT.Type 		= "ai"

ENT.PrintName	= "Harbor_OilBroker"
ENT.Author		= "SERVER"
ENT.Contact		= "N/A"
ENT.Purpose		= "Tester"
ENT.Instructions= ""

ENT.AutomaticFrameAdvance = true

function ENT:OnRemove()
end

function ENT:PhysicsCollide( data, physobj )
end

function ENT:PhysicsUpdate( physobj )
end

function ENT:SetAutomaticFrameAdvance( bUsingAnim )
	self.AutomaticFrameAdvance = bUsingAnim
end