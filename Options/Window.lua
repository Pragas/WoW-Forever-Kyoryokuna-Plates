-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The options window: a list of pages on the left and the chosen page on the right, which scrolls when
-- it's taller than the window. It opens with /kp, from the addon button of the minimap (the addon
-- compartment) and from the game's own settings (Options > AddOns). Each page is built the first time
-- it's shown.
--
-- Also here: the chat commands, including /kp diag, which tells what the game lets the addon see about
-- the current target (useful to know what's secret in combat and inside instances).

local _, ns = ...
local L = ns.L

local WIDTH, HEIGHT = 780, 580
local NAV_WIDTH = 170
local CONTENT_WIDTH = 540

local pages = {}
local window, selectedPage

-- Pages register themselves (Options\Pages\*.lua) in the order they should appear
function ns.AddOptionsPage(name, build)
	pages[#pages + 1] = {name = name, build = build}
end

local function SelectPage(page)
	if selectedPage and selectedPage.scroll then
		selectedPage.scroll:Hide()
		selectedPage.button:UnlockHighlight()
	end
	selectedPage = page
	page.button:LockHighlight()

	if not page.scroll then
		local scroll = CreateFrame("ScrollFrame", nil, window)
		scroll:SetPoint("TOPLEFT", window, "TOPLEFT", NAV_WIDTH + 24, -48)
		scroll:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -16, 16)
		local content = CreateFrame("Frame", nil, scroll)
		content:SetSize(CONTENT_WIDTH, 100)
		scroll:SetScrollChild(content)
		scroll:EnableMouseWheel(true)
		scroll:SetScript("OnMouseWheel", function(self, delta)
			local maxScroll = math.max(0, content:GetHeight() - self:GetHeight())
			local value = math.min(maxScroll, math.max(0, self:GetVerticalScroll() - delta * 40))
			self:SetVerticalScroll(value)
		end)
		local builder = ns.Widgets.NewBuilder(content)
		ns.SafeCall(page.build, builder)
		content:SetHeight(builder:Height())
		page.scroll = scroll
	end
	page.scroll:SetVerticalScroll(0)
	page.scroll:Show()
	ns.Widgets.RefreshAll()
	-- The test mode shows the examples of this page
	if ns.Preview and ns.Preview.SetPage then
		ns.Preview.SetPage(page.name)
	end
end

local function CreateWindow()
	window = CreateFrame("Frame", "KyoryokunaPlatesOptionsWindow", UIParent, "BackdropTemplate")
	window:SetSize(WIDTH, HEIGHT)
	window:SetPoint("CENTER")
	-- Below the game's color picker, which opens over it
	window:SetFrameStrata("HIGH")
	window:SetClampedToScreen(true)
	window:SetMovable(true)
	window:EnableMouse(true)
	window:RegisterForDrag("LeftButton")
	window:SetScript("OnDragStart", window.StartMoving)
	window:SetScript("OnDragStop", window.StopMovingOrSizing)
	window:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4},
	})
	window:SetBackdropColor(0.06, 0.06, 0.08, 0.96)
	window:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
	window:SetScript("OnHide", ns.Widgets.ClosePopup)
	-- Escape closes it
	tinsert(UISpecialFrames, "KyoryokunaPlatesOptionsWindow")

	local title = window:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", window, "TOPLEFT", 18, -16)
	title:SetText(ns.TITLE)
	local version = window:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
	version:SetPoint("LEFT", title, "RIGHT", 8, -1)
	version:SetText("v" .. ns.VERSION)

	local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", window, "TOPRIGHT", -4, -4)
	-- The template closes its parent with the game's panel system (HideUIPanel), which the game blocks
	-- for addons in combat: the window then couldn't be closed. It's simply hidden instead.
	close:SetScript("OnClick", function() window:Hide() end)
	window.closeButton = close

	local divider = window:CreateTexture(nil, "ARTWORK")
	divider:SetColorTexture(1, 1, 1, 0.12)
	divider:SetWidth(1)
	divider:SetPoint("TOPLEFT", window, "TOPLEFT", NAV_WIDTH + 12, -44)
	divider:SetPoint("BOTTOMLEFT", window, "BOTTOMLEFT", NAV_WIDTH + 12, 14)

	for i, page in ipairs(pages) do
		local button = CreateFrame("Button", nil, window)
		button:SetSize(NAV_WIDTH - 8, 26)
		button:SetPoint("TOPLEFT", window, "TOPLEFT", 12, -46 - (i - 1) * 28)
		button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
		button:GetHighlightTexture():SetVertexColor(1, 0.82, 0, 0.18)
		local text = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		text:SetPoint("LEFT", button, "LEFT", 10, 0)
		text:SetText(L[page.name])
		button:SetScript("OnClick", function() SelectPage(page) end)
		page.button = button
	end

	window:Hide()
