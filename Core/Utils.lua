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
