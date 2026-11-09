-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The health percent of an enemy ("100%"), inside the right end of the bar by default, or anywhere
-- inside or outside it (Enemies page). White with an outline, in the font of the name with a size of its
-- own (never taller than the bar when inside it), and like the name it doesn't grow when the enemy is
-- selected.
-- The game's own health text is made invisible, so it never shows twice. In combat the health is
-- secret, so the percent comes from the game already scaled to 100 and goes straight to the text; the
-- addon never reads the number.

local _, ns = ...

local HealthText = ns.RegisterModule("HealthText", {})

-- Inside the bar: how far from its ends. Outside: the space between the bar (or the level) and the text.
local INSIDE_INSET = 4
local OUTSIDE_GAP = 2
-- Inside the bar, the font is at most this much smaller than the bar is high (room for the outline)
local INSIDE_FIT = 3
local GAME_TEXTS = {"TextString", "Text", "LeftText", "RightText"}

local function HideGameTexts(frame)
	local bar = ns.GetHealthBar(frame)
	if not bar then return end
	for _, key in ipairs(GAME_TEXTS) do
		local region = bar[key]
		if type(region) == "table" and region.SetAlpha then region:SetAlpha(0) end
	end
end

local function GetPercent(unit)
	if UnitHealthPercent and CurveConstants and CurveConstants.ScaleTo100 then
		return UnitHealthPercent(unit, true, CurveConstants.ScaleTo100)
	end
	local health, maxHealth = ns.Known(UnitHealth(unit)), ns.Known(UnitHealthMax(unit))
	if health and maxHealth and maxHealth > 0 then
		return health / maxHealth * 100
	end
end

local function SetPercent(text, data)
	-- Examples of the test mode carry their own health
	local percent = data.fake and data.fake.health or GetPercent(data.unit)
	if percent then
		text:SetText(string.format("%.0f%%", percent))
	else
		text:SetText("")
	end
end

local function GetText(frame, data)
	if not data.healthText then
		local text = ns.GetOverlay(frame, data):CreateFontString(nil, "OVERLAY")
		if text.SetIgnoreParentScale then text:SetIgnoreParentScale(true) end
		text:SetJustifyH("RIGHT")
		data.healthText = text
	end
	return data.healthText
end

-- Inside the bar (left, center or right) or outside it (left or right). Outside, when the level is on
-- the same side, the percent goes right after the level.
local function PlaceText(text, frame, data)
	local bar = ns.GetHealthBar(frame)
	local position = ns.db.enemy.healthTextPosition
	text:ClearAllPoints()
	if position == "INSIDE_LEFT" then
		text:SetPoint("LEFT", bar, "LEFT", INSIDE_INSET, 0)
		text:SetJustifyH("LEFT")
	elseif position == "INSIDE_CENTER" then
		text:SetPoint("CENTER", bar, "CENTER", 0, 0)
		text:SetJustifyH("CENTER")
	elseif position == "OUTSIDE_RIGHT" then
		local level = ns.GetOutsideLevel and ns.GetOutsideLevel(data, "RIGHT")
		text:SetPoint("LEFT", level or frame.HealthBarsContainer, "RIGHT", level and OUTSIDE_GAP or OUTSIDE_GAP + 2, 0)
		text:SetJustifyH("LEFT")
	elseif position == "OUTSIDE_LEFT" then
		local level = ns.GetOutsideLevel and ns.GetOutsideLevel(data, "LEFT")
		text:SetPoint("RIGHT", level or frame.HealthBarsContainer, "LEFT", level and -OUTSIDE_GAP or -OUTSIDE_GAP - 2, 0)
		text:SetJustifyH("RIGHT")
	else
		text:SetPoint("RIGHT", bar, "RIGHT", -INSIDE_INSET, 0)
		text:SetJustifyH("RIGHT")
	end
end

-- The percent's own space when it's shown outside the bar on that side, so the icons go after it
function ns.GetOutsideHealthText(data, sideName)
	local text = data.healthText
	if not text or not text:IsShown() then return nil end
	local position = ns.db.enemy.healthTextPosition
	if (sideName == "LEFT" and position == "OUTSIDE_LEFT") or (sideName == "RIGHT" and position == "OUTSIDE_RIGHT") then
		return text
	end
end

local function Hide(data)
	if data.healthText then data.healthText:Hide() end
end

function HealthText.Update(frame, data)
	HideGameTexts(frame)
	local bar = ns.GetHealthBar(frame)
	if data.side ~= "enemy" or not ns.HasHealthBar(frame) or not bar then
		Hide(data)
		return
	end
	local text = GetText(frame, data)
	-- The font of the name, in its own size (at 100%, the name's normal size)
	local base = data.nameFont
	local path = base and base.path or ns.FONT
	local enemy = ns.db.enemy
	local size = (base and base.size or 9) * ns.NAME_BASE.enemy * enemy.healthTextScale / 100
	-- Inside the bar, never taller than the bar
	if enemy.healthTextPosition:find("^INSIDE") then
		size = math.min(size, math.max(4, enemy.barHeight - INSIDE_FIT))
	end
	local flags = (base and base.flags or ""):find("SLUG") and "OUTLINE, SLUG" or "OUTLINE"
	text:SetFont(path, size, flags)
	PlaceText(text, frame, data)
	SetPercent(text, data)
	text:Show()
end

HealthText.Layout = HealthText.Update

function HealthText.Removed(_, data)
	Hide(data)
end

local function OnHealth(_, unit)
	local frame, data = ns.GetFrameForUnit(unit)
	if frame and data and data.unit and data.healthText and data.healthText:IsShown() then
		SetPercent(data.healthText, data)
	end
end

ns.RegisterEvent("UNIT_HEALTH", OnHealth)
ns.RegisterEvent("UNIT_MAXHEALTH", OnHealth)
