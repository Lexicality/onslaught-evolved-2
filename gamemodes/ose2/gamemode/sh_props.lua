--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]
AddCSLuaFile()

cleanup.Register("props")
cleanup.Register("ose_ammo_crates")
cleanup.Register("ose_health_chargers")
cleanup.Register("ose_mines")
cleanup.Register("ose_turrets")

function GM:SetupProps()
	--- @type OSEPropGroupDefinition[]
	local groups = list.GetForEdit("OSEGroups")
	local GROUP_WALLS = 1
	local GROUP_BOXES = 2
	local GROUP_BEAMS = 3
	local GROUP_OTHER = 4
	local GROUP_JUNK = 5
	local GROUP_SPECIAL = 6
	groups[GROUP_WALLS] = {
		Name = "#ose.group.walls",
		Icon = "icon16/door.png",
	}
	groups[GROUP_BOXES] = {
		Name = "#ose.group.boxes",
		Icon = "icon16/box.png",
	}
	groups[GROUP_BEAMS] = {
		Name = "#ose.groups.beams",
		Icon = "icon16/pencil.png",
	}
	groups[GROUP_OTHER] = {
		Name = "#ose.groups.other",
		Icon = "icon16/wrench.png",
	}
	groups[GROUP_JUNK] = {
		Name = "#ose.groups.junk",
		Icon = "icon16/bin.png",
	}
	groups[GROUP_SPECIAL] = {
		Name = "#ose.groups.special",
		Icon = "icon16/wand.png",
	}


	--- @type {[string]: OSEPropDefinition}
	local props = list.GetForEdit("OSEProps")

	--
	-- Walls
	--
	props["models/props_wasteland/prison_celldoor001a.mdl"] = {
		ModelGroup = GROUP_WALLS,
		Name = "#ose.props.cell_door"
	}
	props["models/props_debris/metal_panel01a.mdl"] = {
		ModelGroup = GROUP_WALLS,
		Name = "#ose.props.sheet_metal"
	}
	props["models/props_debris/metal_panel02a.mdl"] = {
		ModelGroup = GROUP_WALLS,
		Name = "#ose.props.sheet_metal"
	}
	props["models/props_lab/blastdoor001c.mdl"] = {
		ModelGroup = GROUP_WALLS,
		Name = "#ose.props.blast_door"
	}
	props["models/props_lab/blastdoor001b.mdl"] = {
		ModelGroup = GROUP_WALLS,
		Name = "#ose.props.blast_door"
	}
	props["models/props_wasteland/wood_fence01a.mdl"] = {
		SpawnAngle = Angle(0, 90, 0),
		ModelGroup = GROUP_WALLS,
		Name = "#ose.props.fence"
	}
	props["models/props_wasteland/wood_fence02a.mdl"] = {
		SpawnAngle = Angle(0, 90, 0),
		ModelGroup = GROUP_WALLS,
		Name = "#ose.props.fence"
	}
	props["models/props_interiors/VendingMachineSoda01a_door.mdl"] = {
		ModelGroup = GROUP_WALLS,
		Name = "#ose.props.vending_machine_door"
	}
	props["models/props_c17/shelfunit01a.mdl"] = {
		SpawnAngle = Angle(0, -90, 0),
		ModelGroup = GROUP_WALLS,
		Name = "#ose.props.shelf"
	}

	--
	-- Boxes
	--
	props["models/props_c17/furnitureStove001a.mdl"] = {
		ModelGroup = GROUP_BOXES,
		Name = "#ose.props.stove"
	}
	props["models/props_combine/breendesk.mdl"] = {
		ModelGroup = GROUP_BOXES,
		Name = "#ose.props.desk"
	}
	props["models/props_junk/wood_crate001a.mdl"] = {
		ModelGroup = GROUP_BOXES,
		Name = "#ose.props.crate"
	}
	props["models/props_junk/wood_crate002a.mdl"] = {
		ModelGroup = GROUP_BOXES,
		Name = "#ose.props.crate"
	}
	props["models/props_wasteland/kitchen_counter001b.mdl"] = {
		ModelGroup = GROUP_BOXES,
		Name = "#ose.props.table"
	}
	props["models/props_interiors/VendingMachineSoda01a.mdl"] = {
		ModelGroup = GROUP_BOXES,
		Name = "#ose.props.vending_machine"
	}
	props["models/props_wasteland/kitchen_fridge001a.mdl"] = {
		ModelGroup = GROUP_BOXES,
		Name = "#ose.props.fridge"
	}
	props["models/props_wasteland/kitchen_stove002a.mdl"] = {
		ModelGroup = GROUP_BOXES,
		Name = "#ose.props.large_stove"
	}
	props["models/props_c17/FurnitureFridge001a.mdl"] = {
		ModelGroup = GROUP_BOXES,
		Name = "#ose.props.fridge"
	}

	--
	-- Beams
	--
	props["models/props_docks/dock01_pole01a_128.mdl"] = {
		ModelGroup = GROUP_BEAMS,
		Name = "#ose.props.pole"
	}
	props["models/props_c17/gravestone_coffinpiece002a.mdl"] = {
		ModelGroup = GROUP_BEAMS,
		Name = "#ose.props.gravestone"
	}
	props["models/props_trainstation/traincar_rack001.mdl"] = {
		ModelGroup = GROUP_BEAMS,
		Name = "#ose.props.rack"
	}
	props["models/props_junk/iBeam01a.mdl"] = {
		SpawnAngle = Angle(0, -90, 0),
		ModelGroup = GROUP_BEAMS,
		Name = "#ose.props.i_beam"
	}

	--
	-- Other
	--
	props["models/props_c17/display_cooler01a.mdl"] = {
		SpawnAngle = Angle(0, -90, 0),
		ModelGroup = GROUP_OTHER,
		Name = "#ose.props.display_case"
	}
	props["models/props_pipes/concrete_pipe001a.mdl"] = {
		ModelGroup = GROUP_OTHER,
		Name = "#ose.props.pipe"
	}
	props["models/props_combine/combine_barricade_short01a.mdl"] = {
		SpawnAngle = Angle(0, 180, 0),
		ModelGroup = GROUP_OTHER,
		Name = "#ose.props.combine_barricade"
	}
	props["models/props_junk/TrashDumpster02b.mdl"] = {
		ModelGroup = GROUP_OTHER,
		Name = "#ose.props.dumpster_lid"
	}
	props["models/props_c17/concrete_barrier001a.mdl"] = {
		ModelGroup = GROUP_OTHER,
		Name = "#ose.props.barricade"
	}

	--
	-- Junk
	--
	props["models/props_wasteland/controlroom_filecabinet002a.mdl"] = {
		ModelGroup = GROUP_JUNK,
		Name = "#ose.props.filing_cabinet"
	}
	props["models/props_c17/door01_left.mdl"] = {
		ModelGroup = GROUP_JUNK,
		Name = "#ose.props.door"
	}
	props["models/props_interiors/Furniture_Couch02a.mdl"] = {
		ModelGroup = GROUP_JUNK,
		Name = "#ose.props.couch"
	}
	props["models/props_c17/oildrum001.mdl"] = {
		ModelGroup = GROUP_JUNK,
		Name = "#ose.props.oil_drum"
	}
	props["models/props_junk/PushCart01a.mdl"] = {
		ModelGroup = GROUP_JUNK,
		Name = "#ose.props.cart"
	}
	props["models/props_c17/FurnitureCouch001a.mdl"] = {
		ModelGroup = GROUP_JUNK,
		Name = "#ose.props.couch"
	}
	props["models/props_wasteland/laundry_cart001.mdl"] = {
		ModelGroup = GROUP_JUNK,
		Name = "#ose.props.cart"
	}
	props["models/props_wasteland/laundry_basket001.mdl"] = {
		ModelGroup = GROUP_JUNK,
		Name = "#ose.props.basket"
	}
	props["models/props_wasteland/prison_bedframe001b.mdl"] = {
		ModelGroup = GROUP_JUNK,
		Name = "#ose.props.bedframe"
	}

	--- @type {[string]: OSEEntityDefinition}
	local entities = list.GetForEdit("OSEEntities")
	entities["ose_mine"] = {
		Name = "#ose_mine",
		DisplayModel = "models/props_combine/combine_mine01.mdl",
		DisplaySkin = 1,
		AllowInBattle = true,
		ModelGroup = GROUP_SPECIAL,
		Price = 300,
	}
	entities["ose_turret"] = {
		Name = "#ose_turret",
		DisplayModel = "models/combine_turrets/floor_turret.mdl",
		DisplaySkin = 0,
		-- TODO:
		-- The automatic spawnicon position/angles/etc is completely broken for
		-- the turret model.
		-- Happily the default one is not, but that's only set for the default
		-- skin, which means we can't use the citizen turret skin unless I can
		-- figure out how the defaults are set and create ones for the skins
		-- This camerea position is pretty acceptable:
		-- {"ang":"{20 270 0}","pos":"[-5 200 105]","mdl_ang":"{0 130 0}","fov":16.08}
		-- DisplaySkin = 1,
		AllowInBattle = true,
		ModelGroup = GROUP_SPECIAL,
		Price = 700,
		SpawnAngle = Angle(0, 180, 0),
	}
	entities["ose_health_charger"] = {
		Name = "#ose_health_charger",
		DisplayModel = "models/props_combine/health_charger001.mdl",
		AllowInBattle = true,
		ModelGroup = GROUP_SPECIAL,
		Price = 600,
		SpawnAngle = function(tr)
			return tr.HitNormal:Angle()
		end,
	}
	entities["ose_ammo_crate"] = {
		Name = "#ose_ammo_crate",
		DisplayModel = "models/items/ammocrate_smg1.mdl",
		AllowInBattle = true,
		ModelGroup = GROUP_SPECIAL,
		Price = 400,

	}

	for mdl, _ in pairs(props) do
		util.PrecacheModel(mdl)
	end
	for _, ent in pairs(entities) do
		util.PrecacheModel(ent.DisplayModel)
	end
end
