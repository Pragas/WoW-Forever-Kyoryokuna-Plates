-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The health bar in the classic style. The modern art of the game's bar is made invisible (its rounded
-- frame, its background, the selection outline, the fade overlay and the mask that rounds its corners)
-- and the bar gets instead:
--   - the game's classic bar fill texture (glossy, takes any color);
--   - a dark, see-through background behind the empty part;
--   - a border of exactly one screen pixel: black, and white (the target color) on the current target.
--     Elites, rares and bosses (not the target) fade from black on the left to a color of their own
--     (Enemies page). It ignores the scale of the nameplate, so it stays sharp at any size.
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

-- Each edge is sized and placed in screen pixels, around the outside of the bar: as many whole screen
-- pixels thick as asked (1 by default; Enemies and Target pages)
local function LayoutEdges(decoration, container, pixels)
	local top, bottom, left, right = decoration.top, decoration.bottom, decoration.left, decoration.right
	pixels = pixels or BORDER_THICKNESS
	local size = pixels * (ns.OnePixel and ns.OnePixel(top) or 1)
	if PixelUtil then
		PixelUtil.SetHeight(top, size, math.max(MIN_PIXELS, pixels))
		PixelUtil.SetHeight(bottom, size, math.max(MIN_PIXELS, pixels))
		PixelUtil.SetWidth(left, size, math.max(MIN_PIXELS, pixels))
		PixelUtil.SetWidth(right, size, math.max(MIN_PIXELS, pixels))
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
	decoration.pixels = pixels
end

-- How thick the border of a nameplate is, in screen pixels: the target's (Target page) or the enemies'
-- (Enemies page); allies with a health bar keep one pixel
function ns.GetBorderPixels(data)
	if data.isTarget then return ns.db.target.borderSize end
	if data.side == "enemy" then return ns.db.enemy.borderSize end
	return BORDER_THICKNESS
end

-- Painting the edges --------------------------------------------------------------------------------

-- An edge in one color, or fading from one color (left) to another (right). The edge is white and the
-- colors are laid over it, so a fade and a plain color can follow each other on the same edge; without
-- the game's gradient, the plain color only.
local function PaintEdge(edge, r1, g1, b1, r2, g2, b2)
	r2, g2, b2 = r2 or r1, g2 or g1, b2 or b1
	if edge.SetGradient and CreateColor then
		edge:SetColorTexture(1, 1, 1, 1)
		local ok = pcall(edge.SetGradient, edge, "HORIZONTAL", CreateColor(r1, g1, b1, 1), CreateColor(r2, g2, b2, 1))
		if ok then return end
	end
	edge:SetColorTexture(r2, g2, b2, 1)
end

-- The whole border in one color
local function PaintSolid(edges, r, g, b)
	for _, key in ipairs(EDGES) do PaintEdge(edges[key], r, g, b) end
end

-- Elites, rares and bosses: black on the left, fading along the top and the bottom to their color,
-- which the right edge has
local function PaintFade(edges, r, g, b)
	PaintEdge(edges.left, 0, 0, 0)
	PaintEdge(edges.top, 0, 0, 0, r, g, b)
	PaintEdge(edges.bottom, 0, 0, 0, r, g, b)
	PaintEdge(edges.right, r, g, b)
end

-- What kind of enemy it is, for its border and its icons: "boss", "rare" (the silver dragon, also rare
-- elites), "elite" (the gold dragon), or nil. Players and allies are none; nil too while the game hides it.
function ns.GetRank(data)
	if data.side ~= "enemy" or data.isPlayer then return nil end
	local classification = data.classification
	if data.isBoss or classification == "worldboss" then return "boss" end
	if classification == "rare" or classification == "rareelite" then return "rare" end
	if classification == "elite" then return "elite" end
	return nil
end

local RANK_COLORS = {boss = "bossColor", rare = "rareColor", elite = "eliteColor"}

-- The border a nameplate gets: the target's color (always, it wins), the fade of its rank, or black.
-- Paints the given edges (of the health bar or of the cast bar).
function ns.PaintBorder(edges, data)
	if data.isTarget then
		PaintSolid(edges, ns.Unpack(ns.db.target.borderColor))
		return
	end
	local rank = ns.db.enemy.rankBorder and ns.GetRank(data)
	if rank then
		PaintFade(edges, ns.Unpack(ns.db.enemy[RANK_COLORS[rank]]))
		return
	end
	PaintSolid(edges, 0, 0, 0)
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
		PaintSolid(self, r, g, b)
	end
	function border:SetShown(shown)
		for _, key in ipairs(EDGES) do self[key]:SetShown(shown) end
	end
	function border:SetThickness(pixels)
		if self.pixels ~= pixels then LayoutEdges(self, bar, pixels) end
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
	local pixels = ns.GetBorderPixels(data)
	if decoration.pixels ~= pixels then LayoutEdges(decoration, frame.HealthBarsContainer, pixels) end
	ns.PaintBorder(decoration, data)
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
	-- On whole pixels from the nameplate's bottom, so the one-pixel border lines are never half way into one
	bottom = ns.SnapToPixels(container, bottom)
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
