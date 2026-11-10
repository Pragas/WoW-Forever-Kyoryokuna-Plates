-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

local _, ns = ...
local W = ns.Widgets

local ROLE_POSITIONS = {
	{value = "LEFT", text = "Left"},
	{value = "RIGHT", text = "Right"},
	{value = "TOP", text = "Above the name"},
}

ns.AddOptionsPage("Allies", function(b)
	local managed = W.IsOn("general.manageGameSettings")
	local roles = W.IsOn("allies.roleIcons")
	local mana = W.IsOn("allies.manaBar")

	b:Text("Inside dungeons and raids the game doesn't let addons change the nameplates of allies. There only name only and the class colors apply.",
		{0.7, 0.7, 0.7})

	b:Header("Players")
	b:Check("allies.nameOnly", "Name only (no health bar)", nil, managed)
	b:Check("allies.clickThrough", "Click through allies",
		"Clicking the name of an ally doesn't select them; you select them on their character or the party frames.", managed)
	b:Slider("allies.nameScale", "Name size", 5, "%", "100% is the normal size.")
	b:Slider("allies.nameHeight", "Name height", 1, nil,
		"How high above the player's head the name sits, with name only. Lower brings it closer to the head.",
		W.IsOn("allies.nameOnly"), true)

	b:Header("Group roles")
	b:Check("allies.roleIcons", "Show the role of players in your group",
		"The tank, healer or damage icon next to the name, from the group finder or the role the leader gave.")
	b:Check("allies.roleTank", "Tanks", nil, roles, true)
	b:Check("allies.roleHealer", "Healers", nil, roles, true)
	b:Check("allies.roleDamager", "Damage", nil, roles, true)
	b:Dropdown("allies.roleIconPosition", "Position", ROLE_POSITIONS,
		"Left or right: beside the health bar, or beside the name when it's name only.", roles, true)
	b:Slider("allies.roleIconSize", "Size", 1, nil, nil, roles, true)

	b:Header("Healer mana")
	b:Check("allies.manaBar", "Mana bar of healers",
		"Under the name. With a health bar, right under the health bar and just as wide.")
	b:Check("allies.manaBarFollowName", "Same width as the name", "With name only.", mana, true)
	b:Slider("allies.manaBarWidth", "Width", 1, nil, nil, W.All(mana, function() return not ns.Get("allies.manaBarFollowName") end), true)
	b:Slider("allies.manaBarHeight", "Height", 1, nil, nil, mana, true)
end)
