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
AddCSLuaFile()

include("sandbox/gamemode/player_extension.lua")

--- @type GPlayer
local plyMeta = FindMetaTable("Player")

-- gotta override `CheckLimit` to make it more onslaughty
function plyMeta:CheckLimit(limitName)
	local c = cvars.Number("ose_max" .. limitName, 0)
	local count = self:GetCount(limitName)

	local ret = hook.Run("PlayerCheckLimit", self, limitName, count, c)
	if ret ~= nil then
		if not ret and SERVER then
			self:LimitHit(limitName)
		end
		return ret
	end

	if c < 0 then return true end

	if count >= c then
		if SERVER then
			self:LimitHit(limitName)
		end
		return false
	end

	return true
end
