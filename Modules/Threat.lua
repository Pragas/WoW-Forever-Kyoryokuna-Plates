-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The height of the game's threat glow above an enemy's health bar (turned on by Engine\CVars.lua).
-- The glow is the game's own: three textures of the nameplate (the orange flare, its brighter copy and
-- the mask that shapes them), held on the top of the health bar, as wide as the bar and as tall as the
-- game's art. The addon gives them a height of its own (a share of the game's), so the glow is lower;
-- the game keeps showing, animating and scaling it.

local _, ns = ...

local Threat = ns.RegisterModule("Threat", {})

local PARTS = {"aggroHighlightBase", "aggroHighlightAdditive", "aggroHighlightMask"}

local function Usable(region)
	return region and not (region.IsForbidden and region:IsForbidden())
end

function Threat.Update(frame, data)
	if data.side ~= "enemy" then return end
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
