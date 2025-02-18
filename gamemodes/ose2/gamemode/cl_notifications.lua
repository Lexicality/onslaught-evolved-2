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

local hintCvar = CreateClientConVar("ose_showhints", "1", true, false, "Whether to display popup hints.")

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

--- Does some mildly annoying formatting
--- @param text string
--- @param args any[]
--- @return string
local function maybeFormatText(text, args)
	text = language.GetPhrase(text)
	if #args == 0 then
		return text
	end
	-- Ensure any strings in the arguments are also correctly translated
	for i, v in ipairs(args) do
		if isstring(v) and v[1] == "#" then
			args[i] = language.GetPhrase(v)
		end
	end
	return string.format(text, unpack(args))
end

local function onNotification()
	local text = net.ReadString()
	local type = net.ReadUInt(1)
	local length = net.ReadUInt(7)
	local args = net.ReadTable(true)

	text = maybeFormatText(text, args)

	notification.AddLegacy(text, type, length)
end
net.Receive("OSE Notification", onNotification)

local function onMoneyNotification()
	local reason = net.ReadString()
	local amount = net.ReadInt(32)
	local args = net.ReadTable(true)

	reason = maybeFormatText(reason, args)

	--- @type string?
	local moneystr
	if amount > 0 then
		moneystr = "ose.hud.add_money"
	elseif amount < 0 then
		moneystr = "ose.hud.sub_money"
		-- Re-positivitate the amount so the formatter can add the -
		amount = amount * -1
	end
	local formattedAmount = string.FormatMoney(amount, moneystr)

	-- TODO: Much better money notification
	local text = string.format(
		language.GetPhrase("ose.notification.moneytemp"),
		formattedAmount,
		reason
	)
	notification.AddLegacy(text, NOTIFY_GENERIC, 10)
end
net.Receive("OSE Money Notification", onMoneyNotification)


-- A list of hints we've already done so we don't repeat ourselves
local ProcessedHints = {}

--- @param group string
local function lookupBinding(group)
	local key = input.LookupBinding(group)
	if not key then
		return string.lower(group) .. " not bound"
	end
	return "'" .. string.upper(key) .. "'"
end

--
-- Throw's a Hint to the screen
--
local function ThrowHint(name)
	if not hintCvar:GetBool() or engine.IsPlayingDemo() then return end

	local text = language.GetPhrase("Hint_" .. name)

	text = string.gsub(text, "%%([^%%]+)%%", lookupBinding)

	GAMEMODE:AddNotify(text, NOTIFY_HINT, 20)

	surface.PlaySound("ambient/water/drip" .. math.random(1, 4) .. ".wav")
end


--
-- Adds a hint to the queue
--
function GM:AddHint(name, delay)
	if (ProcessedHints[name]) then return end

	timer.Create(
		"HintSystem_" .. name,
		delay,
		1,
		function() ThrowHint(name) end
	)
	ProcessedHints[name] = true
end

--
-- Removes a hint from the queue
--
function GM:SuppressHint(name)
	ProcessedHints[name] = true
	timer.Remove("HintSystem_" .. name)
end

-- Tell them how to turn the hints off after 1 minute
-- GM:AddHint( "Annoy1", 5 )
-- GM:AddHint( "Annoy2", 7 )
