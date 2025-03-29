--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

--- @class SENT_OSEFuncNobuild : SENT
local ENT = ENT --[[@as SENT_OSEFuncNobuild]]
--- @type SENT
local BaseClass
DEFINE_BASECLASS("base_brush")

ENT.Type = "brush"

-- TODO Nocollide players when they're in me
