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

local startingMoneyCvar = GetConVar("ose_starting_money")

---@param player GPlayer
---@return integer
function GM:GetStartingMoney(player)
	return startingMoneyCvar:GetInt()
end

--- Checks if a player is allowed to use a particular ammo crate
--- @param ply GPlayer
--- @param crate SENT_OSEAmmoCrate
--- @return boolean
function GM:PlayerOpenAmmoCrate(ply, crate)
	-- Do we care about prop protection? Probably not
	return self.m_RoundPhase ~= ROUND_PHASE_BUILD
end

util.AddNetworkString("OSE Ammo Menu Open")
util.AddNetworkString("OSE Ammo Menu Close")

--- Called when a player successfully opens an ammo crate
--- @param ply GPlayer
--- @param crate SENT_OSEAmmoCrate
function GM:PlayerOpenedAmmoCrate(ply, crate)
	net.Start("OSE Ammo Menu Open")
	net.WriteEntity(crate)
	net.Send(ply)
end

net.Receive("OSE Ammo Menu Close", function(len, ply)
	--- @cast ply GPlayer
	-- Find every ammo crate vaguely near them and tell it they're not using it any more
	for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), 300)) do
		--- @cast ent SENT_OSEAmmoCrate
		if ent:GetClass() == "ose_ammo_crate" then
			-- This is safe to call if they're not actually using the crate
			ent:OnPlayerFinished(ply)
		end
	end
end)

