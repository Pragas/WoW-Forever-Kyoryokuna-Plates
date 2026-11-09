-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

local _, ns = ...
local W = ns.Widgets

ns.AddOptionsPage("General", function(b)

	b:Header("Language")
	b:Dropdown("general.language", "Language", ns.LANGUAGES, "The language of the addon's texts.")

	b:Header("Test mode")
	b:Text("Example nameplates for every case, to see how the options look without having to find each case in the game. They follow every change at once.",
		{0.7, 0.7, 0.7})
	b:Button("Open the test mode", function() ns.Preview.Toggle() end, "Also with /kp test.")

	b:Header("Nameplates")
	b:Check("general.manageGameSettings", "Manage the game's nameplate settings",
		"Lets this addon set the game's own nameplate settings: width, target size, which nameplates show, class colors, name-only allies and click-through. Turning it off puts back the values they had before.")
	b:Check("general.stackNameplates", "Stack enemy nameplates",
		"Off, the nameplates of mobs close together overlap, and the game keeps swapping which one is in front, so a bar can seem to jump up and down. On, the game pushes them apart so they never overlap.",
		W.IsOn("general.manageGameSettings"), true)

	b:Header("Minimap")
	b:Check("general.minimapIcon", "Show the minimap button",
		"A click on it opens the options. Drag it to move it around the minimap.")

	b:Header("Support")
	b:Check("general.reportErrors", "Tell me in the chat when an error happens",
		"Errors are always kept. Read them with /kp errors.")
	b:Button("Show recorded errors", function() ns.PrintErrors() end)
	b:Button("Delete recorded errors", function() ns.ConfirmClearErrors() end,
		"Asks for confirmation first. Also with /kp clearerrors.")
	b:Button("Diagnostics of my target", function() ns.PrintDiagnostics() end,
		"Prints in the chat what the game lets the addon see about your current target.")
end)
