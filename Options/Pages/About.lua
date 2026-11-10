-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

local _, ns = ...

local LABEL = {1, 0.82, 0}
local GREY = {0.75, 0.75, 0.75}

local EMBLEM_SIZE = 64

ns.AddOptionsPage("About", function(b)
	-- The addon's emblem, at the right of the version and author
	local emblem = b.content:CreateTexture(nil, "ARTWORK")
	emblem:SetTexture(ns.ICON)
	emblem:SetSize(EMBLEM_SIZE, EMBLEM_SIZE)
	emblem:SetPoint("TOPRIGHT", b.content, "TOPRIGHT", -24, b.y - 28)

	b:Header(ns.SHORT_TITLE)
	b:Text("Version", LABEL)
	b:Text(ns.VERSION)
	b:Text("Author", LABEL)
	b:Text(ns.AUTHOR)
	b:Button("See what's new", function() ns.ShowWhatsNew() end,
		"The window of what's new in each version, and the known issues.")

	b:Header("How it works")
	b:Text("Kyoryokuna Plates doesn't create nameplates of its own. It takes the game's nameplates and changes how they look, so the game keeps handling health, positions, clicks, its threat glow and its health text. That's why it keeps working in combat and with the values the game hides from addons.", GREY)
	b:Text("Some options are the game's own nameplate settings. You can put them back as they were with \"Manage the game's nameplate settings\" on the General page.", GREY)

	b:Header("Copyright")
	b:Text(ns.COPYRIGHT)
	b:Text("This addon may be used freely for personal use. Copying, modifying or redistributing its code, in whole or in part, is not allowed without written permission from the author. See the LICENSE file for the full terms.", GREY)
	b:Text("World of Warcraft is a trademark of Blizzard Entertainment, Inc. This addon is not affiliated with or endorsed by Blizzard Entertainment.", GREY)
end)
