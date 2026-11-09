-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

local _, ns = ...
local W = ns.Widgets

ns.AddOptionsPage("Target", function(b)
	local arrow = W.IsOn("target.arrow")

	b:Header("Size")
	-- A setting of the game itself: it needs "Manage the game's nameplate settings" (General page)
	b:Slider("general.targetScale", "Target size", 5, "%",
		"How much bigger the nameplate of your target is. Needs \"Manage the game's nameplate settings\" on the General page.",
		W.IsOn("general.manageGameSettings"))

	b:Header("Arrow")
	b:Check("target.arrow", "Arrow above the target")
	b:Slider("target.arrowScale", "Arrow size", 5, "%", nil, arrow, true)
	b:Slider("target.arrowX", "Left / right", 1, nil, nil, arrow, true)
	b:Slider("target.arrowY", "Down / up", 1, nil, nil, arrow, true)

	b:Header("Health bar")
	b:Color("target.borderColor", "Border color of the target")

	b:Header("Who they target")
	b:Check("target.targetText", "Show who each enemy is targeting",
		"Under the right end of the bar, in the class color of players. While the enemy casts, the target of the cast, under the cast bar.")
end)
