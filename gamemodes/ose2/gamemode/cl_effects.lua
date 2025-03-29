--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]
local physgun_halo = CreateConVar(
	"physgun_halo",
	"1",
	FCVAR_ARCHIVE,
	"Draw the Physics Gun grab effect?"
)

local PhysgunHalos = {}

--[[---------------------------------------------------------
	Name: gamemode:DrawPhysgunBeam()
	Desc: Return false to override completely
-----------------------------------------------------------]]
function GM:DrawPhysgunBeam(ply, weapon, bOn, target, boneid, pos)
	if not physgun_halo:GetBool() then
		return true
	end

	if IsValid(target) then
		PhysgunHalos[ply] = target
	end

	return true
end

hook.Add("PreDrawHalos", "AddPhysgunHalos", function()
	if not PhysgunHalos or table.IsEmpty(PhysgunHalos) then
		return
	end

	for ply, ent in pairs(PhysgunHalos) do
		if IsValid(ply) then
			local size = math.random(1, 2)
			local colr = ply:GetWeaponColor() + VectorRand() * 0.3

			halo.Add(PhysgunHalos, Color(colr.x * 255, colr.y * 255, colr.z * 255), size, size, 1, true, false)
		end
	end

	PhysgunHalos = {}
end)


--[[---------------------------------------------------------
	Name: gamemode:NetworkEntityCreated()
	Desc: Entity is created over the network
-----------------------------------------------------------]]
function GM:NetworkEntityCreated(ent)
	--
	-- If the entity wants to use a spawn effect
	-- then create a propspawn effect if the entity was
	-- created within the last second (this function gets called
	-- on every entity when joining a server)
	--

	if ent:GetSpawnEffect() and ent:GetCreationTime() > (CurTime() - 1.0) then
		local ed = EffectData()
		ed:SetOrigin(ent:GetPos())
		ed:SetEntity(ent)
		util.Effect("propspawn", ed, true, true)
	end
end
