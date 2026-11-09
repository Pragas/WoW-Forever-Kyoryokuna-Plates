-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The game's raid mark (skull, cross...) always over the head, centered above the name:
--   - enemies: above the name, or above the player's debuffs when the enemy shows some (they sit above
--     the name too);
--   - allies: above the name, or above the role icon when that's above the name.
-- The game would put it left of the health bar. It keeps deciding when the mark shows; the addon only
-- places it, again whenever the game lays the nameplate out, a mark changes or the debuffs change.

local _, ns = ...

local RaidMark = ns.RegisterModule("RaidMark", {})

local MARK_SIZE = 20
local GAP = 2
-- Between the name and the health bar (Modules\Name.lua)
local NAME_GAP = 4

local function GetAnchor(frame, data)
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

function RaidMark.Update(frame, data)
	local markFrame = frame.RaidTargetFrame
	if type(markFrame) ~= "table" or not frame.name then return end
	if data.side ~= "enemy" and data.side ~= "allies" then return end
	local anchor, point, x, y = GetAnchor(frame, data)
	markFrame:SetSize(MARK_SIZE, MARK_SIZE)
	markFrame:ClearAllPoints()
	markFrame:SetPoint("BOTTOM", anchor, point, x, y)
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
