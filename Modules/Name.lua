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

-- Allies inside dungeons and raids -----------------------------------------------------------------
-- There the game protects the nameplates of allies: the addon can't touch them, and their names keep
-- the game's size, which also shrinks with the nameplate's scale (outside, names ignore that scale), so
-- they look smaller than outside. The game's shared font of nameplate names may be changed, though:
-- inside dungeons, raids and scenarios it gets the size that, shrunk by the nameplate's scale, gives
-- the names of allies the size they have outside. The game's own font is put back when leaving.

local SHARED_FONT = "SystemFont_NamePlate_Outlined"
local INSTANCE_TYPES = {party = true, raid = true, scenario = true}
-- The game's own shared font, kept before the addon changes it
local sharedOriginal
-- The size the addon gave it; nil while it's the game's own
local sharedApplied
-- The scale of a nameplate that isn't the target, last seen
local plateScale
-- A hidden text that ignores its parent's scale, like the names: how such a text is scaled
local probe

local function SharedFont()
	return _G[SHARED_FONT]
end

-- The game's own size of a name's font: while the addon has changed the shared font, the name may
-- show the changed size, but the game's own is what the name's size is based on
local function GameSize(fontString, size)
	if sharedApplied and sharedOriginal and fontString.GetFontObject then
		local ok, object = pcall(fontString.GetFontObject, fontString)
		if ok and object == SharedFont() then return sharedOriginal.size end
	end
	return size
end

local function IgnoringScale()
	if not probe then
		probe = UIParent:CreateFontString(nil, "BACKGROUND")
		if probe.SetIgnoreParentScale then probe:SetIgnoreParentScale(true) end
		probe:Hide()
	end
	return ns.Known(probe:GetEffectiveScale())
end

local function IsInsideInstance()
	if not IsInInstance then return false end
	local inside, instanceType = IsInInstance()
	return inside and INSTANCE_TYPES[instanceType] or false
end

local function UpdateSharedFont()
	local font = SharedFont()
	if not font or not ns.db then return end
	if not IsInsideInstance() then
		if sharedApplied and sharedOriginal then
			font:SetFont(sharedOriginal.path, sharedOriginal.size, sharedOriginal.flags)
		end
		sharedApplied = nil
		return
	end
	if not sharedOriginal then
		local path, size, flags = font:GetFont()
		size = ns.Known(size)
		if not path or type(size) ~= "number" then return end
		sharedOriginal = {path = path, size = size, flags = flags or ""}
	end
	local ignoring = IgnoringScale()
	local plates = plateScale or ns.Known(UIParent:GetEffectiveScale())
	if type(ignoring) ~= "number" or type(plates) ~= "number" or plates <= 0 then return end
	local size = sharedOriginal.size * NAME_BASE.allies * ns.db.allies.nameScale / 100 * ignoring / plates
	if sharedApplied and math.abs(sharedApplied - size) < 0.01 then return end
	font:SetFont(sharedOriginal.path, size, sharedOriginal.flags)
	sharedApplied = size
end
ns.UpdateInstanceNameFont = UpdateSharedFont

ns.RegisterEvent("PLAYER_ENTERING_WORLD", function() ns.SafeCall(UpdateSharedFont) end)
ns.RegisterEvent("ZONE_CHANGED_NEW_AREA", function() ns.SafeCall(UpdateSharedFont) end)

local function BuildFlags(baseFlags)
	if baseFlags and baseFlags:find("SLUG") then
		return "OUTLINE, SLUG"
	end
	return "OUTLINE"
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
	local function FontChanged()
		local current = ns.GetPlateData(frame)
		if current and not current.settingNameFont then
			current.nameFont = nil
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

	-- The game's font, as it was before this addon changed it
	if not data.nameFont then
		local path, size, flags = fontString:GetFont()
		if not path then return end
		data.nameFont = {path = path, size = GameSize(fontString, ns.Known(size) or 9), flags = flags or ""}
	end
	-- The scale of the nameplates, for the allies' names inside instances (a selected one is bigger)
	if not data.fake and not data.isTarget then
		local ok, value = pcall(frame.GetEffectiveScale, frame)
		value = ok and ns.Known(value) or nil
		if type(value) == "number" and value > 0 then plateScale = value end
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
	data.settingNameFont = true
	fontString:SetFont(base.path, base.size * scale, BuildFlags(base.flags))
	data.settingNameFont = false

	if data.side == "enemy" and data.isPlayer and ns.db.enemy.classColor then
		local r, g, b = ns.GetClassColor(data.class)
		if r then
			fontString:SetVertexColor(r, g, b)
		end
	end

	HookNamePosition(frame, data)
	PlaceName(frame, data)
	-- A new name size (Allies page) or nameplate scale: the allies' names inside instances follow
	UpdateSharedFont()
end

Name.Layout = Name.Update
