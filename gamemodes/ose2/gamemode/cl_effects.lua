--[[
 Copyright (C) 2025 Lexi Robinson

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as
 published by the Free Software Foundation, either version 3 of the
 License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License for more details.

 You should have received a copy of the GNU Affero General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
