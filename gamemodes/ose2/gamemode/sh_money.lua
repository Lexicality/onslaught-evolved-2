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

local priceMultiplierCvar = GetConVar("ose_price_multiplier")

function GM:SetupBuyables()
	--- @type {[string]: OSEAmmoDefinition}
	local ammo = list.GetForEdit("OSEAmmo")
	ammo["ammo_357"] = {
		Name = "#ose.ammo.357",
		Class = "357",
		DisplayModel = "models/Items/357ammo.mdl",
		Quantity = 18,
		Price = 200,
	}
	ammo["ammo_ar2"] = {
		Name = "#ose.ammo.ar2",
		Class = "AR2",
		DisplayModel = "models/Items/combine_rifle_cartridge01.mdl",
		Price = 150,
		Quantity = 120,
	}
	ammo["ammo_ar2alt"] = {
		Name = "#ose.ammo.ar2alt",
		Class = "AR2AltFire",
		DisplayModel = "models/Items/combine_rifle_ammo01.mdl",
		Quantity = 1,
		Price = 400,
	}
	ammo["ammo_buckshot"] = {
		Name = "#ose.ammo.buckshot",
		Class = "BuckShot",
		DisplayModel = "models/Items/BoxBuckshot.mdl",
		Quantity = 32,
		Price = 200,
	}
	ammo["ammo_crossbow"] = {
		Name = "#ose.ammo.crossbow",
		Class = "xbowbolt",
		DisplayModel = "models/Items/CrossbowRounds.mdl",
		Quantity = 10,
		Price = 500,
	}
	ammo["ammo_grenade"] = {
		Name = "#ose.ammo.grenade",
		Class = "grenade",
		DisplayModel = "models/Items/grenadeAmmo.mdl",
		Quantity = 1,
		Price = 300,
	}
	ammo["ammo_pistol"] = {
		Name = "#ose.ammo.pistol",
		Class = "Pistol",
		DisplayModel = "models/Items/BoxSRounds.mdl",
		Quantity = 72,
		Price = 100,
	}
	ammo["ammo_smg1"] = {
		Name = "#ose.ammo.smg1",
		Class = "SMG1",
		DisplayModel = "models/Items/BoxMRounds.mdl",
		Quantity = 90,
		Price = 150,
	}
	ammo["ammo_smg1_grenade"] = {
		Name = "#ose.ammo.smg1_grenade",
		Class = "SMG1_Grenade",
		DisplayModel = "models/Items/AR2_Grenade.mdl",
		Quantity = 1,
		Price = 250,
	}
end

--- Calculated cache of health/price for props
--- This is intentionally a local so it gets wiped on refreshes since the
--- calculation method might change and it's not *that* expensive to re-calculate
--- @type {[string]: number}
local propCache = {}

local FALLBACK_PROP_VALUE = 1000
local MIN_PROP_VALUE = 200
local MAX_PROP_VALUE = 800 -- TODO: Why is the max less than the fallback?!

local function doPropCalc(model)
	--- @type GEntity
	local ent
	if SERVER then
		ent = ents.Create("prop_physics_multiplayer")
		-- This can't reasonably fail, but it certainly can *unreasonably* fail
		-- so let's print an unhelpful error message
		if not IsValid(ent) then
			error("Can't create prop! Server's broken!!")
		end
		ent:SetModel(model)
	else
		ent = ents.CreateClientProp(model)
		-- This however could reasonably fail if the client doesn't have the
		-- model so let's not make this a fatal error
		if not IsValid(ent) then
			ErrorNoHalt("Can't create clientside model for '", model, "'!")
			return FALLBACK_PROP_VALUE
		end
	end
	ent:Spawn()
	ent:Activate()
	local physobj = ent:GetPhysicsObject()
	if not IsValid(physobj) then
		ErrorNoHalt("Can't calculate values for missing model '", model, "'!")
		ent:Remove()
		return FALLBACK_PROP_VALUE
	end

	local mass = physobj:GetMass()
	local size = ent:BoundingRadius() / 50

	ent:Remove()

	return math.Clamp(mass * size, MIN_PROP_VALUE, MAX_PROP_VALUE)
