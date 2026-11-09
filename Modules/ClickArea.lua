-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The area of each nameplate that selects the unit when clicked. On this client it's an area of its
-- own, which the game places around the bar and the name where it lays them out. This addon moves the
-- bar and the name, so it places that area itself, over what's really on the screen:
--   - enemies (and allies with a health bar): around the bar and the name above it;
--   - name-only allies: around the name;
--   - allies with "click through" on: an area of no size, so clicks always go through to the world.
-- The game only lets this change at certain moments (it says when, and that's checked first).

local _, ns = ...

local ClickArea = ns.RegisterModule("ClickArea", {})

-- Around the health bar: a little to each side, the name above it and some room under it
local BAR_LEFT, BAR_RIGHT, BAR_TOP, BAR_BOTTOM = 9, 9, 24, 16
-- The level and the health percent, when they sit outside the bar, can be clicked too
local LEVEL_ROOM = 21
local PERCENT_ROOM = 28

local function OutsideRoom(data, sideName)
	local room = 0
	if ns.GetOutsideLevel and ns.GetOutsideLevel(data, sideName) then room = room + LEVEL_ROOM end
	if ns.GetOutsideHealthText and ns.GetOutsideHealthText(data, sideName) then room = room + PERCENT_ROOM end
	return room
end
-- Around the name of name-only nameplates
local NAME_PADDING = 4

local function GetArea(nameplate, data)
	if not data.clickArea then
		data.clickArea = CreateFrame("Frame", nil, nameplate)
	end
	return data.clickArea
end

function ClickArea.Update(frame, data)
	-- The examples of the test mode aren't real nameplates
	if data.fake then return end
	local nameplate = frame:GetParent()
	if type(nameplate) ~= "table" or not (nameplate.CanChangeHitTestPoints and nameplate.SetAllHitTestPoints) then return end
	local ok, canChange = pcall(nameplate.CanChangeHitTestPoints, nameplate)
	if not ok or not ns.Known(canChange) then
		-- Not now (e.g. in combat): all the nameplates get their area again when the combat ends
		ns.RunOutOfCombat("clickAreas", function()
			ns.ForEachPlate(ClickArea.Update)
		end)
		return
	end

	local area = GetArea(nameplate, data)
	local container = frame.HealthBarsContainer
	area:ClearAllPoints()
	if data.side == "allies" and ns.db.allies.clickThrough and ns.db.general.manageGameSettings then
		area:SetPoint("TOPLEFT", frame, "CENTER", 0, 0)
		area:SetPoint("BOTTOMRIGHT", frame, "CENTER", 0, 0)
	elseif container and ns.HasHealthBar(frame) then
		area:SetPoint("TOPLEFT", container, "TOPLEFT", -BAR_LEFT - OutsideRoom(data, "LEFT"), BAR_TOP)
		area:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", BAR_RIGHT + OutsideRoom(data, "RIGHT"), -BAR_BOTTOM)
	elseif frame.name then
		area:SetPoint("TOPLEFT", frame.name, "TOPLEFT", -NAME_PADDING, NAME_PADDING)
		area:SetPoint("BOTTOMRIGHT", frame.name, "BOTTOMRIGHT", NAME_PADDING, -NAME_PADDING)
	else
		return
	end
	pcall(nameplate.SetAllHitTestPoints, nameplate, area)
end

ClickArea.Layout = ClickArea.Update
