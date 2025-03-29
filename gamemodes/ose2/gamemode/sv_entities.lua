local function setupNPCManager()
	local npcManager = ents.Create("ose_npc_manager")
	npcManager:SetName("npc_manager")
	npcManager:Spawn()
	npcManager:Activate()
	--- @type GEntity[], GEntity[], GEntity[]
	local hunterSpawners, manhackSpawners, npcSpawners = {}, {}, {}
	for _, ent in ipairs(ents.FindByClass("ose_legacy_npc_spawner")) do
		--- @cast ent SENT_OSESpawner
		npcManager:SetKeyValue("OnNPCSpawnEnabled", ent:GetName() .. ",Enable")
		npcManager:SetKeyValue("OnNPCSpawnDisabled", ent:GetName() .. ",Disable")
		npcManager:SetKeyValue("OnNPCSpawnFrequencyChanged", ent:GetName() .. ",SetSpawnFrequency")
		ent:SetKeyValue("OnSpawnNPC", "npc_manager,NPCSpawned")

		if ent.m_SpawnMode == SPAWNER_SPAWN_MODE_HUNTER then
			hunterSpawners[#hunterSpawners + 1] = ent
		elseif ent.m_SpawnMode == SPAWNER_SPAWN_MODE_MANHACK then
			manhackSpawners[#manhackSpawners + 1] = ent
		elseif ent.m_SpawnMode == SPAWNER_SPAWN_MODE_NORMAL then
			npcSpawners[#npcSpawners + 1] = ent
		end
	end
	-- TODO: Can I do something about the alisas so I don't have to do this?
	for _, ent in ipairs(ents.FindByClass("sent_spawner")) do
		--- @cast ent SENT_OSESpawner
		npcManager:SetKeyValue("OnNPCSpawnEnabled", ent:GetName() .. ",Enable")
		npcManager:SetKeyValue("OnNPCSpawnDisabled", ent:GetName() .. ",Disable")
		npcManager:SetKeyValue("OnNPCSpawnFrequencyChanged", ent:GetName() .. ",SetSpawnFrequency")
		ent:SetKeyValue("OnSpawnNPC", "npc_manager,NPCSpawned")

		if ent.m_SpawnMode == SPAWNER_SPAWN_MODE_HUNTER then
			hunterSpawners[#hunterSpawners + 1] = ent
		elseif ent.m_SpawnMode == SPAWNER_SPAWN_MODE_MANHACK then
			manhackSpawners[#manhackSpawners + 1] = ent
		elseif ent.m_SpawnMode == SPAWNER_SPAWN_MODE_NORMAL then
			npcSpawners[#npcSpawners + 1] = ent
		end
	end
	for _, ent in ipairs(ents.FindByClass("sent_spawnonce")) do
		npcManager:SetKeyValue("OnNPCSpawnEnabled", ent:GetName() .. ",Enable")
		npcManager:SetKeyValue("OnNPCSpawnDisabled", ent:GetName() .. ",Disable")
		npcManager:SetKeyValue("OnNPCSpawnFrequencyChanged", ent:GetName() .. ",SetSpawnFrequency")
		ent:SetKeyValue("OnSpawnNPC", "npc_manager,NPCSpawned")
	end

	if #hunterSpawners ~= 0 then
		local helper = ents.Create("ose_spawner_helper")
		helper:SetName("ose_hunter_helper")
		helper:Spawn()
		helper:Activate()
		npcManager:SetKeyValue("OnHunterLimitChanged", helper:GetName() .. ",NPCLimitChanged")
		for _, ent in ipairs(hunterSpawners) do
			helper:SetKeyValue("OnNPCLimitChanged", ent:GetName() .. ",SetMaxLiveChildren")
		end
	end
	if #manhackSpawners ~= 0 then
		local helper = ents.Create("ose_spawner_helper")
		helper:SetName("ose_manhack_helper")
		helper:Spawn()
		helper:Activate()
		npcManager:SetKeyValue("OnManhackLimitChanged", helper:GetName() .. ",NPCLimitChanged")
		for _, ent in ipairs(manhackSpawners) do
			helper:SetKeyValue("OnNPCLimitChanged", ent:GetName() .. ",SetMaxLiveChildren")
		end
	end
	if #npcSpawners ~= 0 then
		local helper = ents.Create("ose_spawner_helper")
		helper:SetName("ose_npc_helper")
		helper:Spawn()
		helper:Activate()
		npcManager:SetKeyValue("OnNPCLimitChanged", helper:GetName() .. ",NPCLimitChanged")
		for _, ent in ipairs(npcSpawners) do
			helper:SetKeyValue("OnNPCLimitChanged", ent:GetName() .. ",SetMaxLiveChildren")
		end
	end
end

local function setupGameRules()
	local gamerules = ents.Create("ose_gamerules")
	gamerules:SetName("gamerules")
	gamerules:Spawn()
	gamerules:Activate()
	if #ents.FindByName("ose_battle") then
		gamerules:SetKeyValue("OnBattle", "ose_battle,trigger")
	end
	if #ents.FindByName("ose_build") then
		gamerules:SetKeyValue("OnBuild", "ose_build,trigger")
	end
	if #ents.FindByName("ose_win") then
		gamerules:SetKeyValue("OnWin", "ose_win,trigger")
	end
	if #ents.FindByName("ose_lose") then
		gamerules:SetKeyValue("OnLose", "ose_lose,trigger")
	end
end

local function setupDissolvers()
	if #ents.FindByName("ose_dissolve_nobuild") == 0 then
		local ent = ents.Create("env_entity_dissolver")
		ent:SetName("ose_dissolve_nobuild")
		ent:SetKeyValue("magnitude", "3")
		ent:SetKeyValue("dissolvetype", "2")
		ent:Spawn()
	end
	if #ents.FindByName("ose_dissolve_propdeath") == 0 then
		local ent = ents.Create("env_entity_dissolver")
		ent:SetName("ose_dissolve_propdeath")
		-- Disolve type Core (blasted away from the origin while disolving)
		ent:SetKeyValue("dissolvetype", "3")
		-- Blast at 200 units per second
		ent:SetKeyValue("magnitude", "200")
		-- For this effect to look good it should ideally blast away from the
		-- middle of the map, so grab a random player spawnpoint since those are
		-- generally somewhere in the middle
		local spawns = ents.FindByClass("info_player_start")
		local spawn = spawns[math.random(#spawns)]
		ent:SetPos(spawn:GetPos())
		ent:Spawn()
	end
end

local function setupBullseye()
	-- We need to always have a bullseye to avoid relationship errors, but we
	-- don't want to have one that'll actually be visible to the npcs
	-- This should be "close enough".
	local ent = ents.Create("npc_bullseye")
	ent:SetName("ose_be_gnd")
	ent:SetKeyValue(
		"spawnflags",
		tostring(
		-- "Not Solid"
			65536
			-- "Take No Damage"
			+ 131072
		)
	)
	ent:SetKeyValue("minangle", "1")
	ent:SetKeyValue("mindist", "1")
	local spawns = ents.FindByClass("info_player_start")
	local spawn = spawns[math.random(#spawns)]
	ent:SetPos(spawn:GetPos())
	ent:Spawn()
end

function GM:SetupEntities()
	if #ents.FindByClass("ose_npc_manager") == 0 then
		setupNPCManager()
	end
	if #ents.FindByClass("ose_gamerules") == 0 then
		setupGameRules()
	end
	setupDissolvers()
	setupBullseye()
end

function GM:InitPostEntity()
	self:SetupEntities()
end

function GM:PostCleanupMap()
	self:SetupEntities()
end

--- @param ent GEntity
--- @param name string
--- @param old GEntity
--- @param new GEntity
local function onCreatorChanged(ent, name, old, new)
	if IsValid(new) and new:IsPlayer() then
		ent._oseCreatorSID = (new --[[@as GPlayer]]):SteamID64()
	end
end

--- Ensures players get credit for their flame based kills
--- @param entFlame GEntity
local function flambe(entFlame)
	if not IsValid(entFlame) then return end
	--- @type GEntity
	local victim = entFlame:GetInternalVariable("m_hEntAttached")
	if not IsValid(victim) then return end
	local inflictor = victim._oseIgniter
	if IsValid(inflictor) then
		entFlame:SetCreator(inflictor)
	end
end

function GM:OnEntityCreated(ent)
	if ent:GetClass() == "entityflame" then
		-- `pFlame->AttachToEntity` gets called *after* the flame exists
		timer.Simple(0, function() flambe(ent) end)
	end
	if ent.NetworkVarNotify and not ent:IsWeapon() then
		ent:NetworkVarNotify("Creator", onCreatorChanged)
	end
	ent:SetNW2VarProxy("Creator", onCreatorChanged)
end
