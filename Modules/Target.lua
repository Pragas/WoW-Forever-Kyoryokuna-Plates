-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The arrow of the current target, on enemies only: the game's own navigation arrow (atlas
-- "Navigation-Tracked-Arrow"), turned to point at the target. Where it goes (Target page):
--   - above (default): pointing down, centered on the top edge of the health bar (or just above the
--     name, on enemies shown by name only);
--   - left, right or both sides: on the left or right edge of the health bar (or the name), pointing at
--     it, half inside and half outside, like the arrow above on the top edge.
-- Its size and offsets are set by sliders; its colors are the game's. The white border of the target's
-- bar is done by HealthBar.lua. Allies get no arrow.

local _, ns = ...

local Target = ns.RegisterModule("Target", {})

local ARROW_ATLAS = "Navigation-Tracked-Arrow"
local ARROW_WIDTH, ARROW_HEIGHT = 14, 9
-- The atlas points up; turned this much (counterclockwise) it points down, right or left
local POINT_DOWN, POINT_RIGHT, POINT_LEFT = math.pi, -math.pi / 2, math.pi / 2

local function GetArrow(frame, data, key)
	if not data[key] then
		local arrow = ns.GetOverlay(frame, data):CreateTexture(nil, "OVERLAY", nil, 7)
		arrow:SetAtlas(ARROW_ATLAS)
		data[key] = arrow
	end
	return data[key]
end

local function HideArrows(data)
	if data.arrow then data.arrow:Hide() end
	if data.arrow2 then data.arrow2:Hide() end
end

local function IsShown(region)
	return type(region) == "table" and region.IsShown and ns.Known(region:IsShown()) and true or false
end

-- Above: pointing down at the bar, or at the name (above the raid mark there, if there's one: the game
-- shows the mark right over the name)
local function PlaceAbove(arrow, frame, data, settings, scale)
	arrow:SetRotation(POINT_DOWN)
	arrow:SetSize(ARROW_WIDTH * scale, ARROW_HEIGHT * scale)
	arrow:ClearAllPoints()
	if ns.HasHealthBar(frame) then
		arrow:SetPoint("CENTER", frame.HealthBarsContainer, "TOP", settings.arrowX, settings.arrowY)
		return true
	end
	if not frame.name then return false end
	local anchor = frame.name
	local mark = frame.RaidTargetFrame
	local marked = data.fake and data.fake.raidMark
		or (GetRaidTargetIndex and ns.Known(GetRaidTargetIndex(data.unit)))
	if mark and marked and IsShown(mark) then
		anchor = mark
	end
	arrow:SetPoint("BOTTOM", anchor, "TOP", settings.arrowX, 1 + settings.arrowY)
	return true
end

-- On the left or right edge of the bar (or the name), pointing at it: centered on that edge, half inside
-- and half outside, just like the arrow above sits on the top edge. "Left / right" moves it away from
-- the bar (or in, with a negative value), on each side alike; "Down / up" moves it up or down.
local function PlaceSide(arrow, frame, data, side, settings, scale)
	-- The game turns the picture about its middle, in the same box, so the box keeps its size
	arrow:SetRotation(side == "LEFT" and POINT_RIGHT or POINT_LEFT)
	arrow:SetSize(ARROW_WIDTH * scale, ARROW_HEIGHT * scale)
	local anchor = ns.HasHealthBar(frame) and frame.HealthBarsContainer or frame.name
	if not anchor then return false end
	local away = side == "LEFT" and -settings.arrowX or settings.arrowX
	arrow:ClearAllPoints()
	arrow:SetPoint("CENTER", anchor, side, away, settings.arrowY)
	return true
end

function Target.Update(frame, data)
	local settings = ns.db.target
	-- Allies and dead units never get the arrow
	if not settings.arrow or not data.isTarget or data.side ~= "enemy" or data.isDead or not frame.HealthBarsContainer then
		HideArrows(data)
		return
	end
	local scale = settings.arrowScale / 100
	local position = settings.arrowPosition
	local first = GetArrow(frame, data, "arrow")
	local placed
	if position == "LEFT" or position == "RIGHT" then
		placed = PlaceSide(first, frame, data, position, settings, scale)
	elseif position == "BOTH" then
		placed = PlaceSide(first, frame, data, "LEFT", settings, scale)
	else
		placed = PlaceAbove(first, frame, data, settings, scale)
	end
	first:SetShown(placed and true or false)
	-- Both sides: a second arrow on the right
	if position == "BOTH" and placed then
		local second = GetArrow(frame, data, "arrow2")
		second:SetShown(PlaceSide(second, frame, data, "RIGHT", settings, scale) and true or false)
	elseif data.arrow2 then
		data.arrow2:Hide()
	end
end

Target.Layout = Target.Update
Target.TargetChanged = Target.Update

function Target.Removed(_, data)
	HideArrows(data)
end

-- A raid mark put on or taken off the target moves the arrow above a name-only nameplate
ns.RegisterEvent("RAID_TARGET_UPDATE", function()
	ns.ForEachPlate(Target.Update)
end)
