-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Who an enemy is after, in a small text under its nameplate: the first name of its target, players in
-- their class color:
-- under the right end of the health bar, or of the cast bar while it casts (always on the right).
-- The names go straight from the game to the text, so it also works when they're secret.

local _, ns = ...

local TargetText = ns.RegisterModule("TargetText", {})

local TEXT_SIZE = 11
-- Below the bar: room for its one-pixel border, and a little more, so the text never touches the border
-- when the game rounds its place to the pixel as the nameplate moves
local TEXT_GAP = 3

local function GetText(frame, data)
	if not data.targetText then
		local text = ns.GetOverlay(frame, data):CreateFontString(nil, "OVERLAY")
		text:SetFont(ns.FONT, TEXT_SIZE, "OUTLINE")
		text:SetShadowOffset(1, -1)
		text:SetShadowColor(0, 0, 0, 1)
		data.targetText = text
	end
	return data.targetText
end

local function ClassColor(class)
	local r, g, b = ns.GetClassColor(class)
	return r or 1, g or 1, b or 1
end

local function IsCasting(castBar)
	return castBar and castBar:IsShown() and (castBar.casting or castBar.channeling) and true or false
end

function TargetText.Update(frame, data)
	local container = frame.HealthBarsContainer
	if not ns.db.target.targetText or data.side ~= "enemy" or not ns.HasHealthBar(frame) then
		if data.targetText then data.targetText:Hide() end
		return
	end
	local text = GetText(frame, data)
	local unit = data.unit
	local castBar = ns.GetCastBar(frame)
	text:ClearAllPoints()

	-- The enemy's current target, by its first name only (without the realm) and in its class color.
	-- While casting, that's the one the cast is aimed at; the text then goes under the cast bar.
	local targetUnit = unit .. "target"
	local fake = data.fake
	local name, class
	if IsCasting(castBar) then
		text:SetPoint("TOPRIGHT", castBar, "BOTTOMRIGHT", 0, -TEXT_GAP)
	else
		text:SetPoint("TOPRIGHT", container, "BOTTOMRIGHT", 0, -TEXT_GAP)
	end
	if fake then
		if IsCasting(castBar) and fake.castTarget then
			name, class = fake.castTarget, fake.castTargetClass
		else
			name, class = fake.targetName, fake.targetClass
		end
	else
		name = UnitName(targetUnit)
		class = ns.Known(UnitIsPlayer(targetUnit)) and UnitClassBase(targetUnit)
	end
	text:SetText(name)
	text:SetTextColor(ClassColor(class))
	text:Show()
end

TargetText.Layout = TargetText.Update

function TargetText.Removed(_, data)
	if data.targetText then data.targetText:Hide() end
end

ns.RegisterEvent("UNIT_TARGET", function(_, unit)
	local frame, data = ns.GetFrameForUnit(unit)
	if frame and data and data.unit then
		TargetText.Update(frame, data)
	end
end)
