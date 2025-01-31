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

--- @class SENT_OSETriggerForceLose : SENT
--- @field m_NPCFilter {[string]: true}
local ENT = ENT --[[@as SENT_OSETriggerForceLose]]
--- @type SENT
local BaseClass
DEFINE_BASECLASS("base_brush")

ENT.Type = "brush"

function ENT:Initialize()
	self:SetTrigger(true)
end

---
--- Splits and validates a space separated table
---@param raw_value string
---@return {[string]: true} | nil
local function handleNPCs(raw_value)
	local split = string.Explode(" ", raw_value, false)
	local ret = {}
	for _, v in ipairs(split) do
		v = string.Trim(v)
		if v == "" then
			return nil
		end
		ret[v] = true
	end
	return ret
end

function ENT:KeyValue(key, value)
	BaseClass.KeyValue(self, key, value)

	if key == "npcfilter" then
		local parsed_value = handleNPCs(value)
		if parsed_value == nil then
			ErrorNoHalt("trigger_forcelose has invalid `npcfilter` keyvalue '", value, "'!\n")
			return
		end
		self.m_NPCs = parsed_value
	end
end

function ENT:StartTouch(ent)
	if not ent:IsNPC() or not self.m_NPCFilter[ent:GetClass()] then
		return
	end
	-- oopsie whoospie you did a fucky wucky
	-- TODO: sensible notification
	PrintMessage(HUD_PRINTTALK, "You failed to keep the objective free of npcs!")
	hook.Run("LoseRound")
end
