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
include("shared.lua")

--- @class SWEP_OSEBaseSpawner : SSWEP
--- @field m_Model string The entity's display model
--- @field m_Price integer How much the user's gonna pay
--- @field m_SpawnAngle SpawnAngle
--- @field m_EntData OSEEntityDefinition
--- @field m_DrawGhost boolean
--- @field m_Ghost GEntity
--- @field m_HideGhost number | nil
local SWEP = SWEP --[[@as SWEP_OSEBaseSpawner]]
--- @type SSWEP
local BaseClass
DEFINE_BASECLASS("weapon_base")

SWEP.DrawWeaponInfoBox = false -- TODO!

SWEP.WepSelectIcon = surface.GetTextureID("vgui/gmod_tool")

SWEP.DrawAmmo = false

local COLOUR_VALID = Color(0, 255, 0, 120)
local COLOUR_INVALID = Color(255, 0, 0, 120)
local WHITE_MAT = "models/debug/debugwhite"

function SWEP:Initialize()
	self:SetHoldType("revolver")
	local owner = self:GetOwner() --[[@as GPlayer]]
	if owner ~= LocalPlayer() then
		return
	end
	-- TODO: Probably should have a convar for this for low perf users
	self.m_DrawGhost = true

	--- @type OSEEntityDefinition | nil
	local ent = list.GetEntry("OSEEntities", self.EntityClass)
	if ent == nil then
		error(self.ClassName .. " has unknown entity " .. self.EntityClass .. " defined!")
	end
	self.m_Model = ent.DisplayModel
	if not util.IsValidProp(self.m_Model) then
		self.m_DrawGhost = false
	end
	self.m_Price = hook.Run("LookupEntityPrice", owner, self.EntityClass, ent)
	self.m_SpawnAngle = ent.SpawnAngle
	self.m_EntData = ent
end

function SWEP:PrimaryAttack()
	local nextTime = CurTime() + self.RefireTime
	self:SetNextPrimaryFire(nextTime)
	self:ShootEffects()
	self.m_HideGhost = nextTime
	if IsFirstTimePredicted() and IsValid(self.m_Ghost) then
		self.m_Ghost:SetNoDraw(true)
	end
end

function SWEP:Holster(w)
	BaseClass.Holster(self, w)
	if IsValid(self.m_Ghost) then
		self.m_Ghost:Remove()
	end
	return true
end

function SWEP:OnRemove()
	BaseClass.OnRemove(self)
	if IsValid(self.m_Ghost) then
		self.m_Ghost:Remove()
	end
end

function SWEP:_SpawnGhost()
	local ent = ClientsideModel(self.m_Model, RENDERGROUP_VIEWMODEL_TRANSLUCENT)
	if not IsValid(ent) then
		self.m_DrawGhost = false
		ErrorNoHalt(self.ClassName .. " failed to create client prop for '" .. self.m_Model .. "'!")
		return
	end
	self.m_Ghost = ent
	-- Positioning will happen next frame, so shove it somewhere that should be valid
	ent:SetPos(self:GetPos())
	ent:Spawn()
	ent:SetMaterial(WHITE_MAT)
	ent:SetColor(COLOUR_INVALID)
	ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
	-- Hide it for now
	ent:SetNoDraw(true)
	self.m_HideGhost = 0
end

function SWEP:Think()
	BaseClass.Think(self)
	if not self.m_DrawGhost then
		return
	end
	local ghost = self.m_Ghost
	if not IsValid(ghost) then
		self:_SpawnGhost()
		return
	end
	local now = CurTime()
	if self.m_HideGhost ~= nil then
		if self.m_HideGhost > now then
			return
		end
		self.m_Ghost:SetNoDraw(false)
		self.m_HideGhost = nil
	end

	local owner = self:GetOwner() --[[@as GPlayer]]
	local start = owner:GetShootPos()
	local aim = owner:GetAimVector()

	--- @type STrace
	local trace = {}
	trace.start = start
	trace.endpos = start + (aim * 1000)
	trace.filter = owner

	local tr = util.TraceLine(trace)
	--- @cast tr STraceResult

	local valid = tr.Hit
	if valid then
		valid = owner:CheckLimit(self.EntityClass)
	end

	if valid then
		ghost:SetColor(COLOUR_VALID)
	else
		ghost:SetColor(COLOUR_INVALID)
	end

	local spawnAngle = self.m_SpawnAngle
	local ang = Angle(0, owner:EyeAngles().yaw + 180, 0)
	if spawnAngle then
		if isfunction(spawnAngle) then
			ang = spawnAngle(tr)
		else
			ang = ang + spawnAngle
		end
	end
	ghost:SetPos(tr.HitPos)
	ghost:SetAngles(ang)
	-- Attempt to move the object so it sits flush
	local vFlushPoint = tr.HitPos - (tr.HitNormal * 512)
	vFlushPoint = ghost:NearestPoint(vFlushPoint)
	vFlushPoint = ghost:GetPos() - vFlushPoint
	vFlushPoint = tr.HitPos + vFlushPoint
	ghost:SetPos(vFlushPoint)
	-- I don't want to deal with TryFixPropPosition, so the ghost will occasionally be slightly wrong
end

local matScreen = Material("models/weapons/v_toolgun/screen")
local txBackground = surface.GetTextureID("models/weapons/v_toolgun/screen_bg")
local TEX_SIZE = 256

-- GetRenderTarget returns the texture if it exists, or creates it if it doesn't
local RTTexture = GetRenderTarget("GModToolgunScreen", TEX_SIZE, TEX_SIZE)

surface.CreateFont("GModToolScreen", {
	font = "Helvetica",
	size = 60,
	weight = 900
})

--- @param text string
--- @param x number
--- @param y number
local function drawText(text, x, y)
	surface.SetTextColor(0, 0, 0, 255)
	surface.SetTextPos(x + 3, y + 3)
	surface.DrawText(text)

	surface.SetTextColor(255, 255, 255, 255)
	surface.SetTextPos(x, y)
	surface.DrawText(text)
end

local function DrawScrollingText(text, y, texwide)
	surface.SetFont("GModToolScreen")
	local w, h = surface.GetTextSize(text)
	y = y - h / 2 -- Center text to y position

	if w <= texwide then
		local x = (texwide - w) / 2
		drawText(text, x, y)
		return
	end

	w = w + 64

	local x = (RealTime() * 100 % w) * -1
	while (x < texwide) do
		drawText(text, x, y)
		x = x + w
	end
end

--[[---------------------------------------------------------
	We use this opportunity to draw to the toolmode
		screen's rendertarget texture.
-----------------------------------------------------------]]
function SWEP:RenderScreen()
	-- Set the material of the screen to our render target
	matScreen:SetTexture("$basetexture", RTTexture)

	-- Set up our view for drawing to the texture
	render.PushRenderTarget(RTTexture)
	cam.Start2D()

	-- Background
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetTexture(txBackground)
	surface.DrawTexturedRect(0, 0, TEX_SIZE, TEX_SIZE)

	DrawScrollingText(string.FormatMoney(self.m_Price), 104, TEX_SIZE)

	cam.End2D()
	render.PopRenderTarget()
end
