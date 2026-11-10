-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The game's raid mark (skull, cross...), where the Raid Marks page says, for enemies and allies apart:
--   - above (default), centered above the name:
--       enemies: above the name, or above the player's debuffs when the enemy shows some (they sit above
--       the name too);
--       allies: above the name, or above the role icon when that's above the name;
--   - left or right: beside the health bar (or beside the name when only the name shows), past
--     whatever else is shown on that side (the level or the health percent outside the bar, the quest
--     "!", the elite dragon, the role icon), so it never covers them.
-- Its size is an option too, for enemies and allies apart.
-- The game keeps deciding when the mark shows; the addon only places it, again whenever the game lays
-- the nameplate out, a mark changes, the debuffs change or the icons beside the bar change.
-- Inside dungeons and raids the game protects the nameplates of allies: there their mark stays where the
-- game puts it.

local _, ns = ...

local RaidMark = ns.RegisterModule("RaidMark", {})

local GAP = 2
-- Between the name and the health bar (Modules\Name.lua)
local NAME_GAP = 4

local function IsShown(region)
	return type(region) == "table" and region.IsShown and ns.Known(region:IsShown()) and true or false
end

-- The outermost thing shown on one side of the health bar (or of the name, when only the name shows),
-- which the mark goes next to
local function OutermostOnSide(frame, data, sideName)
	local container = frame.HealthBarsContainer
	local withBar = container and ns.HasHealthBar(frame)
	local anchor = withBar and container or frame.name
	if data.side == "allies" then
		-- The role icon, when it's on this side (beside the bar, or beside the name)
		if IsShown(data.roleIcon) and ns.db.allies.roleIconPosition == sideName then anchor = data.roleIcon end
		return anchor
	end
	if not withBar then return anchor end
	-- Enemies: the level and the health percent outside the bar (the percent comes after the level)
	local outside = (ns.GetOutsideHealthText and ns.GetOutsideHealthText(data, sideName))
		or (ns.GetOutsideLevel and ns.GetOutsideLevel(data, sideName))
	if outside then anchor = outside end
	if sideName == "LEFT" then
		-- Then the quest "!" and the game's elite dragon (Modules\LeftIcons.lua)
		if IsShown(data.questIcon) then anchor = data.questIcon end
		local classification = frame.ClassificationFrame
		if IsShown(classification) and IsShown(classification.classificationIndicator) then anchor = classification end
	end
	return anchor
end

-- Above the name: what the mark sits on, and how high above it
local function GetTopAnchor(frame, data)
	local nameText = frame.name
	if data.side == "allies" then
		local icon = data.roleIcon
		if icon and icon:IsShown() and ns.db.allies.roleIconPosition == "TOP" then
			return icon, "TOP", 0, GAP
		end
		return nameText, "TOP", 0, GAP
	end
	-- Enemies with debuffs: above the row of icons, which starts this high above the health bar
	local container = frame.HealthBarsContainer
	if container and ns.HasHealthBar(frame) and ns.HasShownDebuffs and ns.HasShownDebuffs(data) then
		local settings = ns.db.enemy
		local nameHeight = ns.Known(nameText:GetStringHeight()) or 12
		local height = math.max(settings.debuffY + settings.debuffSize, NAME_GAP + nameHeight)
		return container, "TOP", 0, height + GAP
	end
	return nameText, "TOP", 0, GAP
end

-- Where the mark goes: its point, the region it's placed on, that region's point, and the offsets
local function GetPlace(frame, data)
	local settings = ns.db.raidMarks
	local position = data.side == "allies" and settings.allyPosition or settings.enemyPosition
	if position == "LEFT" then
		return "RIGHT", OutermostOnSide(frame, data, "LEFT"), "LEFT", -GAP, 0
	elseif position == "RIGHT" then
		return "LEFT", OutermostOnSide(frame, data, "RIGHT"), "RIGHT", GAP, 0
	end
	local anchor, point, x, y = GetTopAnchor(frame, data)
	return "BOTTOM", anchor, point, x, y
end

function RaidMark.Update(frame, data)
	local markFrame = frame.RaidTargetFrame
	if type(markFrame) ~= "table" or not frame.name then return end
	if data.side ~= "enemy" and data.side ~= "allies" then return end
	local point, anchor, anchorPoint, x, y = GetPlace(frame, data)
	-- Its size (Raid Marks page). Like the nameplate, it's bigger on the target.
	local settings = ns.db.raidMarks
	local size = data.side == "allies" and settings.allySize or settings.enemySize
	markFrame:SetSize(size, size)
	markFrame:ClearAllPoints()
	markFrame:SetPoint(point, anchor, anchorPoint, x, y)
	local icon = markFrame.RaidTargetIcon
	if type(icon) == "table" then
		icon:ClearAllPoints()
		icon:SetAllPoints(markFrame)
	end
end

RaidMark.Layout = RaidMark.Update

local function RefreshAll()
	ns.ForEachPlate(RaidMark.Update)
end

-- A mark set or cleared: the game places it again
ns.RegisterEvent("RAID_TARGET_UPDATE", RefreshAll)

-- The debuffs of an enemy changed: the mark goes above or back down to the name. The game updates its
-- icons on the same event, so this waits for it.
ns.RegisterEvent("UNIT_AURA", function(_, unit)
	local frame, data = ns.GetFrameForUnit(unit)
	if not (frame and data and data.side == "enemy") then return end
	C_Timer.After(0, function()
		local current, currentData = ns.GetFrameForUnit(unit)
		if current and currentData then ns.SafeCall(RaidMark.Update, current, currentData) end
	end)
end)
