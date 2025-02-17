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

--- Sandbox Compat
--- @param str string
--- @param type number
--- @param length number
function GM:AddNotify(str, type, length)
	notification.AddLegacy(str, type, length)
end

---@param name string
function GM:LimitHit(name)
	local str = "#SBoxLimit_" .. name
	local translated = language.GetPhrase(str)
	if str == translated then
		-- No translation available, apply our own
		translated = string.format(language.GetPhrase("hint.hitXlimit"), language.GetPhrase(name))
	end

	notification.AddLegacy(translated, NOTIFY_ERROR, 6)
	surface.PlaySound("buttons/button10.wav")
end

function GM:OnUndo(name, strCustomString)
	local text = strCustomString

	if not text then
		local strId = "#Undone_" .. name
		text = language.GetPhrase(strId)
		if strId == text then
			-- No translation available, generate our own
			text = string.format(
				language.GetPhrase("hint.undoneX"),
				language.GetPhrase(name)
			)
		end
	end

	notification.AddLegacy(text, NOTIFY_UNDO, 2)

	surface.PlaySound("buttons/button15.wav")
end

function GM:OnCleanup(name)
	local str = "#Cleaned_" .. name
	local translated = language.GetPhrase(str)
	if str == translated then
		-- No translation available, apply our own
		translated = string.format(
			language.GetPhrase("hint.cleanedX"),
			language.GetPhrase(name)
		)
	end

	notification.AddLegacy(translated, NOTIFY_CLEANUP, 5)

	surface.PlaySound("buttons/button15.wav")
end
