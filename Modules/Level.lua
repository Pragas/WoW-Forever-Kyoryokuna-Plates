-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The level, as a plain number in the color of its difficulty (grey, green, yellow, orange, red), or a
-- skull when the game hides the level. It sits outside the health bar (right by default, or left) or
-- inside it (left, center or right). The art of the game's level badge is made invisible; the game
-- keeps managing the badge as usual. Allies don't show a level. It has the font of the name in its own size,
-- and like the name it doesn't grow when the enemy is selected.

local _, ns = ...

local Level = ns.RegisterModule("Level", {})

local SKULL = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull"
-- The level has the font and the size of the name, like the health percent (100% = the name's normal
-- size); its space is this many times as wide as the font is big (room for two digits), and the skull
-- this many times as big
local SIDE_WIDTH_RATIO = 1.7
local SKULL_RATIO = 1.6
-- Inside the bar, the font is at most this much smaller than the bar is high (room for the outline)
local INSIDE_FIT = 3
local BADGE_PARTS = {"playerLevelDiffIcon", "playerLevelDiffText", "highLevelTexture", "selectedBorder"}

-- Each position: the point of the level that's held, the point of the bar it's held to, the distance,
-- and which side of its own space the number leans to
local POSITIONS = {
	OUTSIDE_RIGHT = {"LEFT", "RIGHT", 4, "LEFT"},
	OUTSIDE_LEFT = {"RIGHT", "LEFT", -4, "RIGHT"},
	INSIDE_LEFT = {"LEFT", "LEFT", 3, "LEFT"},
	INSIDE_CENTER = {"CENTER", "CENTER", 0, "CENTER"},
	INSIDE_RIGHT = {"RIGHT", "RIGHT", -3, "RIGHT"},
}
ns.LEVEL_POSITIONS = POSITIONS

local function HideBadgeArt(levelFrame)
	for _, key in ipairs(BADGE_PARTS) do
		local region = levelFrame[key]
		if type(region) == "table" and region.SetAlpha then region:SetAlpha(0) end
	end
end

local function GetSide(frame, data)
	if not data.levelSide then
		local container = frame.HealthBarsContainer
		local holder = CreateFrame("Frame", nil, container)
		-- Like the name and the health percent, it doesn't grow when the enemy is selected
		if holder.SetIgnoreParentScale then holder:SetIgnoreParentScale(true) end
		holder:SetFrameLevel(container:GetFrameLevel() + 6)
		local text = holder:CreateFontString(nil, "OVERLAY")
		text:SetFont(ns.FONT, 9, "OUTLINE")
		text:SetShadowOffset(1, -1)
		text:SetShadowColor(0, 0, 0, 1)
		local skull = holder:CreateTexture(nil, "OVERLAY")
		skull:SetTexture(SKULL)
		data.levelSide = {holder = holder, text = text, skull = skull}
	end
	return data.levelSide
end

local function PlaceSide(frame, side, data)
	local enemy = ns.db.enemy
	local position = POSITIONS[enemy.levelPosition] or POSITIONS.OUTSIDE_RIGHT
	local point, relativePoint, x, lean = position[1], position[2], position[3], position[4]
	local holder = side.holder
	holder:ClearAllPoints()
	holder:SetPoint(point, frame.HealthBarsContainer, relativePoint, x, 0)
	side.text:ClearAllPoints()
	side.text:SetPoint(lean, holder, lean, 0, 0)
	side.text:SetJustifyH(lean)
	-- The font of the name in its own size (Enemies page); inside the bar, never taller than the bar
	local base = data.nameFont
	local size = (base and base.size or 9) * ns.NAME_BASE.enemy * enemy.levelScale / 100
	if enemy.levelPosition:find("^INSIDE") then
		size = math.min(size, math.max(4, enemy.barHeight - INSIDE_FIT))
	end
	local flags = (base and base.flags or ""):find("SLUG") and "OUTLINE, SLUG" or "OUTLINE"
	side.text:SetFont(base and base.path or ns.FONT, size, flags)
	side.skull:SetSize(size * SKULL_RATIO, size * SKULL_RATIO)
	-- Its space grows with it, so what comes after it outside the bar keeps its distance
	holder:SetSize(size * SIDE_WIDTH_RATIO, size + 6)
	side.skull:ClearAllPoints()
	side.skull:SetPoint(lean, holder, lean, 0, 0)
