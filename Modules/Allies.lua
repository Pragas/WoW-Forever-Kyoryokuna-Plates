-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Allies in the player's group: the icon of their role (tank, healer, damage) next to the name, and a
-- small mana bar under the name of the healers. The role is the one the group finder or the leader
-- gave them. The mana goes straight from the game to the bar, so it also works when it's secret.
--
-- Inside dungeons and raids the game doesn't let addons change the nameplates of allies; there these
-- extras don't show, and only the game's own settings (name only, class color) apply, plus the size of
-- the names (through the game's shared font, see Modules\Name.lua).
--
-- Also here: clicks going through the names of allies, so clicking a name doesn't select the player.

local _, ns = ...

local Allies = ns.RegisterModule("Allies", {})

local ROLE_ATLASES = {
	TANK = "roleicon-tiny-tank",
	HEALER = "roleicon-tiny-healer",
	DAMAGER = "roleicon-tiny-dps",
}
-- The older role texture, if the atlases don't exist on this client
local ROLE_TEXTURE = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES"
local ROLE_COORDS = {
	TANK = {0, 19 / 64, 22 / 64, 41 / 64},
	HEALER = {20 / 64, 39 / 64, 1 / 64, 20 / 64},
	DAMAGER = {20 / 64, 39 / 64, 22 / 64, 41 / 64},
}
local ROLE_OPTIONS = {TANK = "roleTank", HEALER = "roleHealer", DAMAGER = "roleDamager"}

local MANA_GAP = 1
-- Between the health bar (or the name) and the icons beside it
local ICON_GAP = 2
local MANA_POWER = (Enum and Enum.PowerType and Enum.PowerType.Mana) or 0

local function AtlasExists(atlas)
	return C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) ~= nil
end

local function SetRoleTexture(texture, role)
	local atlas = ROLE_ATLASES[role]
	if atlas and AtlasExists(atlas) then
		texture:SetAtlas(atlas)
	else
		texture:SetTexture(ROLE_TEXTURE)
		texture:SetTexCoord(unpack(ROLE_COORDS[role]))
	end
end

local function GetRole(data)
	if not data.isPlayer or data.side ~= "allies" then return end
	if data.fake then return data.fake.role end
	local unit = data.unit
	if not (ns.Known(UnitInParty(unit)) or ns.Known(UnitInRaid(unit))) then return end
	local role = ns.Known(UnitGroupRolesAssigned(unit))
	if role and ROLE_OPTIONS[role] then return role end
end

-- Role icon ----------------------------------------------------------------------------------------

local function UpdateRoleIcon(frame, data, role)
	local settings = ns.db.allies
	local nameText = frame.name
	local show = settings.roleIcons and role and settings[ROLE_OPTIONS[role]] and nameText
	if not show then
		if data.roleIcon then data.roleIcon:Hide() end
		return
	end
	if not data.roleIcon then
		data.roleIcon = ns.GetOverlay(frame, data):CreateTexture(nil, "OVERLAY")
		-- Like the name, it keeps its size when the ally is selected
		if data.roleIcon.SetIgnoreParentScale then data.roleIcon:SetIgnoreParentScale(true) end
	end
	local icon = data.roleIcon
	SetRoleTexture(icon, role)
	icon:SetSize(settings.roleIconSize, settings.roleIconSize)
	icon:ClearAllPoints()
	-- With a health bar, left or right of the bar; name only, left or right of the name. Above the name
	-- in both cases.
	local container = frame.HealthBarsContainer
	local beside = (container and ns.HasHealthBar(frame)) and container or nameText
	if settings.roleIconPosition == "RIGHT" then
		icon:SetPoint("LEFT", beside, "RIGHT", ICON_GAP, 0)
	elseif settings.roleIconPosition == "TOP" then
		icon:SetPoint("BOTTOM", nameText, "TOP", 0, 2)
	else
		icon:SetPoint("RIGHT", beside, "LEFT", -ICON_GAP, 0)
	end
	icon:Show()
end

-- Healer mana --------------------------------------------------------------------------------------

local function UpdateManaValues(bar)
	local unit = bar.unit
	if not unit then return end
	bar:SetMinMaxValues(0, UnitPowerMax(unit, MANA_POWER))
	bar:SetValue(UnitPower(unit, MANA_POWER))
end

