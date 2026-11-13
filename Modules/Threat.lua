-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The height of the game's threat glow above an enemy's health bar (turned on by Engine\CVars.lua).
-- The glow is the game's own: three textures of the nameplate (the orange flare, its brighter copy and
-- the mask that shapes them), held on the top of the health bar, as wide as the bar and as tall as the
-- game's art. The addon gives them a height of its own (a share of the game's), so the glow is lower;
-- the game keeps showing, animating and scaling it.
--
-- A fix for a glitch of the game, always on: the glow over an ally. The game never shows it on allies,
-- but when it gives an enemy's nameplate (they're reused) to an ally, it decides the glow once before it
-- knows the unit is a friend (Blizzard_NamePlateBase: SetUnit runs CompactUnitFrame_SetUnit, then
-- OnUnitSet, which runs UpdateIsFriend): the enemy's "show threat" is still set, and in a group an ally
-- with aggro gets the glow, in the ally's threat color, fading out over 2 seconds once the game sees the
-- friend. Seen only because this addon turns the glow on (it's off in the game). Its three parts are
-- hidden at once on an ally: right after the game updates the glow (Engine\Hooks.lua), and whenever the
-- addon updates the nameplate. The game's own state is left as it is (its fade-out ends hidden too).

local _, ns = ...

local Threat = ns.RegisterModule("Threat", {})

local PARTS = {"aggroHighlightBase", "aggroHighlightAdditive", "aggroHighlightMask"}

local function Usable(region)
	return region and not (region.IsForbidden and region:IsForbidden())
end

-- The glow off an ally's nameplate
function Threat.HideOnAlly(frame)
	for _, key in ipairs(PARTS) do
		local part = frame[key]
		if Usable(part) and ns.Known(part:IsShown()) ~= false then
			part:Hide()
		end
	end
end

function Threat.Update(frame, data)
	if data.side ~= "enemy" then
		-- Unless the game itself counts it as an enemy (e.g. a party member of the other faction, who
		-- can be attacked outside instances): then the glow is the game's to show
		if ns.Known(frame.isFriend) ~= false then Threat.HideOnAlly(frame) end
		return
	end
	local share = (ns.db.enemy.threatGlowHeight or 100) / 100
	for _, key in ipairs(PARTS) do
		local part = frame[key]
		if Usable(part) then
			-- The game's height, seen once before the addon changes it (nameplates are reused)
			if not part.kpGameHeight then
				local height = ns.Known(part:GetHeight())
				if type(height) == "number" and height > 0 then part.kpGameHeight = height end
			end
			if part.kpGameHeight then
				part:SetHeight(part.kpGameHeight * share)
			end
		end
	end
end
