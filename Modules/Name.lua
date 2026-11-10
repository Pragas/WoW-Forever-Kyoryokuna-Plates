-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The name. Its size is a percentage of the game's own size (enemies and allies separately), and the
-- font flags the game uses for sharp text are kept. It doesn't grow when the unit is selected. Enemy players get their class color; the names of
-- mobs keep the game's color (which also turns grey when the mob is tapped by others). Allied players
-- get their class color from the game itself.
--
-- The game pins the name to both ends of the bar's space, so a long name gets cut ("Posttal Kyor...").
-- Here the name is held by a single point instead, so it's always as wide as it needs and never cut:
--   - with a health bar: centered just above the bar;
--   - name only (allies): centered a fixed distance above the bottom of the nameplate, so it doesn't
--     move up when the ally is selected.
-- It's put back there whenever the game moves it.

local _, ns = ...

local Name = ns.RegisterModule("Name", {})

local NAME_GAP = 4
-- The size that 100% means, as a part of the game's own size. The game's size is too big: 100% is 80%
-- of it, for enemies and allies.
local NAME_BASE = {enemy = 0.8, allies = 0.8}
ns.NAME_BASE = NAME_BASE
-- Name-only nameplates: how far above the bottom of the nameplate the name sits
local NAME_ONLY_OFFSET = 30

local function BuildFlags(baseFlags)
	if baseFlags and baseFlags:find("SLUG") then
		return "OUTLINE, SLUG"
	end
	return "OUTLINE"
end

-- Whether a font read from a name is still the one this addon gave it. The size may come back rounded,
-- and when it's secret it can't be compared, so it counts as the same (nothing is changed).
local function SameFont(applied, path, size)
	if not path then return true end
	if path ~= applied.path then return false end
	size = ns.Known(size)
	if type(size) ~= "number" then return true end
	return math.abs(size - applied.size) < 0.05
end

local function PlaceName(frame, data)
	local container = frame.HealthBarsContainer
	if not container then return end
	data.placingName = true
	local fontString = frame.name
	fontString:ClearAllPoints()
	if ns.HasHealthBar(frame) then
		fontString:SetPoint("BOTTOM", container, "TOP", 0, NAME_GAP)
	else
		-- The game makes the selected nameplate bigger, growing up from its bottom, which stays over the
		-- character's head. Held from that bottom at a fixed distance (the name ignores the nameplate's
		-- scale, so the distance doesn't grow either), the name stays put when the unit is selected.
		-- Allies: the distance is an option (Allies page), lower puts the name closer to the head
		local offset = data.side == "allies" and ns.db.allies.nameHeight or NAME_ONLY_OFFSET
		fontString:SetPoint("BOTTOM", frame, "BOTTOM", 0, offset)
	end
	-- No fixed width, so the name is never cut
	fontString:SetWidth(0)
	if fontString.SetWordWrap then fontString:SetWordWrap(false) end
	data.placingName = false
end

local function HookNamePosition(frame, data)
	if data.nameHooked then return end
	data.nameHooked = true
	local function Replace()
		local current = ns.GetPlateData(frame)
		if current and not current.placingName then
			ns.SafeCall(PlaceName, frame, current)
		end
	end
	hooksecurefunc(frame.name, "SetPoint", Replace)
	hooksecurefunc(frame.name, "SetWidth", Replace)

	-- The game gives the name another font when it changes the nameplate's style (e.g. an ally going from
	-- name only to a health bar, or a nameplate reused for another unit): the game's new font is read
	-- again, and the name gets its size from it
	-- Also while the nameplate has no unit (between one unit and the next): the next unit must not get
	-- the font of the last one (e.g. the smaller font of a friendly NPC on a mob's name).
	local function FontChanged()
		if data.settingNameFont then return end
		data.nameFont = nil
		local current = ns.GetPlateData(frame)
		if current then
			-- The health percent and the level take their font from the name's too
			ns.CallModules("Layout", frame, current)
		end
	end
	hooksecurefunc(frame.name, "SetFontObject", FontChanged)
	hooksecurefunc(frame.name, "SetFont", FontChanged)
end

function Name.Update(frame, data)
	local fontString = frame.name
	if not fontString then return end

	-- The name no longer has the font this addon gave it: the game gave it another one in the meantime,
	-- which becomes the new base (the hooks above may miss it, e.g. when it happens before they exist)
	if data.nameFont and data.appliedNameFont and not data.fake
		and not SameFont(data.appliedNameFont, fontString:GetFont()) then
		data.nameFont = nil
	end
	-- The game's font, as it was before this addon changed it
	if not data.nameFont then
		local path, size, flags = fontString:GetFont()
		if not path then return end
		data.nameFont = {path = path, size = ns.Known(size) or 9, flags = flags or ""}
	end
	-- The game's font of real nameplates, so the examples of the test mode use the very same. Kept for
	-- enemies and allies apart: the game gives the names of allies (name only) a smaller font.
	if not data.fake and data.side then
		ns.gameNameFonts = ns.gameNameFonts or {}
		ns.gameNameFonts[data.side] = data.nameFont
	end
	local base = data.nameFont
	-- The name ignores the scale of the nameplate, so it keeps its size when the unit is selected (the
	-- game makes the target's nameplate bigger) and at any distance. Only the game's raid mark grows.
	if fontString.SetIgnoreParentScale then
		fontString:SetIgnoreParentScale(true)
	end
	local scale = NAME_BASE[data.side] * ns.db[data.side].nameScale / 100
	-- Not taken for a change of the game's (see HookNamePosition)
	local applied = {path = base.path, size = base.size * scale, flags = BuildFlags(base.flags)}
	data.settingNameFont = true
	fontString:SetFont(applied.path, applied.size, applied.flags)
	data.settingNameFont = false
	data.appliedNameFont = applied

	if data.side == "enemy" and data.isPlayer and ns.db.enemy.classColor then
		local r, g, b = ns.GetClassColor(data.class)
		if r then
			fontString:SetVertexColor(r, g, b)
		end
	end

	HookNamePosition(frame, data)
	PlaceName(frame, data)
end

Name.Layout = Name.Update