--- Find a player by name, entindex or steamID
--- @param text string
--- @return GPlayer?
function FindPlayerConsole(text)
	local ply = player.GetBySteamID(text)
	if IsValid(ply) then
		return ply
	end
	ply = player.GetBySteamID64(text)
	if IsValid(ply) then
		return ply
	end

	text = string.lower(text)

	--- @type GPlayer[]
	local matches = {}
	for _, ply in ipairs(player.GetAll()) do
		--- @cast ply GPlayer
		local name = string.lower(ply:Name())
		if name == text then
			return ply
		elseif string.find(ply:Name(), text, 1, true) then
			matches[#matches + 1] = ply
		end
	end
	local numMatches = #matches
	if numMatches == 1 then
		return matches[1]
	elseif numMatches == 0 then
		print(
			"!!!",
			string.format(
				"No players match search string %q",
				text
			)
		)
	else
		print(
			"!!!",
			string.format(
				"%d players match search string %q:",
				numMatches,
				text
			)
		)
		for _, ply in ipairs(matches) do
			print(
				"!!!",
				string.format(
					"Player %d: %q / %q",
					ply:UserID(),
					ply:Name(),
					ply:SteamID()
				)
			)
		end
	end
	return nil
end

--- comment
--- @param lookup string
--- @return string[]
function PlayerNameAutoComplete(lookup)
	local ret = {}
	for _, ply in ipairs(player.GetAll()) do
		--- @cast ply GPlayer
		local name = ply:Name()
		if not lookup or name:StartsWith(lookup) then
			ret[#ret + 1] = name
		end
	end
	table.sort(ret)
	return ret
end

---@param ply GPlayer
---@param cmd string
---@param args string[]
local function ccOSESetMoney(ply, cmd, args)
	if IsValid(ply) and not ply:IsListenServerHost() then
		ply:PrintMessage(HUD_PRINTCONSOLE, "You do not have permission to use this command")
	end
	local targetName = args[1]
	local amount = tonumber(args[2])
	if targetName == nil or amount == nil then
		print("Usage: ose_set_money playername amount")
		return
	end
	local target = FindPlayerConsole(args[1])
	if not target then
		return
	end
	target:SetMoney(amount)
end

---@param cmd string
---@param argStr string
---@param args string[]
---@return string[]
local function ccOSESetMoneyAutocomplete(cmd, argStr, args)
	if #args > 1 then
		return {}
	end
	return PlayerNameAutoComplete(argStr)
end
concommand.Add(
	"ose_set_money",
	ccOSESetMoney,
	ccOSESetMoneyAutocomplete,
	"Sets a user's money to a specific value"
)


---@param ply GPlayer
---@param cmd string
---@param args string[]
local function ccOSEAddMoney(ply, cmd, args)
	if IsValid(ply) and not ply:IsListenServerHost() then
		ply:PrintMessage(HUD_PRINTCONSOLE, "You do not have permission to use this command")
	end
	local targetName = args[1]
	local amount = tonumber(args[2])
	if targetName == nil or amount == nil then
		print("Usage: ose_add_money playername amount")
		return
	end
	local target = FindPlayerConsole(args[1])
	if not target then
		return
	end
	target:AddMoney(amount, "ose.money.reason.admin")
end

---@param cmd string
---@param argStr string
---@param args string[]
---@return string[]
local function ccOSEAddMoneyAutocomplete(cmd, argStr, args)
	if #args > 1 then
		return {}
	end
	return PlayerNameAutoComplete(argStr)
end
concommand.Add(
	"ose_add_money",
	ccOSEAddMoney,
	ccOSEAddMoneyAutocomplete,
	"Give a user some money"
)

---@param ply GPlayer
---@param cmd string
---@param args string[]
local function ccOSEBuyAmmo(ply, cmd, args)
	if not IsValid(ply) then
		print("The server can't buy ammo!")
		return
	end

	-- We want to ensure the user is currently using an ammo crate, but we don't
	-- want to be anoying if say someone walks in front of the player while
	-- they're buing ammo, so do a bit of jiggery pokery
	--- @type STrace
	local trace = {}
	trace.start = ply:GetShootPos()
	-- NOTE: 120 is the magic value defined in `ose_ammo_crate.lua`, see the justification there
	trace.endpos = trace.start + ply:GetAimVector() * 120
	-- Pass through everything that's not an ammo crate
	trace.filter = { "ose_ammo_crate" } --[[@as any]]
	trace.whitelist = true
	--- @type SENT_OSEAmmoCrate
	local ent = util.TraceLine(trace).Entity
	if not (
			IsValid(ent)
			and ent:GetClass() == "ose_ammo_crate"
			and ent:IsPlayerUsingMe(ply)
		)
	then
		ply:SendNotification(NOTIFY_ERROR, "ose.notification.cant_buy_ammo", 10)
		-- Something may have gone wrong, so close the menu and force them to re-open it
		net.Start("OSE Ammo Menu Close")
		net.Send(ply)
		return
	end


	local ammoName = args[1]
	--- @type OSEAmmoDefinition
	local ammoData = list.GetEntry("OSEAmmo", ammoName)
	if not ammoData then
		ply:SendNotification(NOTIFY_ERROR, "ose.notification.invalid_ammo", 10, ammoName)
		return
	elseif not hook.Run("PlayerCanBuyAmmo", ply, ammoName, ammoData) then
		-- no need to notify the player, the hook will do that
		return
	end

	local multiplier = tonumber(args[2])
	if multiplier ~= nil then
		-- Ensure no one tries to buy 0.33333333 of a clip
		multiplier = math.floor(math.Clamp(multiplier, 1, 5))
	else
		multiplier = 1
	end

	--- @type number
	local price = hook.Run("LookupAmmoPrice", ply, ammoName, ammoData) * multiplier
	if not ply:CanAfford(price) then
		ply:SendNotification(NOTIFY_ERROR, "ose.notification.cant_afford", 10)
		return
	end

	ply:AddMoney(-price, "ose.money.reason.bought_x", ammoData.Name)
	local weapon = ammoData.GiveWeapon
	if weapon and not ply:HasWeapon(weapon) then
		ply:Give(weapon, true)
	end
	ply:GiveAmmo(ammoData.Quantity * multiplier, ammoData.EngineName, false)
end
concommand.Add("ose_buy_ammo", ccOSEBuyAmmo)
