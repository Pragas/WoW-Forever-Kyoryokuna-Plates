-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- What's new, for the welcome window (Options\Welcome.lua) and the chat message after an update.
--
-- The game can't read CHANGELOG.md, so each release gets short notes here, written for the player (the
-- CHANGELOG stays the detailed record). Newest first; every new version adds its notes at the top, with
-- their Portuguese in Locales\ptPT.lua.
--
-- The window shows:
--   - the first time the addon is used: what the addon is, and how to start;
--   - after an update: the notes of every version since the last one the player saw;
--   - then never again until the next version (the version seen is saved).

local _, ns = ...
local L = ns.L

ns.RELEASE_NOTES = {
	{
		version = "1.18.1",
		fixed = {
			"In a group, the threat glow could show for a moment over an ally's name (a glitch of the game itself). It no longer shows on allies.",
		},
	},
	{
		version = "1.18.0",
		new = {
			"The General page no longer has the buttons for the recorded errors and for your target's diagnostics. They're still there as chat commands: /kp errors, /kp errors clear and /kp diag (all of them in /kp help).",
		},
	},
	{
		version = "1.17.1",
		fixed = {
			"The mark of an elite or a rare (a dragon, or a rare's round medal with a star) could show at the right end of the health bar, over the health percent, with the raid marks on the right. It now always shows left of the bar, where the dragons are.",
		},
	},
	{
		version = "1.17.0",
		new = {
			"/kp errors clear also clears the recorded errors, like /kp clearerrors: the same in the three Kyoryokuna addons.",
		},
	},
	{
		version = "1.16.0",
		new = {
			"The buttons and dropdowns of the options in the addon's own style, like its window's buttons: a long text no longer runs out of its button.",
			"The test mode button on the General page says \"Close the test mode\" while it's open.",
		},
	},
	{
		version = "1.15.1",
		fixed = {
			"The mana bar of a healer ally showing only the name is again as wide as the name when it follows it.",
		},
	},
	{
		version = "1.15.0",
		new = {
			"Enemies page: the height of the game's threat glow above the bar, from 20% to 100% of the game's. The test mode has a threat example to see it.",
		},
	},
	{
		version = "1.14.0",
		new = {
			"Casts that can be interrupted have the game's own yellow by default (Cast Bar page). Your color stays: its \"Default\" button gives the new one.",
		},
		fixed = {
			"Closing the options now closes the test mode too: left open, it could fail to close. Its X has the new look.",
		},
	},
	{
		version = "1.13.0",
		new = {
			"A button beside the X of the options window shrinks it to its title bar, to see and drag what's on the screen, and brings it back.",
		},
	},
	{
		version = "1.12.0",
		new = {
			"The seconds left on your debuffs can have a color and a size of your own (Enemies page; red and 12 by default, as before).",
		},
	},
	{
		version = "1.11.2",
		fixed = {
			"The message asking to restart the game after an update now shows: it was written too early, while the game was still making its interface, and got lost.",
		},
	},
	{
		version = "1.11.1",
		fixed = {
			"After an update with new files, a /reload no longer gives errors: the addon says to close the game and open it again, and stays off until then.",
		},
	},
	{
		version = "1.11.0",
		new = {
			"A new starting look for new installs: larger bars (150 x 20), larger names, the level inside the bar, your crowd control first, raid marks larger and on the right of enemies, and no spell icon on the cast bar. Your own settings don't change.",
		},
	},
	{
		version = "1.10.0",
		new = {
			"Elites, rares and bosses stand out: their border fades from black to gold (elites), silver (rares) or white (bosses), with colors you can change. Your target keeps its own border.",
			"The elite and rare dragon and the skull of bosses can be hidden (Enemies page).",
			"The thickness of the border around the health bar, from 1 to 5 pixels: one for enemies (Enemies page) and one for your target (Target page).",
			"Test mode: a rare mob, with the silver dragon.",
		},
	},
	{
		version = "1.9.0",
		new = {
			"A welcome window: the first time you open the addon, and after each update with what's new and what was fixed.",
			"A message in the chat when the addon was updated.",
		},
	},
	{
		version = "1.8.0",
		new = {
			"Import / Export page: share your settings with a code, and keep backups with a name of your own to put back later.",
			"Your debuffs on enemies: on the left or the right of the bar, your crowd control first, and a border color of its own for it.",
			"Cast bar: the spell name can be hidden, and the icon and the name can go to the left or the right.",
			"Target arrow: above the bar, on its left, on its right or on both sides.",
			"Options: the pages in a new order, more room between the sections, and the mouse wheel no longer changes the sliders.",
		},
	},
}

-- What isn't fixed: limits of the game itself, shown under the notes
ns.KNOWN_ISSUES = {
	"Inside dungeons and raids the game doesn't let addons change the nameplates of allies: there they keep the game's look (smaller names, the game's raid mark).",
	"In combat the game hides some things from addons: the cast bar can't tell whether your interrupt will be ready in time, and your debuffs can't be centered over the bar.",
}

-- "1.10.2" as three numbers
local function Parse(version)
	local a, b, c = tostring(version or ""):match("^(%d+)%.?(%d*)%.?(%d*)")
	return tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0
end

-- -1, 0 or 1 as version a is older, the same or newer than b
function ns.CompareVersions(a, b)
	local a1, a2, a3 = Parse(a)
	local b1, b2, b3 = Parse(b)
	if a1 ~= b1 then return a1 < b1 and -1 or 1 end
	if a2 ~= b2 then return a2 < b2 and -1 or 1 end
	if a3 ~= b3 then return a3 < b3 and -1 or 1 end
	return 0
end

-- What the welcome window has to show now: "first" (a new install), "update" with the notes of the
-- versions not seen yet (newest first), or nil
function ns.GetWelcomeState()
	if not ns.db or not ns.VERSION or not ns.VERSION:match("^%d") then return nil end
	if ns.db.firstWelcome then return "first", {} end
	local seen = ns.db.seenVersion
	if type(seen) ~= "string" then
		-- Used before this window existed: the notes of this version
		seen = nil
	elseif ns.CompareVersions(seen, ns.VERSION) >= 0 then
		return nil
	end
	local notes = {}
	for _, entry in ipairs(ns.RELEASE_NOTES) do
		local newerThanSeen = not seen and ns.CompareVersions(entry.version, ns.VERSION) == 0
			or seen and ns.CompareVersions(entry.version, seen) > 0
		if newerThanSeen and ns.CompareVersions(entry.version, ns.VERSION) <= 0 then
			notes[#notes + 1] = entry
		end
	end
	return "update", notes
end

-- The OK of the window: not shown again until the next version
function ns.MarkWelcomeSeen()
	if not ns.db then return end
	ns.db.seenVersion = ns.VERSION
	ns.db.firstWelcome = nil
end

-- In the chat once per session, a few seconds after logging in (after the game's own messages)
local told = false
ns.RegisterEvent("PLAYER_ENTERING_WORLD", function()
	if told then return end
	told = true
	local function Tell()
		local state = ns.GetWelcomeState()
		if state == "first" then
			ns.Print(L["Thanks for installing! Type /kp to open the options."])
		elseif state == "update" then
			ns.Print(string.format(L["Updated to version %s. Type /kp to see what's new."], ns.VERSION))
		end
	end
	if C_Timer and C_Timer.After then C_Timer.After(5, function() ns.SafeCall(Tell) end) else Tell() end
end)