end

function ns.OpenOptions()
	if not ns.db then return end
	if not window then CreateWindow() end
	window:Show()
	local page = selectedPage or pages[1]
	selectedPage = nil
	SelectPage(page)
end

function ns.ToggleOptions()
	if window and window:IsShown() then
		window:Hide()
	else
		ns.OpenOptions()
	end
end

function ns.RefreshOptions()
	if window and window:IsShown() then
		ns.Widgets.RefreshAll()
	end
end

-- After a change of language: the window and its pages are made again with the new texts, and it opens
-- again on the same page if it was open
function ns.RebuildOptions()
	if not window then return end
	local wasShown = window:IsShown()
	local pageIndex
	for i, page in ipairs(pages) do
		if page == selectedPage then pageIndex = i end
		page.scroll = nil
		page.button = nil
	end
	window:Hide()
	window = nil
	selectedPage = pages[pageIndex or 1]
	if wasShown then
		ns.OpenOptions()
	end
end

-- The game's settings (Options > AddOns): a short page with a button that opens this window -------

local function RegisterSettingsCategory()
	if not (Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory) then return end
	local panel = CreateFrame("Frame")
	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)
	title:SetText(ns.TITLE)
	local text = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	text:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
	text:SetText(L["All options are in the addon's own window. You can also type /kp."])
	local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	button:SetSize(200, 26)
	button:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -12)
	button:SetText(L["Open options"])
	button:SetScript("OnClick", function()
		if SettingsPanel and SettingsPanel:IsShown() and not InCombatLockdown() then
			HideUIPanel(SettingsPanel)
		end
		ns.OpenOptions()
	end)
	local category = Settings.RegisterCanvasLayoutCategory(panel, ns.SHORT_TITLE)
	Settings.RegisterAddOnCategory(category)
end

ns.RegisterEvent("PLAYER_LOGIN", RegisterSettingsCategory)

-- Addon compartment (the addon button of the minimap) ----------------------------------------------

function KyoryokunaPlates_OnAddonCompartmentClick()
	ns.ToggleOptions()
end

function KyoryokunaPlates_OnAddonCompartmentEnter(_, button)
	GameTooltip:SetOwner(button or UIParent, "ANCHOR_LEFT")
	GameTooltip:SetText(ns.TITLE)
	GameTooltip:AddLine(L["Click to open the options."], 1, 1, 1)
	GameTooltip:Show()
end

function KyoryokunaPlates_OnAddonCompartmentLeave()
	GameTooltip:Hide()
end

-- Diagnostics --------------------------------------------------------------------------------------

local function Describe(value)
	if ns.IsSecret(value) then return "|cffff8000" .. L["secret"] .. "|r" end
	if value == nil then return "|cff999999nil|r" end
	return tostring(value)
end

