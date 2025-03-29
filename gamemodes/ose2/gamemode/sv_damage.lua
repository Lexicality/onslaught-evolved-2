--[[
 Copyright (c) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

GM.m_DamageScale = 1
GM.m_NextDamageCalc = 0

function GM:EntityTakeDamage(target, dmg)
	local now = CurTime()
	if self.m_NextDamageCalc <= now then
		self.m_NextDamageCalc = now + 2
		-- Once again, a mystery equation from the 1.9 codebase
		self.m_DamageScale = math.sqrt(player.GetCount()) + 0.01
	end

	-- mines, turrets etc
	local attacker = dmg:GetAttacker()
	if IsValid(attacker) and not attacker:IsPlayer() then
		local ply = attacker:GetCreator()
		if IsValid(ply) then
			-- Normally the `combine_mine` does the damage using an `env_explosion`
			-- but we'd like the player to do the damage using the mine
			if attacker:GetClass() == "combine_mine" then
				dmg:SetInflictor(attacker)
			end
			dmg:SetAttacker(ply)
			-- Ensure mine/turret damage scales too!
			if target:IsNPC() then
				dmg:AdjustPlayerDamageInflictedForSkillLevel()
			end
		end
	end

	local class = target:GetClass()
	-- For turrets, redirect damage to their prop
	if class == "npc_turret_floor" then
		local parent = target._oseSpawner
		if parent and IsValid(parent) then
			parent:TakeDamageInfo(dmg)
			return
		end
	end

	if target:IsNPC() then
		-- NPCs take less damage the more players there are
		dmg:ScaleDamage(1 / self.m_DamageScale)
	elseif target["OSEProp"] then
		-- Props take more damage however
		dmg:ScaleDamage(self.m_DamageScale)
	end
end

function GM:ScaleNPCDamage(npc, hitgroup, dmginfo)
	-- The base gamemode applies a 3/4 damage penalty for limb damage, which
	-- we're overriding here to make it remotely possible to survive
	if hitgroup == HITGROUP_HEAD then
		dmginfo:ScaleDamage(2)
	end
end
