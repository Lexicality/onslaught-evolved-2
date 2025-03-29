--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

--- @class OSEClassDefinition2 : OSEClassDefinition
--- @field Class string
--- @field ClassID integer

--- @class OSEClassQuickMenu : DScrollPanel
--- @field m_LastClassID integer
--- @field m_Items OSEClassQuickMenuItem[]
local PANEL = {}

function PANEL:Init()
	local heading = self:Add("DLabel")
	--- @cast heading DLabel
	heading:SetFont("DermaHeading")
	heading:SetText("#ose.classmenu.quick_heading")
	heading:SetBright(true)
	heading:Dock(TOP)
	heading:DockMargin(0, 0, 0, 5)

	local desc = self:Add("DLabel")
	--- @cast desc DLabel
	-- Silly me, I thought this was automatic
	local text = language.GetPhrase("#ose.classmenu.quick_description")
	local binding = input.LookupBinding("gm_showteam")
	desc:SetText(string.format(text, binding))
	desc:SetWrap(true)
	desc:SetBright(true)
	desc:SetAutoStretchVertical(true)
	desc:Dock(TOP)
	desc:DockMargin(0, 0, 0, 5)

	--- @type {[string]: OSEClassDefinition2}
	local allClasses = list.Get("OSEClasses")
	--- @type OSEClassDefinition2[]
	local selectableClasses = {}
	for class, data in pairs(allClasses) do
		if data.Selectable then
			data.Class = class
			data.ClassID = util.NetworkStringToID(class)
			selectableClasses[#selectableClasses + 1] = data
		end
	end
	table.SortByMember(selectableClasses, "Name")

	local classID = LocalPlayer():GetTargetClassID()
	self.m_LastClassID = classID

	local items = {}
	for _, data in ipairs(selectableClasses) do
		local item = self:Add("OSEClassQuickMenuItem")
		--- @cast item OSEClassQuickMenuItem
		items[#items + 1] = item
		item:SetupClass(data, classID)
		item:Dock(TOP)
		item:DockPadding(5, 5, 5, 5)
		item:DockMargin(0, 0, 0, 10)
	end
	self:InvalidateLayout(true)
	self.m_Items = items
end

function PANEL:Think()
	local classID = LocalPlayer():GetTargetClassID()
	if self.m_LastClassID ~= classID then
		self.m_LastClassID = classID
		for _, pnl in ipairs(self.m_Items) do
			pnl:CheckButton(classID)
		end
	end
end

vgui.Register("OSEClassQuickMenu", PANEL, "DScrollPanel")

--- @class OSEClassQuickMenuItem : DPanel
--- @field m_Button GPanel
--- @field m_ClassID integer
--- @field m_Name string
--- @diagnostic disable-next-line: redefined-local
local PANEL = {}

--- @param classData OSEClassDefinition2
--- @param currentClassID integer
function PANEL:SetupClass(classData, currentClassID)
	self.m_ClassID = classData.ClassID
	self.m_Name = classData.Name

	local heading = self:Add("DLabel")
	--- @cast heading DLabel
	heading:SetFont("DermaHeading")
	heading:SetText(classData.Name)
	heading:SetDark(true)
	self.m_Heading = heading

	local image = self:Add("DImage")
	--- @cast image DImage
	image:SetImage(classData.Icon)
	self.m_Image = image

	local desc = self:Add("DLabel")
	--- @cast desc DLabel
	desc:SetText(classData.Description)
	desc:SetWrap(true)
	desc:SetDark(true)
	desc:SetAutoStretchVertical(true)
	self.m_Desc = desc

	local button = self:Add("DButton")
	--- @cast button DButton
	button:SetConsoleCommand("ose_chooseclass", classData.Class)
	self.m_Button = button
	self:CheckButton(currentClassID)
	self:InvalidateLayout(true)
end

local ICON_SIZE = 128 / 2
local INFO_PANEL_MARGIN = 5
function PANEL:PerformLayout()
	-- I'm not sure why this needs to called *before* doing things that adjust
	-- the size of the children, but it does, so call it.
	self:SizeToChildren(false, true)

	local lp, tp, rp, bp = self:GetDockPadding()

	local availableWidth = self:GetWide()
	local textLeft = lp + ICON_SIZE + INFO_PANEL_MARGIN

	local heading = self.m_Heading
	heading:SizeToContents()
	heading:SetPos(textLeft, tp)

	local image = self.m_Image
	image:SetSize(ICON_SIZE, ICON_SIZE)
	image:SetPos(lp, tp)

	local desc = self.m_Desc
	local descTop = tp + heading:GetTall() + INFO_PANEL_MARGIN

	desc:SetPos(textLeft, descTop)
	desc:SetWidth(availableWidth - textLeft - rp)

	local button = self.m_Button
	local buttonMinTop = tp + ICON_SIZE
	-- The description might end up being taller than the icon, so make sure the
	-- button accounts for that
	local buttonTop = math.max(buttonMinTop, descTop + desc:GetTall())

	button:SetPos(lp, buttonTop + INFO_PANEL_MARGIN)
	button:SetWide(availableWidth - rp - lp)
end

--- @param currentClassID integer
function PANEL:CheckButton(currentClassID)
	local button = self.m_Button
	if not IsValid(button) then return end
	if currentClassID == self.m_ClassID then
		button:SetText("#ose.classmenu.selected")
		button:SetEnabled(false)
	else
		local text = language.GetPhrase("ose.classmenu.choose")
		local name = language.GetPhrase(self.m_Name)
		button:SetText(string.format(text, name))
		button:SetEnabled(true)
	end
end

vgui.Register("OSEClassQuickMenuItem", PANEL, "DPanel")
