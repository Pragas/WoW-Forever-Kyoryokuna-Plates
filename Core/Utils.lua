-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Helpers shared by the modules. On this client some values come back "secret" (in combat and inside
-- instances): the game's widgets can show them, but the addon can't compare them or do maths with them.
-- Everything that needs a real value goes through Known(), which turns a secret into nil, so the caller
-- simply treats it as unknown.

local _, ns = ...

local issecretvalue = issecretvalue or function() return false end

-- The value if the addon may use it, nil if it's secret
function ns.Known(value)
	if issecretvalue(value) then return nil end
	return value
end

function ns.IsSecret(value)
	return issecretvalue(value)
end

-- Screen pixels ------------------------------------------------------------------------------------

-- The size of one screen pixel in a region's own units (its scale counted), or nil when the game
-- doesn't tell (e.g. a secret scale)
function ns.OnePixel(region)
	local factor = PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor()
	local scale = region and region.GetEffectiveScale and ns.Known(region:GetEffectiveScale())
	if type(factor) == "number" and type(scale) == "number" and scale > 0 then
		return factor / scale
	end
end

-- A size rounded to a whole number of screen pixels (at least one), so a bar's top and bottom edges
-- (and its left and right ones) always fall at the same place within a pixel and move together
function ns.ToWholePixels(region, size)
	local pixel = ns.OnePixel(region)
	if not pixel then return size end
	return math.max(1, math.floor(size / pixel + 0.5)) * pixel
end

-- An offset (a place, not a size: it may be 0) rounded to whole screen pixels. A line one pixel thick
-- placed half way into a pixel may be rounded away by the game, so what holds a bar sits on whole pixels.
function ns.SnapToPixels(region, offset)
	local pixel = ns.OnePixel(region)
	if not pixel then return offset end
	return math.floor(offset / pixel + 0.5) * pixel
end

-- The look shared by the bars: the game's classic bar fill, which takes any color
ns.BAR_TEXTURE = "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill"
ns.FONT = "Fonts\\FRIZQT__.TTF"

function ns.GetClassColor(class)
	class = ns.Known(class)
	if not class then return nil end
	local color = (C_ClassColor and C_ClassColor.GetClassColor(class)) or (RAID_CLASS_COLORS and RAID_CLASS_COLORS[class])
	if color then
		return color.r, color.g, color.b
	end
end

-- A color saved as {r, g, b}
function ns.Unpack(color)
	if type(color) == "table" then
		return color[1] or 1, color[2] or 1, color[3] or 1
	end
	return 1, 1, 1
end

-- Some changes are blocked in combat (CVars, the size of the nameplates): they wait until it ends
local pending = {}

function ns.RunOutOfCombat(key, func)
	if not InCombatLockdown() then
		func()
		return
	end
	pending[key] = func
end

ns.RegisterEvent("PLAYER_REGEN_ENABLED", function()
	for key, func in pairs(pending) do
		pending[key] = nil
		ns.SafeCall(func)
	end
end)
