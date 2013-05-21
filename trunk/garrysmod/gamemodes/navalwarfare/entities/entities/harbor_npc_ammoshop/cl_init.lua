include('shared.lua')
 
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Draw()
	self:DrawModel()
	--spin(self)
end

function ENT:DrawTranslucent()
	self:Draw()
	--spin(self)
end
 
function ENT:BuildBonePositions( NumBones, NumPhysBones )

end

function ENT:SetRagdollBones( bIn )
	self.m_bRagdollSetup = bIn
end

function ENT:DoRagdollBone( PhysBoneNum, BoneNum )
	//self:SetBonePosition( BoneNum, Pos, Angle )
end