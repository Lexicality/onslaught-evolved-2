--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

--- @class SENT_OSESpawnerHelper : SENT_OSEBasePoint
local ENT = ENT --[[@as SENT_OSESpawnerHelper]]
--- @type SENT_OSEBasePoint
local BaseClass
DEFINE_BASECLASS("base_osepoint");

--- @type fun(input: integer, spawners: integer): integer
ENT.m_Calc = nil

local function defaultCalculation(input, spawners)
	return input / spawners
end

function ENT:Initialize()
	if self.m_Calc == nil then
		self.m_Calc = defaultCalculation
	end
end

---@param target string
---@return integer
local function getOutputCount(target)
	if string.StartsWith(target, "!") then
		return 0
	end
	return #ents.FindByName(target)
end

function ENT:GetSpawnerCount()
	if not self.m_tOutputs or not self.m_tOutputs["OnNPCLimitChanged"] then
		return 0
	end
	local dedupedEntities = {}
	for _, output in pairs(self.m_tOutputs["OnNPCLimitChanged"]) do
		dedupedEntities[output.entities] = true
	end
	local ret = 0
	for entities, _ in pairs(dedupedEntities) do
		ret = ret + getOutputCount(entities)
	end
	return ret
end

function ENT:AcceptInput(name, activator, caller, value)
	if BaseClass.AddOutputFromAcceptInput(self, name, value) then
		return true
	end

	name = string.lower(name)

	if name == "npclimitchanged" then
		local spawners = self:GetSpawnerCount()
		if spawners == 0 then
			return true
		end
		local parsedValue = tonumber(value)
		if parsedValue == nil then
			return true
		end
		local result = self.m_Calc(parsedValue, spawners)
		-- this will unfortunately cause weird behaviour if the hunter limit is
		-- 2 and there are 3 hunter spawners but the alternative is simply "no
		-- hunters" and a map being harder is better imo
		result = math.max(1, math.floor(result))
		self:TriggerOutput("OnNPCLimitChanged", self, tostring(result))
		return true
	end
	return false
end

function ENT:KeyValue(key, value)
	BaseClass.KeyValue(self, key, value)

	key = string.lower(key)

	if key == "lua" and value ~= nil then
		local input = "local input, spawners = ...; return " .. value

		local calc = CompileString(input, "ose_spawner_helper	custom calculation", false)
		if isstring(calc) then
			ErrorNoHalt("ose_spawner_helper has invalid `lua` keyvalue: ", calc, "!\n")
			return
		end

		self.m_Calc = calc
	end
end