local function GetManaBar(frame, data)
	if not data.manaBar then
		local bar = CreateFrame("StatusBar", nil, ns.GetOverlay(frame, data))
		-- Like the name, it keeps its size when the ally is selected
		if bar.SetIgnoreParentScale then bar:SetIgnoreParentScale(true) end
		bar:SetStatusBarTexture(ns.BAR_TEXTURE)
		local color = PowerBarColor and PowerBarColor["MANA"]
		bar:SetStatusBarColor(color and color.r or 0, color and color.g or 0.44, color and color.b or 0.87)
		local background = bar:CreateTexture(nil, "BACKGROUND")
		background:SetAllPoints(bar)
		background:SetColorTexture(0, 0, 0, 0.7)
		bar:SetScript("OnEvent", function(self)
			ns.SafeCall(UpdateManaValues, self)
		end)
		data.manaBar = bar
	end
	return data.manaBar
end

local function HideManaBar(data)
	local bar = data.manaBar
	if bar then
		bar:UnregisterAllEvents()
		bar.unit = nil
		bar:Hide()
	end
end

local function UpdateManaBar(frame, data, role)
	local settings = ns.db.allies
	local nameText = frame.name
	if not settings.manaBar or role ~= "HEALER" or not nameText then
		HideManaBar(data)
		return
	end
	local bar = GetManaBar(frame, data)
	bar:ClearAllPoints()
	local container = frame.HealthBarsContainer
	if container and ns.HasHealthBar(frame) then
		-- With a health bar: right under it, just as wide, and growing with it when the ally is selected
		if bar.SetIgnoreParentScale then bar:SetIgnoreParentScale(false) end
		bar:SetPoint("TOPLEFT", container, "BOTTOMLEFT", 0, -MANA_GAP)
		bar:SetPoint("TOPRIGHT", container, "BOTTOMRIGHT", 0, -MANA_GAP)
		bar:SetHeight(settings.manaBarHeight)
	else
		-- Name only: under the name, which keeps its size when the ally is selected, and so does the bar
		if bar.SetIgnoreParentScale then bar:SetIgnoreParentScale(true) end
		local width = settings.manaBarWidth
		if settings.manaBarFollowName then
			width = ns.Known(nameText:GetStringWidth()) or width
		end
		bar:SetPoint("TOP", nameText, "BOTTOM", 0, -MANA_GAP)
		bar:SetSize(math.max(width, 10), settings.manaBarHeight)
	end

	bar:UnregisterAllEvents()
	if data.fake then
		-- Examples of the test mode carry their own mana
		bar.unit = nil
		bar:SetMinMaxValues(0, 100)
		bar:SetValue(data.fake.mana or 100)
	else
		bar.unit = data.unit
		bar:RegisterUnitEvent("UNIT_POWER_FREQUENT", data.unit)
		bar:RegisterUnitEvent("UNIT_MAXPOWER", data.unit)
		bar:RegisterUnitEvent("UNIT_DISPLAYPOWER", data.unit)
		UpdateManaValues(bar)
	end
	bar:Show()
end

-- Module -------------------------------------------------------------------------------------------

function Allies.Update(frame, data)
	local role = GetRole(data)
	UpdateRoleIcon(frame, data, role)
	UpdateManaBar(frame, data, role)
end

-- The game lays the nameplate out again (e.g. the health bar shown or hidden): the icons follow
Allies.Layout = Allies.Update

function Allies.Removed(_, data)
	if data.roleIcon then data.roleIcon:Hide() end
	HideManaBar(data)
end

local function RefreshAll()
	ns.ForEachPlate(Allies.Update)
end

ns.RegisterEvent("GROUP_ROSTER_UPDATE", RefreshAll)
ns.RegisterEvent("PLAYER_ROLES_ASSIGNED", RefreshAll)

-- Click-through ------------------------------------------------------------------------------------

-- The clickable area of the nameplates of allies is shrunk to nothing, so clicks go to the world behind
function Allies.ApplyClickThrough()
	if not (C_NamePlateManager and C_NamePlateManager.SetNamePlateHitTestInsets and Enum and Enum.NamePlateType) then
		return
	end
	ns.RunOutOfCombat("clickThrough", function()
		local inset = (ns.db.general.manageGameSettings and ns.db.allies.clickThrough) and 10000 or 0
		C_NamePlateManager.SetNamePlateHitTestInsets(Enum.NamePlateType.Friendly, inset, inset, inset, inset)
	end)
end
