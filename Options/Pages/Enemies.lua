-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

local _, ns = ...
local W = ns.Widgets

ns.AddOptionsPage("Enemies", function(b)
	local debuffs = W.IsOn("enemy.debuffs")

	local positions = {
		{value = "INSIDE_LEFT", text = "Inside, left"},
		{value = "INSIDE_CENTER", text = "Inside, center"},
		{value = "INSIDE_RIGHT", text = "Inside, right"},
		{value = "OUTSIDE_LEFT", text = "Outside, left"},
		{value = "OUTSIDE_RIGHT", text = "Outside, right"},
	}

	b:Header("Look")
	b:Slider("enemy.barWidth", "Bar width", 2, nil, "The width of the health bar. The nameplates follow it when the addon manages the game's nameplate settings.")
	b:Slider("enemy.barHeight", "Bar height", 1, nil, "The height of the health bar.")
	b:Slider("enemy.borderSize", "Border thickness", 1, " px",
		"The border around the health bar, in screen pixels. Your target has its own (Target page).")
	b:Check("enemy.classColor", "Players in their class color", "The health bar and the name of enemy players.")
	b:Slider("enemy.nameScale", "Name size", 5, "%", "100% is the normal size.")
	local healthText = W.IsOn("enemy.showHealthText")
	b:Check("enemy.showHealthText", "Show the health percent")
	b:Dropdown("enemy.healthTextPosition", "Health percent position", positions,
		"Where the health percent sits: inside the bar, or outside it. Outside on the same side as the level, it comes after the level.",
		healthText, true)
	b:Slider("enemy.healthTextScale", "Health percent size", 5, "%",
		"100% is the normal size of the name. Inside the bar, it's never taller than the bar.", healthText, true)
	b:Check("enemy.showLevel", "Show the level")
	b:Dropdown("enemy.levelPosition", "Level position", positions, nil, W.IsOn("enemy.showLevel"), true)
	b:Slider("enemy.levelScale", "Level size", 5, "%", "100% is the normal size. Inside the bar, it's never taller than the bar.",
		W.IsOn("enemy.showLevel"), true)
	b:Check("enemy.questIcon", "Quest icon on quest mobs", "A yellow \"!\" left of the bar of mobs that belong to one of your active quests.")

	b:Header("Elites, rares and bosses")
	b:Text("Their border fades from black, on the left, to a color of their own. Your target always keeps the target's border.",
		{0.7, 0.7, 0.7})
	local rankBorder = W.IsOn("enemy.rankBorder")
	b:Check("enemy.eliteIcon", "Show the elite and rare dragon",
		"The game's gold (elite) or silver (rare) dragon, left of the health bar.")
	b:Check("enemy.skullIcon", "Show the skull",
		"The game shows a skull instead of the level for bosses and for mobs far above your level. Hidden, they show no level.")
	b:Check("enemy.rankBorder", "Border in their own color",
		"Also on the cast bar joined to the health bar.")
	b:Color("enemy.eliteColor", "Elites", nil, rankBorder, true)
	b:Color("enemy.rareColor", "Rares", "Also rare elites (the silver dragon).", rankBorder, true)
	b:Color("enemy.bossColor", "Bosses", nil, rankBorder, true)

	b:Header("Threat")
	local managed = W.IsOn("general.manageGameSettings")
	b:Check("enemy.threatGlow", "Threat glow above the bar",
		"The game's orange glow above the health bar of a mob that's attacking you, or that you're about to pull. Needs \"Manage the game's nameplate settings\" (General page).",
		managed)
	b:Check("enemy.threatFlash", "Flash when gaining or losing aggro",
		"The game's short flash on the health bar when a mob starts or stops attacking you. Needs \"Manage the game's nameplate settings\" (General page).",
		managed)

	b:Header("My debuffs")
	b:Check("enemy.debuffs", "Show my debuffs above the name")
	b:Dropdown("enemy.debuffAlign", "Position", {
		{value = "LEFT", text = "Left"},
		{value = "RIGHT", text = "Right"},
	}, "Where the row of icons sits over the health bar: from its left end, or from its right end.", debuffs, true)
	local ccFirst = W.All(debuffs, W.IsOn("enemy.debuffCCFirst"))
	b:Check("enemy.debuffCCFirst", "My crowd control first",
		"Your stuns, roots, fears, sleeps and other controls (what the game counts as crowd control) come first in the row.",
		debuffs, true)
	b:Check("enemy.debuffCCBorder", "Crowd control border in its own color",
		"Every icon has a black border; this gives the crowd control ones a color of their own. Needs \"My crowd control first\": only then can the addon tell them apart.",
		ccFirst, true)
	b:Color("enemy.debuffCCBorderColor", "Crowd control border color", nil,
		W.All(ccFirst, W.IsOn("enemy.debuffCCBorder")), true)
	b:Color("enemy.debuffTimerColor", "Time left color",
		"The color of the seconds left on each of your debuffs.", debuffs, true)
	b:Slider("enemy.debuffTimerSize", "Time left size", 1, nil,
		"The size of the seconds left on each of your debuffs. 12 is the size it had before.", debuffs, true)
	b:Slider("enemy.debuffSize", "Icon size", 1, nil, nil, debuffs, true)
	b:Slider("enemy.debuffMax", "Most icons", 1, nil, nil, debuffs, true)
	b:Slider("enemy.debuffY", "Height above the bar", 1, nil, nil, debuffs, true)
end)
