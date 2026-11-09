-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

local _, ns = ...

local POSITIONS = {
	{value = "LEFT", text = "Left"},
	{value = "TOP", text = "Above the name"},
	{value = "RIGHT", text = "Right"},
}

ns.AddOptionsPage("Raid Marks", function(b)
	b:Text("Where the raid mark (skull, cross, square...) shows on the nameplates, for enemies and allies apart.",
		{0.7, 0.7, 0.7})

	b:Header("Enemies")
	b:Dropdown("raidMarks.enemyPosition", "Position", POSITIONS,
		"Left or right: beside the health bar, past the level, the health percent and the icons shown on that side; beside the name when only the name shows.")

	b:Header("Allies")
	b:Dropdown("raidMarks.allyPosition", "Position", POSITIONS,
		"Left or right: beside the health bar (past the role icon when it's on that side), or beside the name when it's name only.")
	b:Text("Inside dungeons and raids the game doesn't let addons change the nameplates of allies: there their mark stays where the game puts it.",
		{0.7, 0.7, 0.7})
end)
