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

--- @class OSEPlayerEngineer : OSEPlayerBase
local PLAYER = {}

PLAYER.DisplayName = "#ose.player.engineer"
-- No running or jumping allowed
PLAYER.WalkSpeed = 300
PLAYER.RunSpeed = 300
PLAYER.JumpPower = 160
-- Very slight boost in health
PLAYER.MaxHealth = 120
PLAYER.StartHealth = 120

PLAYER.ValidAmmo = {
	"ammo_pistol",
	"ammo_buckshot",
}

function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
	self.Player:Give("weapon_pistol")
	self.Player:GiveAmmo(144, "Pistol")
	self.Player:Give("weapon_shotgun")
	self.Player:GiveAmmo(64, "Buckshot")
	self.Player:Give("weapon_physcannon")
	self.Player:Give("weapon_ose_repair_stick")
	self.Player:Give("weapon_ose_health_charger_spawner")
	self.Player:Give("weapon_ose_turret_spawner")
	self.Player:SwitchToDefaultWeapon()
end

player_manager.RegisterClass("player_engineer", PLAYER, "player_osebase")
