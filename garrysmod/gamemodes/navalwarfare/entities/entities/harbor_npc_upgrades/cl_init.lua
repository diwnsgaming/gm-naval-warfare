include('shared.lua')
 
ENT.RenderGroup = RENDERGROUP_BOTH

local menuIsOpen = false

function ENT:Draw()
	self:DrawModel()

end
function ENT:DrawTranslucent()
	self:Draw()
end
 
function ENT:BuildBonePositions( NumBones, NumPhysBones )

end

function ENT:SetRagdollBones( bIn )
	self.m_bRagdollSetup = bIn
end

function ENT:DoRagdollBone( PhysBoneNum, BoneNum )
	//self:SetBonePosition( BoneNum, Pos, Angle )
end