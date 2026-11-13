-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The icons to the left of an enemy's health bar, in a row going left from the bar:
--   1. the yellow "!" of mobs that belong to one of the player's active quests, right next to the bar
--      (Questie's sword or bag, when Questie is on, shows at its own place further left);
--   2. the game's mark of an elite or a rare (the gold dragon of elites, the silver dragon of rare elites,
--      the round medal with a star of rares), moved here from where the game puts it.
-- Only the icons that are shown take a place, so the first one is always next to the bar. The game
-- keeps deciding when its mark shows. (The raid mark goes where the Raid Marks page says:
-- Modules\RaidMark.lua.)

local _, ns = ...

local LeftIcons = ns.RegisterModule("LeftIcons", {})

local QUEST_ATLAS = "smallquestbang"
local QUEST_SIZE = 22
-- The "!" is centered this far left of the bar, right next to it. Questie puts its own icon (a sword or
-- a bag) at a fixed place further left, so both show side by side.
local QUEST_CENTER = -8
local GAP = 2

local function IsQuestUnit(data)
	if data.isPlayer or data.side ~= "enemy" then return false end
	if data.fake then return data.fake.quest and true or false end
	if not (C_QuestLog and C_QuestLog.UnitIsRelatedToActiveQuest) then return false end
	if C_Secrets and C_Secrets.ShouldUnitIdentityBeSecret and ns.Known(C_Secrets.ShouldUnitIdentityBeSecret(data.unit)) then
		return false
	end
	return ns.Known(C_QuestLog.UnitIsRelatedToActiveQuest(data.unit)) == true
end

local function GetQuestIcon(frame, data)
	if not data.questIcon then
		local icon = ns.GetOverlay(frame, data):CreateTexture(nil, "OVERLAY")
		icon:SetAtlas(QUEST_ATLAS)
		icon:SetSize(QUEST_SIZE, QUEST_SIZE)
		data.questIcon = icon
	end
	return data.questIcon
end

local function IsShown(region)
	return region and ns.Known(region:IsShown()) and true or false
end

-- Places a region with its right side a gap left of the anchor, and returns it as the next anchor
local function Chain(region, anchor, anchorPoint)
	region:ClearAllPoints()
	region:SetPoint("RIGHT", anchor, anchorPoint, -GAP, 0)
	return region, "LEFT"
end

function LeftIcons.Update(frame, data)
	local container = frame.HealthBarsContainer
	if data.side ~= "enemy" or not ns.HasHealthBar(frame) then
		if data.questIcon then data.questIcon:Hide() end
		return
	end
	data.placingIcons = true
	-- The level or the health percent shown outside on the left come first; the icons go after them
	local outside = (ns.GetOutsideHealthText and ns.GetOutsideHealthText(data, "LEFT"))
		or (ns.GetOutsideLevel and ns.GetOutsideLevel(data, "LEFT"))
	local anchor, anchorPoint = outside or container, "LEFT"

	if ns.db.enemy.questIcon and IsQuestUnit(data) then
		local icon = GetQuestIcon(frame, data)
		icon:ClearAllPoints()
		if outside then
			icon:SetPoint("RIGHT", outside, "LEFT", 0, 0)
		else
			icon:SetPoint("CENTER", container, "LEFT", QUEST_CENTER, 0)
		end
		icon:Show()
		anchor, anchorPoint = icon, "LEFT"
	elseif data.questIcon then
		data.questIcon:Hide()
	end

	-- The dragon (or the medal) can be hidden (Enemies page): made invisible, so the game keeps managing
	-- it, and then it takes no place in the row. It's placed in the row even while the game hides it: the
	-- game may show it later (a new unit on the nameplate, a new classification, a raid mark gone), and
	-- left where the game ties it, beside the raid mark, it came up over the health percent on the right
	-- of the bar when the raid marks go there. (Engine\Hooks.lua places the icons again when the game
	-- shows or hides it, so a raid mark on the left goes past it.)
	local classification = frame.ClassificationFrame
	if classification then
		local showDragon = ns.db.enemy.eliteIcon
		pcall(classification.SetAlpha, classification, showDragon and 1 or 0)
		if showDragon then Chain(classification, anchor, anchorPoint) end
	end
	data.placingIcons = false
	-- A raid mark on the left goes past these icons, so it follows when they show or hide
	if ns.RaidMark and ns.RaidMark.Update then ns.RaidMark.Update(frame, data) end
end

LeftIcons.Layout = LeftIcons.Update

function LeftIcons.Removed(_, data)
	if data.questIcon then data.questIcon:Hide() end
end

local function RefreshAll()
	ns.ForEachPlate(LeftIcons.Update)
end

-- The quest log changes often in a row, so the icons are checked once, a moment after the last change
local scheduled = false
local function ScheduleRefresh()
	if scheduled then return end
	scheduled = true
	C_Timer.After(0.5, function()
		scheduled = false
		ns.SafeCall(RefreshAll)
	end)
end
ns.RegisterEvent("QUEST_LOG_UPDATE", ScheduleRefresh)
ns.RegisterEvent("UNIT_QUEST_LOG_CHANGED", ScheduleRefresh)
