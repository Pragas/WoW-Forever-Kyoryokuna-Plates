-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The cast bar of enemies, right under the health bar and exactly as wide as it, with the spell icon
-- inside its left end (or hidden), the spell name centered, the one-pixel border of the health bar (so
-- both look just as wide, always drawn above the icon) and a grey see-through background. It's the
-- game's own cast bar, laid out again after each of its cast events (see Engine\Hooks.lua); the
-- game's frame, glows and flash on it are made invisible.
--
-- Its color, all three chosen on the Cast Bar page:
--   a cast that can be interrupted (the player's interrupt is ready, or the player has none);
--   the same, but the player's interrupt is on cooldown;
--   a cast that can't be interrupted at all.
-- "Can't be interrupted" comes from the game as a yes/no the addon may not be allowed to read in combat,
-- so the bar is painted with the game's "color from a yes/no" function, which picks one of two colors.
-- (Whether the interrupt would be ready before the cast ends can't be known: in combat the game hides
-- both times from addons.)
--
-- Joined to the health bar (default), it's just as wide and right under it, sharing its border; apart,
-- it has its own width, distance and horizontal position.

local _, ns = ...

local CastBar = ns.RegisterModule("CastBar", {})

-- The size of one screen pixel in a region's own units
local function OnePixel(region)
	local factor = PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor()
	local scale = ns.Known(region:GetEffectiveScale())
	if factor and scale and scale > 0 then return factor / scale end
	return 1
end

-- The room between the health bar and the cast bar, which the health bar leaves under it
function ns.GetCastGap()
	local settings = ns.db.castBar
	if settings.attached then return 1 end
	return settings.gap
end

local BACKGROUND = {0.25, 0.25, 0.25, 0.6}
-- The game's global cooldown; a cooldown this short is the GCD, not the interrupt's own
local GCD = 1.5

-- Interrupts of every class, all ranks; the first one the player knows is followed
local INTERRUPT_SPELLS = {
	1766, 1767, 1768, 1769, 38768,                      -- Kick
	6552, 6554,                                         -- Pummel
	72, 1671, 1672,                                     -- Shield Bash
	2139,                                               -- Counterspell
	8042, 8044, 8045, 8046, 10412, 10413, 10414,        -- Earth Shock
	19244, 19647,                                       -- Spell Lock (Felhunter)
	15487,                                              -- Silence
	57994, 96231, 47528, 106839, 187707, 147362, 116705, 183752, 351338,
}

-- The player's interrupt -----------------------------------------------------------------------------

local interruptSpell
local readyByCooldownFrame

-- A hidden cooldown frame follows the interrupt when the game hides its times: it still knows when the
-- cooldown ends, even if the addon can't read it
local holder = CreateFrame("Frame", nil, UIParent)
holder:SetSize(1, 1)
holder:SetPoint("TOPLEFT", UIParent, "BOTTOMRIGHT", 200, -200)
holder:SetAlpha(0)
local cooldown = CreateFrame("Cooldown", nil, holder, "CooldownFrameTemplate")
cooldown:SetAllPoints(holder)
cooldown.noCooldownCount = true

local function IsKnown(spellID)
	if IsSpellKnownOrOverridesKnown then
		return IsSpellKnownOrOverridesKnown(spellID) or IsSpellKnownOrOverridesKnown(spellID, true)
	end
	if IsPlayerSpell then return IsPlayerSpell(spellID) end
	return false
end

local function FindInterrupt()
	for _, spellID in ipairs(INTERRUPT_SPELLS) do
		if IsKnown(spellID) then return spellID end
	end
end

-- In combat the game hides the interrupt's cooldown times from addons. The addon then follows the
-- cooldown on its own: it notes when the player uses the interrupt (the spell of the player's own casts
-- isn't hidden) and how long its cooldown lasts: the game's readable value when there is one, measured
-- when a cooldown ends, or the spell's base cooldown before that.
local usedAt
local cooldownLength = {}

local function GetBaseCooldown(spellID)
	if not GetSpellBaseCooldown then return nil end
	local ok, ms = pcall(GetSpellBaseCooldown, spellID)
	ms = ok and ns.Known(ms)
	if type(ms) == "number" and ms > 0 then return ms / 1000 end
end

-- The cooldown as the game gives it, when it's readable: seconds left (0 = ready), or nil
local function GetReadableRemaining()
	if not interruptSpell or not (C_Spell and C_Spell.GetSpellCooldown) then return end
	local info = C_Spell.GetSpellCooldown(interruptSpell)
	if not info then return end
	local start, duration = ns.Known(info.startTime), ns.Known(info.duration)
	if not start or not duration then return end
	if duration <= GCD then return 0 end
	cooldownLength[interruptSpell] = duration
	return math.max(0, start + duration - GetTime())
end

-- Whether the spells of the player's own casts are readable (nil until a cast is seen)
local ownSpellsReadable

local function GetCooldownLength()
	return cooldownLength[interruptSpell] or GetBaseCooldown(interruptSpell)
end

-- Seconds left by the addon's own record of the interrupt's use (may be below 0), or nil without one
local function GetRecordedRemaining()
	local length = GetCooldownLength()
	if usedAt and length then return usedAt + length - GetTime() end
end

-- true / false, or nil when there's no interrupt to follow
local function IsInterruptReady()
	if not interruptSpell then return nil end
	local remaining = GetReadableRemaining()
	if remaining then return remaining <= 0 end
	if readyByCooldownFrame ~= false then return readyByCooldownFrame end
	-- The hidden cooldown frame shows a cooldown: the interrupt's own, or only the global cooldown
	-- after another spell. The addon's record of the interrupt's use tells them apart.
	local recorded = GetRecordedRemaining()
	if recorded then return recorded <= -GCD end
	-- No record: the global cooldown, unless the record can't be made (the game hides the spells)
	return ownSpellsReadable == true
end

function ns.GetInterruptSpell()
	return interruptSpell
end
ns.IsInterruptReady = IsInterruptReady

-- What the addon knows of the interrupt, for /kp diag
function ns.GetInterruptTracking()
	return {
		usedAgo = usedAt and (GetTime() - usedAt),
		length = interruptSpell and GetCooldownLength(),
		frameReady = readyByCooldownFrame,
		ownSpellsReadable = ownSpellsReadable,
	}
end

local function RefreshShownCastBars()
	ns.ForEachPlate(function(frame, data)
		local castBar = ns.GetCastBar(frame)
		if castBar and castBar:IsShown() then
			CastBar.UpdateColor(frame, data)
		end
	end)
end

local function FollowCooldown()
	if interruptSpell and C_Spell and C_Spell.GetSpellCooldownDuration and cooldown.SetCooldownFromDurationObject then
		local duration = C_Spell.GetSpellCooldownDuration(interruptSpell)
		if duration then
			cooldown:SetCooldownFromDurationObject(duration)
			readyByCooldownFrame = not cooldown:IsShown()
		end
	end
	RefreshShownCastBars()
end

cooldown:HookScript("OnCooldownDone", function()
	readyByCooldownFrame = true
	-- How long the cooldown really lasted (talents and other effects can shorten it)
	if usedAt and interruptSpell then
		local measured = GetTime() - usedAt
		local base = GetBaseCooldown(interruptSpell)
		-- A cooldown far shorter than the spell's is a global cooldown that ended, not the interrupt's
		if measured > GCD and (not base or measured >= base / 2) then cooldownLength[interruptSpell] = measured end
	end
	usedAt = nil
	RefreshShownCastBars()
end)

-- The player used the interrupt: its cooldown starts now
ns.RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", function(_, unit, _, spellID)
	if unit ~= "player" or not interruptSpell then return end
	spellID = ns.Known(spellID)
	ownSpellsReadable = spellID ~= nil
	if spellID and (spellID == interruptSpell or (C_Spell and C_Spell.GetOverrideSpell
		and ns.Known(C_Spell.GetOverrideSpell(interruptSpell)) == spellID)) then
		usedAt = GetTime()
		readyByCooldownFrame = false
	end
end)

local function RefreshInterruptSpell()
	interruptSpell = FindInterrupt()
	FollowCooldown()
end

ns.RegisterEvent("PLAYER_ENTERING_WORLD", RefreshInterruptSpell)
ns.RegisterEvent("SPELLS_CHANGED", RefreshInterruptSpell)
ns.RegisterEvent("UNIT_PET", function(_, unit)
	if unit == "player" then
		C_Timer.After(0.5, RefreshInterruptSpell)
	end
end)
ns.RegisterEvent("SPELL_UPDATE_COOLDOWN", FollowCooldown)

-- Colors ---------------------------------------------------------------------------------------------

local function IsCasting(castBar)
	return castBar.casting or castBar.channeling
end

local function GetNotInterruptible(castBar, unit)
	if castBar.casting then
		return select(8, UnitCastingInfo(unit))
	elseif castBar.channeling then
		return select(7, UnitChannelInfo(unit))
	end
end

function CastBar.UpdateColor(frame, data)
	local castBar = ns.GetCastBar(frame)
	local texture = castBar and castBar:GetStatusBarTexture()
	if not texture or not IsCasting(castBar) then return end
	local settings = ns.db.castBar

	local onCooldown, notInterruptible
	if data.fake then
		-- Examples of the test mode carry the state they show
		local state = data.fake.castState
		notInterruptible = state == "uninterruptible"
		onCooldown = state == "cooldown"
	else
		notInterruptible = GetNotInterruptible(castBar, data.unit)
		onCooldown = IsInterruptReady() == false
	end
	local color = onCooldown and settings.notReadyColor or settings.readyColor
	texture:SetDesaturated(true)
	local hasAnswer = ns.IsSecret(notInterruptible) or notInterruptible ~= nil
	if hasAnswer and texture.SetVertexColorFromBoolean and CreateColor then
		texture:SetVertexColorFromBoolean(notInterruptible, CreateColor(ns.Unpack(settings.nonInterruptibleColor)),
			CreateColor(ns.Unpack(color)))
	else
		texture:SetVertexColor(ns.Unpack(color))
	end
end

-- Layout ---------------------------------------------------------------------------------------------

-- The game's art on its cast bar, made invisible: its frame, the shield of casts that can't be
-- interrupted, its background, the glow around the bar when the cast is aimed at the player, the mark
-- of important casts, its flash at the end, and its own text with the target of the cast
local HIDDEN_ART = {
	"Border", "BorderShield", "TextBorder", "Background", "CastTargetIndicator", "ImportantCastIndicator",
	"Flash", "CastTargetNameText",
}
-- Those the game shows only for a moment (with animations that change their opacity): also hidden
local TRANSIENT_ART = {Flash = true, CastTargetIndicator = true, ImportantCastIndicator = true}

local function GetBackground(castBar, data)
	if not data.castBackground then
		local background = castBar:CreateTexture(nil, "BACKGROUND", nil, -7)
		background:SetAllPoints(castBar)
		background:SetColorTexture(unpack(BACKGROUND))
		data.castBackground = background
	end
	return data.castBackground
end

local function ApplyLayout(frame, data)
	local castBar = ns.GetCastBar(frame)
	local container = frame.HealthBarsContainer
	if not castBar or not container then return end
	local settings = ns.db.castBar
	local height = settings.height

	castBar:ClearAllPoints()
	if settings.attached then
		-- One screen pixel under the health bar: exactly where the health bar's bottom border is, which is
		-- then the line between both bars
		local gap = OnePixel(castBar)
		castBar:SetPoint("TOPLEFT", container, "BOTTOMLEFT", 0, -gap)
		castBar:SetPoint("TOPRIGHT", container, "BOTTOMRIGHT", 0, -gap)
	else
		castBar:SetPoint("TOP", container, "BOTTOM", settings.offsetX, -settings.gap)
		castBar:SetWidth(settings.width)
	end
	castBar:SetHeight(height)
	castBar:SetStatusBarTexture(ns.BAR_TEXTURE)

	-- Done after each cast event of the game, so they're made invisible again right after the game shows
	-- them. The game blocks addons from following these regions (their scripts are protected), and may
	-- block other calls on them, so each call is protected and a blocked one never stops the rest.
	for _, key in ipairs(HIDDEN_ART) do
		local region = castBar[key]
		if type(region) == "table" then
			if region.SetAlpha then pcall(region.SetAlpha, region, 0) end
			if TRANSIENT_ART[key] and region.Hide then pcall(region.Hide, region) end
		end
	end
	GetBackground(castBar, data):Show()
	-- The one-pixel border of the health bar, in the same color (black, or the target color on the
	-- target), so both bars look just as wide; above the spell icon, so it's always whole
	if not data.castBorder and ns.CreatePixelBorder then
		data.castBorder = ns.CreatePixelBorder(castBar, 7)
	end
	if data.castBorder then
		if data.isTarget then
			data.castBorder:SetColor(ns.Unpack(ns.db.target.borderColor))
		else
			data.castBorder:SetColor(0, 0, 0)
		end
		-- Joined, the health bar's bottom border is the line between both bars
		data.castBorder.top:SetShown(not settings.attached)
	end

	-- The spell icon sits inside the left end of the bar; at 100% it's exactly as tall as the bar. The
	-- border is drawn above it, so it's always whole. It can be hidden (Cast Bar page).
	local icon = castBar.Icon
	if type(icon) == "table" then
		local size = height * settings.iconScale / 100
		icon:ClearAllPoints()
		icon:SetPoint("LEFT", castBar, "LEFT", 0, 0)
		icon:SetSize(size, size)
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		icon:SetDrawLayer("OVERLAY", 6)
		icon:SetAlpha(settings.showIcon and 1 or 0)
	end

	local text = castBar.Text
	if text then
		if not data.castFont then
			local path, size, flags = text:GetFont()
			if path then
				data.castFont = {path = path, size = ns.Known(size) or 8, flags = flags or ""}
			end
		end
		-- The game's font of real cast bars, so the examples of the test mode use the very same
		if data.castFont and not data.fake then ns.gameCastFont = data.castFont end
		local base = data.castFont
		if base then
			local flags = base.flags:find("SLUG") and "OUTLINE, SLUG" or "OUTLINE"
			text:SetFont(base.path, base.size * settings.textScale / 100, flags)
		end
		text:ClearAllPoints()
		text:SetPoint("CENTER", castBar, "CENTER", 0, 0)
	end
end

-- Hidden on allies: the bar is made invisible, so the game keeps running it as usual
local function ApplyVisibility(frame, data)
	local castBar = ns.GetCastBar(frame)
	if not castBar then return end
	if data.side == "allies" and ns.db.castBar.hideOnAllies then
		data.castHidden = true
		castBar:SetAlpha(0)
	elseif data.castHidden then
		data.castHidden = false
		castBar:SetAlpha(1)
	end
end

-- Module ---------------------------------------------------------------------------------------------

function CastBar.Update(frame, data)
	ApplyVisibility(frame, data)
	ApplyLayout(frame, data)
	CastBar.UpdateColor(frame, data)
end

CastBar.Layout = ApplyLayout
-- The border takes the target color, like the health bar's
CastBar.TargetChanged = ApplyLayout

function CastBar.OnCastEvent(frame, data)
	ApplyVisibility(frame, data)
	ApplyLayout(frame, data)
	CastBar.UpdateColor(frame, data)
	if ns.TargetText then
		ns.TargetText.Update(frame, data)
	end
end
