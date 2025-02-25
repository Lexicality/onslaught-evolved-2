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
