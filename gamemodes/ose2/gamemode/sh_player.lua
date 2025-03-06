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

function GM:SetupClasses()
	--- @type {[string]: OSEClassDefinition}
	local classes = list.GetForEdit("OSEClasses")

	classes["player_engineer"] = {
		Name = "#ose.player.engineer",
		Description = "#ose.player.engineer_desc",
		Selectable = true,
		Icon = "ose/classes/icon_engineer",
	}
	classes["player_pyro"] = {
		Name = "#ose.player.pyro",
		Description = "#ose.player.pyro_desc",
		Selectable = true,
		Icon = "ose/classes/icon_pyro",
	}
	classes["player_scout"] = {
		Name = "#ose.player.scout",
		Description = "#ose.player.scout_desc",
		Selectable = true,
		Icon = "ose/classes/icon_scout",
	}
	classes["player_sniper"] = {
		Name = "#ose.player.sniper",
		Description = "#ose.player.sniper_desc",
		Selectable = true,
		Icon = "ose/classes/icon_sniper",
	}
	classes["player_soldier"] = {
		Name = "#ose.player.soldier",
		Description = "#ose.player.soldier_desc",
		Selectable = true,
		Icon = "ose/classes/icon_soldier",
	}
	classes["player_support"] = {
		Name = "#ose.player.support",
		Description = "#ose.player.support_desc",
		Selectable = false, -- TODO: Work out how to actually do this one
		Icon = "ose/classes/icon_support",
	}
end

--- Checks if a player is allowed to choose a certain class
--- @param ply GPlayer @The player who wants to switch to this class
--- @param class string @The pre-validated class, eg `player_soldier`
--- @param classData OSEClassDefinition @The data for this class
--- @return boolean
function GM:PlayerCanChooseClass(ply, class, classData)
	return true
end
