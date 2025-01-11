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
	local ret = 0
	for _, output in pairs(self.m_tOutputs["OnNPCLimitChanged"]) do
		ret = ret + getOutputCount(output.entities)
	end
	return ret
end

---@param name string
---@param activator GEntity
---@param caller GEntity
---@param value string | nil
---@return boolean
function ENT:AcceptInput(name, activator, caller, value)
	if BaseClass.AddOutputFromAcceptInput(self, name, value) then
		return true
	end

	if name == "NPCLimitChanged" then
		local spawners = self:GetSpawnerCount()
		if spawners == 0 then
			return true
		end
		local parsedValue = tonumber(value)
		if parsedValue == nil then
			return true
		end
		local result = math.floor(self.m_Calc(parsedValue, spawners))
		self:TriggerOutput("OnNPCLimitChanged", self, self, tostring(result))
		return true
	end
	return false
end

---@param key string
---@param value string
function ENT:KeyValue(key, value)
	BaseClass.KeyValue(self, key, value)

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