end

local function doCachedPropCalc(model)
	local cachedValue = propCache[model]
	if cachedValue ~= nil then
		return cachedValue
	end
	local value = doPropCalc(model)
	propCache[model] = value
	return value
end

--- Calculate the base un-changing health of a prop.
--- @param model string
--- @return integer price
function GM:CalculatePropBaseHealth(model)
	local baseHealth = doCachedPropCalc(model)
	return math.floor(baseHealth)
end

--- Calculate the base un-changing price of a prop.
--- @param model string
--- @return integer price
function GM:CalculatePropBasePrice(model)
	local price = doCachedPropCalc(model)
	-- TODO: Do we want the option to tweak/override individual prop prices?
	-- The original gamemode has this as an option but it never actually uses it
	-- and it seems like annoying complexity that we probably don't need
	return math.floor(price * priceMultiplierCvar:GetFloat())
end

--- Calculates the health that a player's spawned prop should have this round
--- This value should *NOT* change inside a round
--- @param player GPlayer
--- @param round integer
--- @param model string
--- @param baseHealth integer
--- @return integer
function GM:CalculatePropHealth(player, round, model, baseHealth)
	-- No tweaks by default
	return baseHealth
end

--- Calculates the price a player should pay for a prop this round
--- This value should *NOT* change inside a round
--- @param player GPlayer
--- @param round integer
--- @param model string
--- @param basePrice integer
--- @return integer
function GM:CalculatePropPrice(player, round, model, basePrice)
	-- No tweaks by default
	return basePrice
end

--- Calculates the price a player should pay for an entity this round
--- This value should *NOT* change inside a round
--- @param player GPlayer
--- @param round integer
--- @param entity string
--- @param basePrice integer
--- @return integer
function GM:CalculateEntityPrice(player, round, entity, basePrice)
	-- No tweaks by default
	return basePrice
end

--- INTERNAL: Does the work to calculate a prop's health
--- @param player GPlayer
--- @param model string
--- @return integer
function GM:LookupPropHealth(player, model)
	--- @type integer
	local baseHealth = hook.Call("CalculatePropBaseHealth", self, model)
	return hook.Call("CalculatePropHealth", self, player, self.m_Round, model, baseHealth)
end

--- INTERNAL: Does the work to calculate a prop's price
--- @param player GPlayer
--- @param model string
--- @return integer
function GM:LookupPropPrice(player, model)
	--- @type integer
	local basePrice = hook.Call("CalculatePropBasePrice", self, model)
	return hook.Call("CalculatePropPrice", self, player, self.m_Round, model, basePrice)
end

--- INTERNAL: Does the work to calculate a entity's price
--- @param player GPlayer
--- @param entity string
--- @param entData OSEEntityDefinition
--- @return integer
function GM:LookupEntityPrice(player, entity, entData)
	local basePrice = math.floor(entData.Price * priceMultiplierCvar:GetFloat())
	return hook.Call("CalculateEntityPrice", self, player, self.m_Round, entity, basePrice)
end

--- Checks if a particular ammo is valid for a player
--- This is run speculatively and should not notify the player
--- @param ply GPlayer
--- @param ammoName string
--- @param ammoData OSEAmmoDefinition
--- @return boolean
function GM:PlayerCanBuyAmmo(ply, ammoName, ammoData)
	return player_manager.RunClass(ply, "CanBuyAmmo", ammoName, ammoData)
end

function GM:LookupPlayerAmmo(ply, ammoName)
	local ammoData = list.GetEntry("OSEAmmo", ammoName)
	if not ammoData then
		return false
	end
	return hook.Call("PlayerCanBuyAmmo", self, ply, ammoName, ammoData)
end
