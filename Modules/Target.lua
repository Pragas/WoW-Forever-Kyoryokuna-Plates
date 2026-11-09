-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The arrow above the current target, on enemies only: the game's own navigation arrow (atlas
-- "Navigation-Tracked-Arrow"), turned to point down, centered on the top edge of the health bar (or
-- just above the name, on enemies shown by name only). Its size is set by a slider; its colors are the
-- game's. The white border of the target's bar is done by HealthBar.lua. Allies get no arrow.

local _, ns = ...

local Target = ns.RegisterModule("Target", {})

local ARROW_ATLAS = "Navigation-Tracked-Arrow"
local ARROW_WIDTH, ARROW_HEIGHT = 14, 9

local function GetArrow(frame, data)
	if not data.arrow then
		local arrow = ns.GetOverlay(frame, data):CreateTexture(nil, "OVERLAY", nil, 7)
		arrow:SetAtlas(ARROW_ATLAS)
		-- The atlas points up; turned half a circle, it points down at the bar
		arrow:SetRotation(math.pi)
		data.arrow = arrow
	end
	return data.arrow
end

function Target.Update(frame, data)
	local settings = ns.db.target
	local container = frame.HealthBarsContainer
	-- Allies and dead units never get the arrow
	if not settings.arrow or not data.isTarget or data.side ~= "enemy" or data.isDead or not container then
		if data.arrow then data.arrow:Hide() end
		return
	end
	local arrow = GetArrow(frame, data)
	local scale = settings.arrowScale / 100
	local height = ARROW_HEIGHT * scale
	arrow:SetSize(ARROW_WIDTH * scale, height)
	arrow:ClearAllPoints()
	if ns.HasHealthBar(frame) then
		arrow:SetPoint("CENTER", container, "TOP", settings.arrowX, settings.arrowY)
	elseif frame.name then
		-- Enemies shown by name only: the arrow points down at the name instead, above the raid mark if
		-- there's one (the game shows the mark right over the name)
		local anchor = frame.name
		local mark = frame.RaidTargetFrame
		local marked = data.fake and data.fake.raidMark
			or (GetRaidTargetIndex and ns.Known(GetRaidTargetIndex(data.unit)))
		if mark and marked and ns.Known(mark:IsShown()) then
			anchor = mark
		end
		arrow:SetPoint("BOTTOM", anchor, "TOP", settings.arrowX, 1 + settings.arrowY)
	else
		arrow:Hide()
		return
	end
	arrow:Show()
end

Target.Layout = Target.Update
Target.TargetChanged = Target.Update

function Target.Removed(_, data)
	if data.arrow then data.arrow:Hide() end
end

-- A raid mark put on or taken off the target moves the arrow of name-only nameplates
ns.RegisterEvent("RAID_TARGET_UPDATE", function()
	ns.ForEachPlate(Target.Update)
end)
