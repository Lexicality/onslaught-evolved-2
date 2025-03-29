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

-- Value from the original gamemode - double the default value (3)
local TURRET_DAMAGE = 6

function GM:EntityFireBullets(ent, bullet)
	-- Unfortunately the turret uses the `Pistol` ammo type and I can't make it
	-- more powerful without also giving the metrocops all a boost which I don't
	-- want to do, so the easiest solution is to just override the bullet before
	-- it's fired which disables the ammo lookup.
	if ent:GetClass() == "npc_turret_floor" and IsValid(ent:GetCreator()) then
		bullet.Damage = TURRET_DAMAGE
	end

	return true
end

-- These values were copied from the original gamemode, I have no idea how they
-- were chosen - probably just vibes.
local WEAPON_DAMAGE_OVERRIDES = {
	["357"] = 50,
	["ar2"] = 11 * 1.4,
	["crowbar"] = 25,
	["pistol"] = 12,
	["buckshot"] = 9,
	["smg1"] = 12,
}

local function overrideDamageCvars()
	for name, damage in pairs(WEAPON_DAMAGE_OVERRIDES) do
		RunConsoleCommand("sk_plr_dmg_" .. name, tostring(damage))
	end
end

-- This protects us from someone doing something that causes the skill config
-- file being re-executed mid-game, for example by changing the `skill` cvar
cvars.AddChangeCallback("sk_plr_dmg_crowbar", function(_, __, value)
	-- If gmod ever changes the default value from 10 (or the server owner
	-- changes the value in their `skill.cfg` file) then this if statement will
	-- break, but given it's a safety net I think we're fine to rely on this and
	-- fix it should it become a problem.
	if value == "10" then
		-- Wait for the rest of the config file to finish executing before
		-- re-overriding the values
		timer.Simple(0, overrideDamageCvars)
	end
end, "the skill system makes me sad")

function GM:SetupDamageOverrides()
	-- Unfortunately the skill config files get executed *after* InitPostEntity,
	-- but thankfully still in the same frame as startup, so we need to wait for
	-- the first frame after starting before overriding the weapon values
	timer.Simple(0, overrideDamageCvars)
end