end

-- The level's own space when it's shown outside the bar on that side, so what comes next on that side
-- (the health percent, the icons) goes after it
function ns.GetOutsideLevel(data, sideName)
	local side = data.levelSide
	if not side or not side.holder:IsShown() then return nil end
	local position = ns.db.enemy.levelPosition
	if (sideName == "LEFT" and position == "OUTSIDE_LEFT") or (sideName == "RIGHT" and position == "OUTSIDE_RIGHT") then
		return side.holder
	end
end

local function HideSide(data)
	if data.levelSide then data.levelSide.holder:Hide() end
end

-- Whether the game itself would show a level for this unit
local function GameShowsLevel(levelFrame, unit)
	if levelFrame and levelFrame.ShouldDisplay then
		local ok, shown = pcall(levelFrame.ShouldDisplay, levelFrame, unit)
		if ok then
			shown = ns.Known(shown)
			if shown ~= nil then return shown end
		end
	end
	return true
end

-- The usual difficulty colors, by how many levels the unit is above the player
local function DifficultyColor(level)
	if GetCreatureDifficultyColor then
		local color = GetCreatureDifficultyColor(level)
		if color then return color.r, color.g, color.b end
	end
	local difference = level - (ns.Known(UnitLevel("player")) or level)
	if difference >= 5 then return 1, 0.1, 0.1 end
	if difference >= 3 then return 1, 0.5, 0.25 end
	if difference >= -2 then return 1, 1, 0 end
	if difference >= -8 then return 0.25, 0.75, 0.25 end
	return 0.5, 0.5, 0.5
end

local function GetLevelColor(levelFrame, data, level)
	-- Examples of the test mode
	if data.fake then return DifficultyColor(level) end
	local unit = data.unit
	if not ns.Known(UnitCanAttack("player", unit)) then
		return 1, 0.82, 0
	end
	local playerLevel = ns.Known(UnitEffectiveLevel("player"))
	if levelFrame and levelFrame.GetDifficultyColor and playerLevel then
		local ok, color = pcall(levelFrame.GetDifficultyColor, levelFrame, level - playerLevel)
		if ok and color and color.GetRGB then return color:GetRGB() end
	end
	return DifficultyColor(level)
end

function Level.Update(frame, data)
	local levelFrame = frame.PlayerLevelDiffFrame
	if type(levelFrame) ~= "table" then levelFrame = nil end
	if levelFrame then HideBadgeArt(levelFrame) end

	local unit = data.unit
	if data.side ~= "enemy" or not ns.db.enemy.showLevel or not ns.HasHealthBar(frame)
		or not GameShowsLevel(levelFrame, unit) then
		HideSide(data)
		return
	end
	local level
	if data.fake then
		level = data.fake.level
	else
		level = ns.Known(UnitEffectiveLevel(unit)) or ns.Known(UnitLevel(unit))
	end
	if level == nil then
		HideSide(data)
		return
	end

	local side = GetSide(frame, data)
	PlaceSide(frame, side, data)
	if level <= 0 then
		side.text:Hide()
		side.skull:Show()
	else
		side.text:SetText(level)
		side.text:SetTextColor(GetLevelColor(levelFrame, data, level))
		side.text:Show()
		side.skull:Hide()
	end
	side.holder:Show()
end

Level.Layout = Level.Update

function Level.Removed(_, data)
	HideSide(data)
end

ns.RegisterEvent("UNIT_LEVEL", function(_, unit)
	local frame, data = ns.GetFrameForUnit(unit)
	if frame and data and data.unit then
		Level.Update(frame, data)
	end
end)
