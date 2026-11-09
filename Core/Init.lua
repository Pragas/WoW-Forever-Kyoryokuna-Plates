-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The namespace shared by every file, the version, and a small event bus: any file can listen to a game
-- event without creating its own frame, and several files can listen to the same event.

local addonName, ns = ...

ns.NAME = addonName
ns.TITLE = "|cffffe00aKyoryokuna|r |cff0055ffPlates|r"
ns.SHORT_TITLE = "Kyoryokuna Plates"
ns.AUTHOR = "Pragas"
ns.COPYRIGHT = "Copyright (c) 2026 Pragas. All Rights Reserved."
-- The addon's emblem: a KP monogram (white K, P in the blue of "Plates") over a blue nameplate bar, on a
-- deep navy rounded square with a soft white outline. Made in the sizes it's shown at, so the game never
-- has to shrink it (which makes its edges jagged): 64 for the About page, 32 for the minimap button and
-- the game's addon list (the IconTexture of the TOC).
ns.ICON = "Interface\\AddOns\\" .. addonName .. "\\Media\\Icon"
ns.ICON_SMALL = "Interface\\AddOns\\" .. addonName .. "\\Media\\IconSmall"

local GetMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
ns.VERSION = (GetMetadata and GetMetadata(addonName, "Version")) or "?"

local _, _, _, interfaceVersion = GetBuildInfo()
ns.INTERFACE = interfaceVersion
ns.IS_FOREVER = interfaceVersion >= 16000 and interfaceVersion < 17000

-- Event bus ----------------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
local listeners = {}

-- Each listener runs protected, so an error in one doesn't stop the others (see Errors.lua)
eventFrame:SetScript("OnEvent", function(_, event, ...)
	local list = listeners[event]
	if not list then return end
	for i = 1, #list do
		ns.SafeCall(list[i], event, ...)
	end
end)

function ns.RegisterEvent(event, func)
	local list = listeners[event]
	if not list then
		list = {}
		listeners[event] = list
		eventFrame:RegisterEvent(event)
	end
	list[#list + 1] = func
end

-- Until Errors.lua loads, a call is just a call
function ns.SafeCall(func, ...)
	return func(...)
end

function ns.Print(text)
	DEFAULT_CHAT_FRAME:AddMessage(ns.TITLE .. ": " .. tostring(text))
end