function ns.PrintDiagnostics()
	local function Line(label, value)
		DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100" .. L[label] .. ":|r " .. value)
	end
	ns.Print(L["Diagnostics"])
	Line("Version", ns.VERSION .. " (interface " .. tostring(ns.INTERFACE) .. ")")
	local _, instanceType = IsInInstance()
	Line("Instance", tostring(instanceType))
	Line("In combat", tostring(InCombatLockdown()))

	local spellID = ns.GetInterruptSpell and ns.GetInterruptSpell()
	local spellName = spellID and C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(spellID)
	Line("Interrupt", spellID and (tostring(spellName) .. " (" .. spellID .. ")") or L["none found"])
	Line("Interrupt ready", Describe(ns.IsInterruptReady and ns.IsInterruptReady()))
	local tracking = spellID and ns.GetInterruptTracking and ns.GetInterruptTracking()
	if tracking then
		Line("Interrupt last used", tracking.usedAgo and string.format(L["%.1fs ago"], tracking.usedAgo) or L["not seen"])
	end

	if not UnitExists("target") then
		Line("Target", L["none"])
		return
	end
	local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit("target", issecure())
	local frame = plate and plate.UnitFrame
	if not frame then
		Line("Target nameplate", L["not found (no nameplate, or protected by the game)"])
	else
		Line("Target nameplate forbidden", tostring(frame:IsForbidden()))
		Line("Managed by the addon", ns.GetPlateData(frame) and L["yes"] or L["no"])
	end
	ns.PrintTargetDiagnostics(Line)
end


function ns.PrintTargetDiagnostics(Line)
	Line("Name", Describe(UnitName("target")))
	Line("Health", Describe(UnitHealth("target")))
	Line("Max health", Describe(UnitHealthMax("target")))
	Line("Class", Describe(UnitClassBase("target")))
	Line("Reaction", Describe(UnitReaction("target", "player")))
	Line("Threat status", Describe(UnitThreatSituation("player", "target")))
	local _, _, _, _, castEnd, _, _, notInterruptible = UnitCastingInfo("target")
	Line("Cast end time", Describe(castEnd))
	Line("Cast can't be interrupted", Describe(notInterruptible))
	Line("Raid mark", Describe(GetRaidTargetIndex("target")))
	Line("Group role", Describe(UnitGroupRolesAssigned("target")))
	if C_QuestLog and C_QuestLog.UnitIsRelatedToActiveQuest then
		Line("Quest unit", Describe(C_QuestLog.UnitIsRelatedToActiveQuest("target")))
	end
	if C_Secrets and C_Secrets.ShouldUnitIdentityBeSecret then
		Line("Identity secret", Describe(C_Secrets.ShouldUnitIdentityBeSecret("target")))
	end
end

-- Chat commands ------------------------------------------------------------------------------------

SLASH_KYORYOKUNAPLATES1 = "/kp"
SLASH_KYORYOKUNAPLATES2 = "/kyoryokunaplates"
SlashCmdList.KYORYOKUNAPLATES = function(message)
	local command = strtrim(message or ""):lower()
	if command == "errors" then
		ns.PrintErrors()
	elseif command == "clearerrors" then
		ns.ClearErrors()
	elseif command == "diag" then
		ns.PrintDiagnostics()
	elseif command == "test" then
		ns.Preview.Toggle()
	elseif command == "help" then
		ns.Print(L["Commands:"])
		DEFAULT_CHAT_FRAME:AddMessage("  /kp - " .. L["open the options"])
		DEFAULT_CHAT_FRAME:AddMessage("  /kp test - " .. L["test mode: example nameplates for every case"])
		DEFAULT_CHAT_FRAME:AddMessage("  /kp diag - " .. L["what the game lets the addon see about your target"])
		DEFAULT_CHAT_FRAME:AddMessage("  /kp errors - " .. L["show recorded errors"])
		DEFAULT_CHAT_FRAME:AddMessage("  /kp clearerrors - " .. L["clear recorded errors"])
	else
		ns.ToggleOptions()
	end
end
