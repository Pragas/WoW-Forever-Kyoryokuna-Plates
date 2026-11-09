-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The health bar in the classic style. The modern art of the game's bar is made invisible (its rounded
-- frame, its background, the selection outline, the fade overlay and the mask that rounds its corners)
-- and the bar gets instead:
--   - the game's classic bar fill texture (glossy, takes any color);
--   - a dark, see-through background behind the empty part;
--   - a border of exactly one screen pixel: black, and white (the target color) on the current target.
--     It ignores the scale of the nameplate, so it stays sharp at any size.
-- The color of the bar stays the game's: red, yellow, grey when tapped by others, the class color of
-- players. The game's health text and threat glow are left untouched.
-- Size: 144 wide and 15 high by default, like the reference (both set on the Enemies page). The
-- nameplate itself is made 16 wider than the bar (Engine\CVars.lua).

local _, ns = ...

local HealthBar = ns.RegisterModule("HealthBar", {})

local BACKGROUND_ALPHA = 0.55
local BORDER_THICKNESS = 1
local MIN_PIXELS = 1
local ART_REGIONS = {"bgTexture", "selectedBorder", "deselectedOverlay"}
local EDGES = {"top", "bottom", "left", "right"}

local function HideGameArt(frame)
	local container = frame.HealthBarsContainer
	local bar = ns.GetHealthBar(frame)
	if container and type(container.border) == "table" then
		container.border:SetAlpha(0)
	end
	if bar then
		for _, key in ipairs(ART_REGIONS) do
			local region = bar[key]
			if type(region) == "table" and region.SetAlpha then region:SetAlpha(0) end
		end
		local mask = bar.MaskTexture
		if type(mask) == "table" and mask.Hide then mask:Hide() end
	end
end

local function ApplyTexture(frame)
	local bar = ns.GetHealthBar(frame)
	if bar then
		bar:SetStatusBarTexture(ns.BAR_TEXTURE)
	end
end

-- Background and pixel border ---------------------------------------------------------------------

local function CreateEdge(parent, sublevel)
	local edge = parent:CreateTexture(nil, "OVERLAY", nil, sublevel or 7)
	edge:SetColorTexture(0, 0, 0, 1)
	if edge.SetIgnoreParentScale then edge:SetIgnoreParentScale(true) end
	return edge
end

local function SetPixelPoint(region, ...)
	if PixelUtil then
		PixelUtil.SetPoint(region, ...)
	else
		region:SetPoint(...)
	end
end

-- Each edge is sized and placed in screen pixels, around the outside of the bar
local function LayoutEdges(decoration, container)
	local top, bottom, left, right = decoration.top, decoration.bottom, decoration.left, decoration.right
	local size = BORDER_THICKNESS
	if PixelUtil then
		PixelUtil.SetHeight(top, size, MIN_PIXELS)
		PixelUtil.SetHeight(bottom, size, MIN_PIXELS)
		PixelUtil.SetWidth(left, size, MIN_PIXELS)
		PixelUtil.SetWidth(right, size, MIN_PIXELS)
	else
		top:SetHeight(size)
		bottom:SetHeight(size)
		left:SetWidth(size)
		right:SetWidth(size)
	end
	top:ClearAllPoints()
	SetPixelPoint(top, "BOTTOMLEFT", container, "TOPLEFT", 0, 0)
	SetPixelPoint(top, "BOTTOMRIGHT", container, "TOPRIGHT", 0, 0)
	bottom:ClearAllPoints()
	SetPixelPoint(bottom, "TOPLEFT", container, "BOTTOMLEFT", 0, 0)
	SetPixelPoint(bottom, "TOPRIGHT", container, "BOTTOMRIGHT", 0, 0)
	left:ClearAllPoints()
	SetPixelPoint(left, "TOPRIGHT", container, "TOPLEFT", 0, size)
	SetPixelPoint(left, "BOTTOMRIGHT", container, "BOTTOMLEFT", 0, -size)
	right:ClearAllPoints()
	SetPixelPoint(right, "TOPLEFT", container, "TOPRIGHT", 0, size)
	SetPixelPoint(right, "BOTTOMLEFT", container, "BOTTOMRIGHT", 0, -size)
end

-- The same one-pixel border around another bar (the cast bar): its edges are drawn by the bar itself,
-- under the given sublevel of its top layer, so what's drawn above that (e.g. a spell icon) stays on top
function ns.CreatePixelBorder(bar, sublevel)
	local border = {}
	for _, key in ipairs(EDGES) do
		border[key] = CreateEdge(bar, sublevel)
	end
	LayoutEdges(border, bar)
	function border:SetColor(r, g, b)
		for _, key in ipairs(EDGES) do self[key]:SetColorTexture(r, g, b, 1) end
	end
	function border:SetShown(shown)
		for _, key in ipairs(EDGES) do self[key]:SetShown(shown) end
	end
	return border
end

