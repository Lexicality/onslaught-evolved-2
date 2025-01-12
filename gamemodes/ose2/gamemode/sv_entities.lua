local function setupNPCManager()
	print("OSE2 Debug: Creating NPC manager")
	local npcManager = ents.Create("ose_npc_manager")
	npcManager:SetName("npc_manager")
	npcManager:Spawn()
	npcManager:Activate()
	--- @type GEntity[], GEntity[], GEntity[]
	local hunterSpawners, manhackSpawners, npcSpawners = {}, {}, {}
	for _, ent in ipairs(ents.FindByClass("ose_legacy_npc_spawner")) do
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
		if ent.m_SpawnMode == SPAWNER_SPAWN_MODE_HUNTER then
			hunterSpawners[#hunterSpawners + 1] = ent
		elseif ent.m_SpawnMode == SPAWNER_SPAWN_MODE_MANHACK then
			manhackSpawners[#manhackSpawners + 1] = ent
		elseif ent.m_SpawnMode == SPAWNER_SPAWN_MODE_NORMAL then
			npcSpawners[#npcSpawners + 1] = ent
		end
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
	print("OSE2 Debug: Creating gamerules")
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

function GM:SetupEntities()
	if #ents.FindByClass("ose_npc_manager") == 0 then
		setupNPCManager()
	end
	if #ents.FindByClass("ose_gamerules") == 0 then
		setupGameRules()
	end
end

function GM:InitPostEntity()
	self:SetupEntities()
end

function GM:PostCleanupMap()
	self:SetupEntities()
end
