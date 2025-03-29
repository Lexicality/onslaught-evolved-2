--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

--- This file contains a bunch of stuff that should be in the base game but aren't

AddCSLuaFile()

--- Returns the index of a value if it exists
--- @generic V
--- @param table V[]
--- @param value V
--- @return integer | nil
function table.Find(table, value)
	for i, v in ipairs(table) do
		if v == value then
			return i
		end
	end
	return nil
end

--- Returns a single item from a list which may or may not exist
--- @param listid string
--- @param key string
--- @return any | nil
function list.GetEntry(listid, key)
	local list = list.GetForEdit(listid)
	local value = list[key]
	if (istable(value)) then
		value = table.Copy(value)
	end
	return value
end

if CLIENT then
	if (system.IsLinux()) then
		surface.CreateFont("DermaDefaultBold", {
			-- On my system at least, you need to specify bold in the font name
			-- or the damn thing doesn't show up as bold which is very silly but
			-- what can you do
			font     = "DejaVu Sans Bold",
			size     = 14,
			weight   = 800,
			extended = true
		})

		surface.CreateFont("DermaHeading", {
			font     = "DejaVu Sans Bold",
			size     = 16,
			weight   = 800,
			extended = true
		})
	else
		surface.CreateFont("DermaHeading", {
			font     = "Tahoma",
			size     = 15,
			weight   = 800,
			extended = true
		})
	end

	--- Formats money nicely
	--- @param amount integer
	--- @param formatStr? string
	function string.FormatMoney(amount, formatStr)
		if not formatStr then
			formatStr = "ose.hud.money"
		end
		local sepr = language.GetPhrase("ose.hud.money_sepr")
		return string.format(
			language.GetPhrase(formatStr),
			string.Comma(amount, sepr)
		)
	end

	-- https://wiki.facepunch.com/gmod/util.IsInWorld#example
	--- @type STrace
	local worldTrace = { collisiongroup = COLLISION_GROUP_WORLD, output = {} }

	function util.IsInWorld(pos)
		worldTrace.start = pos
		worldTrace.endpos = pos
		return not util.TraceLine(worldTrace).HitWorld
	end
end

-- Reject object orentated sillyness
-- (hopefully luaJIT will inline this!)
--- Lerps one colour to another
--- @param from GColor
--- @param to GColor
--- @param fraction number
--- @return GColor
function LerpColour(from, to, fraction)
	return from:Lerp(to, fraction)
end

local cvarScaleEasy   = GetConVar("sk_dmg_inflict_scale1")
local cvarScaleNormal = GetConVar("sk_dmg_inflict_scale2")
local cvarScaleHard   = GetConVar("sk_dmg_inflict_scale3")
--- @class GCTakeDamageInfo
local dmgMeta         = FindMetaTable("CTakeDamageInfo")

if dmgMeta.AdjustPlayerDamageInflictedForSkillLevel == nil then
	--- Adjusts the damage based on the current `skill` cvar value
	function dmgMeta:AdjustPlayerDamageInflictedForSkillLevel()
		-- Unclear but the c++ version of this function does this even though you
		-- could easily scale the damage correctly on the client
		if CLIENT then return end
		local damage = self:GetDamage()
		self:SetBaseDamage(damage)
		local skill = game.GetSkillLevel()
		if skill == 1 then
			damage = damage * cvarScaleEasy:GetFloat()
		elseif skill == 2 then
			damage = damage * cvarScaleNormal:GetFloat()
		elseif skill == 3 then
			damage = damage * cvarScaleHard:GetFloat()
		end
		self:SetDamage(damage)
	end
end