local function GetDecoration(frame, data)
	if data.barDecoration then return data.barDecoration end
	local container = frame.HealthBarsContainer
	local bar = ns.GetHealthBar(frame)

	local background = bar:CreateTexture(nil, "BACKGROUND", nil, -7)
	background:SetAllPoints(container)
	background:SetColorTexture(0, 0, 0, BACKGROUND_ALPHA)

	local holder = CreateFrame("Frame", nil, container)
	holder:SetAllPoints(container)
	holder:SetFrameLevel(container:GetFrameLevel() + 5)

	local decoration = {background = background, holder = holder}
	for _, key in ipairs(EDGES) do
		decoration[key] = CreateEdge(holder)
	end
	LayoutEdges(decoration, container)
	data.barDecoration = decoration
	return decoration
end

local function HideDecoration(data)
	if data.barDecoration then
		data.barDecoration.holder:Hide()
		data.barDecoration.background:Hide()
	end
end

function HealthBar.UpdateBorder(frame, data)
	-- Name-only nameplates get no background or border around the name
	if not ns.HasHealthBar(frame) then
		HideDecoration(data)
		return
	end
	local decoration = GetDecoration(frame, data)
	local r, g, b = 0, 0, 0
	if data.isTarget then
		r, g, b = ns.Unpack(ns.db.target.borderColor)
	end
	for _, key in ipairs(EDGES) do
		decoration[key]:SetColorTexture(r, g, b, 1)
	end
	decoration.holder:Show()
	decoration.background:Show()
end

-- Size and place -------------------------------------------------------------------------------------

-- Space under the cast bar, at the bottom of the nameplate
local BOTTOM_GAP = 3
-- Space between the bar and the cast bar under it (the Cast Bar page sets it; this until it's loaded)
local CAST_GAP = 2

-- The bar is held from the bottom of the nameplate, with the cast bar's room under it, and with a fixed
-- width and height instead of the game's own anchors, which made it tall and narrow. The game sets its
-- size and place again during its layout, so this runs again after it (see Engine\Hooks.lua).
-- Width and height are in whole screen pixels (see ns.ToWholePixels).
function HealthBar.ApplySize(frame, data)
	local container = frame.HealthBarsContainer
	if not container or not ns.HasHealthBar(frame) then return end
	local half = ns.ToWholePixels(container, ns.db.enemy.barWidth) / 2
	local bottom = BOTTOM_GAP + ns.db.castBar.height + (ns.GetCastGap and ns.GetCastGap() or CAST_GAP)
	data.sizingBar = true
	container:ClearAllPoints()
	container:SetPoint("BOTTOMLEFT", frame, "BOTTOM", -half, bottom)
	container:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", half, bottom)
	container:SetHeight(ns.ToWholePixels(container, ns.db.enemy.barHeight))
	data.sizingBar = false
end

-- The game may change a nameplate's scale right after the addon sees it (a new target is made bigger,
-- the old one smaller again), and a screen pixel is then another size in the bar's units: both bars are
-- sized again on the next frame, unless the nameplate went away or shows another unit by then
local function ApplySizeSoon(frame, data)
	local unit = data.unit
	C_Timer.After(0, function()
		if data.unit ~= unit or not ns.GetPlateData(frame) then return end
		HealthBar.ApplySize(frame, data)
		if ns.CastBar and ns.CastBar.Layout then ns.CastBar.Layout(frame, data) end
	end)
end

-- A dead unit keeps its nameplate (e.g. a selected corpse), but its empty bar is made invisible
local function ApplyDeadState(frame, data)
	local container = frame.HealthBarsContainer
	if not container then return end
	if data.isDead then
		data.barHiddenForDeath = true
		container:SetAlpha(0)
	elseif data.barHiddenForDeath then
		data.barHiddenForDeath = false
		container:SetAlpha(1)
	end
end

-- Module -------------------------------------------------------------------------------------------

function HealthBar.Update(frame, data)
	ApplyDeadState(frame, data)
	HealthBar.ApplySize(frame, data)
	ApplySizeSoon(frame, data)
	HideGameArt(frame)
	ApplyTexture(frame)
	HealthBar.UpdateBorder(frame, data)
end

function HealthBar.Layout(frame, data)
	ApplyDeadState(frame, data)
	HealthBar.ApplySize(frame, data)
	HideGameArt(frame)
	ApplyTexture(frame)
	HealthBar.UpdateBorder(frame, data)
end

function HealthBar.TargetChanged(frame, data)
	-- The game shows its own selection art again when the target changes
	HideGameArt(frame)
	HealthBar.UpdateBorder(frame, data)
	-- The target's nameplate is bigger: the size in whole screen pixels is measured again
	HealthBar.ApplySize(frame, data)
	ApplySizeSoon(frame, data)
end

function HealthBar.Removed(frame, data)
	HideDecoration(data)
	-- The game reuses its nameplates: the bar is shown again for the next unit
	if data.barHiddenForDeath and frame.HealthBarsContainer then
		data.barHiddenForDeath = false
		frame.HealthBarsContainer:SetAlpha(1)
	end
end
