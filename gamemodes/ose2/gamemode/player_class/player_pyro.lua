--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

AddCSLuaFile()

--- @type OSEPlayerBase
local BaseClass
DEFINE_BASECLASS("player_osebase")

--- @class OSEPlayerPyro : OSEPlayerBase
local PLAYER = {}

PLAYER.DisplayName = "#ose.player.pyro"
PLAYER.WalkSpeed = 450
PLAYER.RunSpeed = 450
PLAYER.JumpPower = 210
PLAYER.MaxHealth = 150
PLAYER.StartHealth = 150

PLAYER.ValidAmmo = {
	"ammo_pistol",
	"ammo_grenade",
	"ammo_flamer_fuel",
}


function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
	self.Player:Give("weapon_crowbar")
	self.Player:Give("weapon_pistol")
	self.Player:GiveAmmo(144, "Pistol")
	self.Player:Give("weapon_ose_flamethrower")
	self.Player:GiveAmmo(200, "FlamerFuel")
	self.Player:Give("weapon_frag")
	self.Player:GiveAmmo(4, "grenade")
	self.Player:Give("weapon_ose_mine_spawner")
	self.Player:SwitchToDefaultWeapon()
end

player_manager.RegisterClass("player_pyro", PLAYER, "player_osebase")
