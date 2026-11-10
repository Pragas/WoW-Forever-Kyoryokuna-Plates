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
	b:Check("castBar.hideOnAllies", "Hide on allies")

	b:Header("Spell")
	local icon, text = W.IsOn("castBar.showIcon"), W.IsOn("castBar.showText")
	b:Check("castBar.showIcon", "Show the spell icon")
	b:Dropdown("castBar.iconPosition", "Spell icon position", {
		{value = "LEFT", text = "Left"},
		{value = "RIGHT", text = "Right"},
	}, "Inside the left or the right end of the cast bar.", icon, true)
	b:Slider("castBar.iconScale", "Spell icon size", 5, "%", "100% is as tall as the cast bar.", icon, true)
	b:Check("castBar.showText", "Show the spell name")
	b:Dropdown("castBar.textPosition", "Spell name position", {
		{value = "LEFT", text = "Left"},
		{value = "CENTER", text = "Center"},
		{value = "RIGHT", text = "Right"},
	}, "At the left, in the middle or at the right of the cast bar. On the side of the icon, it starts after the icon.", text, true)
	b:Slider("castBar.textScale", "Spell name size", 5, "%", "A percentage of the game's own size.", text, true)
end)
