-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

local _, ns = ...
local W = ns.Widgets

ns.AddOptionsPage("Cast Bar", function(b)
	local apart = function() return not ns.Get("castBar.attached") end

	b:Header("Colors")
	b:Color("castBar.readyColor", "Can be interrupted",
		"A cast you can interrupt: your interrupt is ready (or you don't have one).")
	b:Color("castBar.notReadyColor", "My interrupt on cooldown",
		"A cast that could be interrupted, but your interrupt is on cooldown.")
	b:Color("castBar.nonInterruptibleColor", "Can't be interrupted",
		"Spells that can never be interrupted.")

	b:Header("Bar")
	b:Check("castBar.attached", "Join to the health bar",
		"Right under the health bar, just as wide, sharing its border. Off, the cast bar has its own width and distance.")
	b:Slider("castBar.width", "Width", 2, nil, nil, apart, true)
	b:Slider("castBar.gap", "Distance from the health bar", 1, nil, nil, apart, true)
	b:Slider("castBar.offsetX", "Horizontal position", 1, nil, "0 is centered under the health bar.", apart, true)
	b:Slider("castBar.height", "Height", 1)
	b:Check("castBar.showIcon", "Show the spell icon")
	b:Slider("castBar.iconScale", "Spell icon size", 5, "%", "100% is as tall as the cast bar.", W.IsOn("castBar.showIcon"), true)
	b:Slider("castBar.textScale", "Spell name size", 5, "%", "A percentage of the game's own size.")
	b:Check("castBar.hideOnAllies", "Hide on allies")
end)
