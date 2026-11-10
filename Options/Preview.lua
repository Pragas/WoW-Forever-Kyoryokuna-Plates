-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Test mode: a window with example nameplates for every case (enemy, target, neutral, tapped, elite,
-- raid mark, enemy player, boss, the three cast bar colors, allies). Each example is built like the
-- game's nameplates (health bar, name, cast bar, raid mark, elite dragon) and handed to the same modules
-- as the real ones, so what shows here is what the options really do. The examples follow every change
-- of the options at once. Opened from the General page or with /kp test. While the options are open,
-- it shows only the examples of the page that's open (General, Import / Export and About: all of them).
--
-- What the game itself would do on a real nameplate (the bar's value and color, the name, the cast bar
-- running, name-only allies) is done here by hand; everything else comes from the modules.

local _, ns = ...
local L = ns.L

local Preview = {}
ns.Preview = Preview

local COLUMNS = 2
local CELL_WIDTH = 320
local PLATE_HEIGHT = 55
-- The cards: the space between them, the band at their top with the title and the description, the
-- space between that band and the nameplate, and the room under the nameplate (in the nameplate's own
-- units: the target's name under its cast bar goes there)
local CARD_GAP = 8
local TITLE_BAND = 40
local CONTENT_GAP = 8
local PLATE_BOTTOM = 14
local MIN_CARD_HEIGHT = 96
local TITLE_SIZE = 14
local TOP = 52
local PADDING = 16
local SCROLLBAR_WIDTH = 16
local VISIBLE_HEIGHT = 560
local SCROLL_STEP = 60

local ICONS = {
	immolate = "Interface\\Icons\\Spell_Fire_Immolation",
	frostbolt = "Interface\\Icons\\Spell_Frost_FrostBolt02",
	heal = "Interface\\Icons\\Spell_Holy_Heal",
	shadow = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
}

local HOSTILE = {1, 0, 0}
local NEUTRAL = {1, 1, 0}
local TAPPED = {0.6, 0.6, 0.6}

-- Each example lists the option pages it belongs to: with one of those pages open in the options, the
-- test mode shows only its examples. The General, Import / Export and About pages show them all.
local ENEMIES, TARGET, CAST, ALLIES, MARKS = "Enemies", "Target", "Cast Bar", "Allies", "Raid Marks"

local SCENARIOS = {
	{label = "Enemy", desc = "A hostile mob from one of your quests", name = "Cursed Sailor", level = 26, health = 100, color = HOSTILE, quest = true,
		targetName = "Katara", targetClass = "MAGE", pages = {ENEMIES, TARGET}},
	{label = "Target", desc = "Your current target, with your debuffs", name = "Cursed Marine", level = 28, health = 55, color = HOSTILE, isTarget = true, debuffs = 2,
		targetName = "Posttal", targetClass = "SHAMAN", pages = {ENEMIES, TARGET}},
	{label = "Target casting", desc = "Your target casting at someone", name = "Dragonmaw Shadowcaller", level = 29, health = 74, color = HOSTILE, isTarget = true,
		cast = "Shadow Bolt", castIcon = ICONS.shadow, castState = "ready", castTarget = "Katara", castTargetClass = "MAGE",
		pages = {TARGET, CAST}},
	{label = "Neutral", desc = "Doesn't attack until you do", name = "Mottled Boar", level = 24, health = 100, color = NEUTRAL, pages = {ENEMIES}},
	{label = "Tapped by others", desc = "Already tagged by another player", name = "Bluegill Warrior", level = 25, health = 60, color = TAPPED, pages = {ENEMIES}},
	{label = "Elite", desc = "A stronger mob, with the elite dragon", name = "Nightveiled Rotheap", level = 31, health = 100, color = HOSTILE, elite = true, pages = {ENEMIES}},
	{label = "Raid mark", desc = "A mob with a raid mark", name = "Fen Creeper", level = 24, health = 58, color = HOSTILE, raidMark = 8, pages = {ENEMIES, MARKS}},
	{label = "Quest mob with a raid mark", desc = "The mark goes past the quest icon", name = "Murloc Forager", level = 25, health = 100, color = HOSTILE,
		quest = true, raidMark = 2, pages = {MARKS}},
	{label = "Enemy player", desc = "In the color of their class", name = "Viktor", level = 27, health = 80, isPlayer = true, class = "WARLOCK", pages = {ENEMIES}},
	{label = "Boss", desc = "Its level shows as a skull", name = "Mother Fang", level = -1, health = 100, color = HOSTILE, elite = true, pages = {ENEMIES}},
	{label = "Low level", desc = "Far below your level", name = "Young Wetlands Crocolisk", level = 18, health = 100, color = HOSTILE, pages = {ENEMIES}},
	{label = "Cast: can be interrupted", desc = "Your interrupt is ready", name = "Dragonmaw Bonewarder", level = 28, health = 53, color = HOSTILE,
		cast = "Immolate", castIcon = ICONS.immolate, castState = "ready", castTarget = "Posttal Kyoryokuna", castTargetClass = "SHAMAN",
		pages = {CAST}},
	{label = "Cast: my interrupt on cooldown", desc = "Your interrupt is on cooldown", name = "Dragonmaw Bonewarder", level = 28, health = 21, color = HOSTILE,
		cast = "Shadow Bolt", castIcon = ICONS.shadow, castState = "cooldown", castTarget = "Katara", castTargetClass = "MAGE",
		pages = {CAST}},
	{label = "Cast: can't be interrupted", desc = "A spell that can't be interrupted", name = "Dragonmaw Shadowcaller", level = 29, health = 90, color = HOSTILE,
		cast = "Heal", castIcon = ICONS.heal, castState = "uninterruptible", pages = {CAST}},
	{label = "Ally", desc = "A player of your faction", side = "allies", name = "Kalendris Swiftsong", isPlayer = true, class = "HUNTER", pages = {ALLIES}},
	{label = "Ally selected", desc = "No arrow, and it doesn't grow", side = "allies", name = "Lunara Nightwing", isPlayer = true, class = "DRUID", isTarget = true,
		pages = {ALLIES, TARGET}},
	{label = "Ally tank", desc = "With the tank role icon", side = "allies", name = "Toadz Malone", isPlayer = true, class = "WARRIOR", role = "TANK", pages = {ALLIES}},
	{label = "Ally healer", desc = "With the role icon and the mana bar", side = "allies", name = "Posttal Kyoryokuna", isPlayer = true, class = "SHAMAN",
		role = "HEALER", mana = 70, raidMark = 6, pages = {ALLIES, MARKS}},
	{label = "Ally with a raid mark", desc = "A player of your faction, marked", side = "allies", name = "Vellira Dawnsong", isPlayer = true, class = "PALADIN",
		raidMark = 1, pages = {MARKS}},
}

-- The option page the examples follow (nil: all of them)
local currentPage

local function BelongsToPage(scenario)
	if not currentPage then return true end
	for _, page in ipairs(scenario.pages or {}) do
		if page == currentPage then return true end
	end
	return false
end

local window
local examples = {}

-- An example nameplate ---------------------------------------------------------------------------------

local function SetRaidMarkTexture(texture, index)
	texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	local column, row = (index - 1) % 4, math.floor((index - 1) / 4)
	texture:SetTexCoord(column / 4, (column + 1) / 4, row / 4, (row + 1) / 4)
end

local function SetEliteTexture(texture)
	local atlas = "nameplates-icon-elite-gold"
	if C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) then
		texture:SetAtlas(atlas)
	else
		texture:SetTexture("Interface\\Tooltips\\EliteNameplateIcon")
	end
end

local function NewFontString(parent, fontObject, size)
	local text = parent:CreateFontString(nil, "OVERLAY")
	if fontObject and _G[fontObject] then
		text:SetFontObject(_G[fontObject])
	else
		text:SetFont(ns.FONT, size, "")
	end
	return text
end

local function BuildPlate(parent)
	local frame = CreateFrame("Frame", nil, parent)
	-- Like the game's nameplates, the example isn't scaled with the interface
	if frame.SetIgnoreParentScale then frame:SetIgnoreParentScale(true) end

	local container = CreateFrame("Frame", nil, frame)
	local bar = CreateFrame("StatusBar", nil, container)
	bar:SetAllPoints(container)
	bar:SetMinMaxValues(0, 100)
	container.healthBar = bar
	frame.HealthBarsContainer = container
	frame.healthBar = bar

	frame.name = NewFontString(frame, "SystemFont_NamePlate", 9)

	local castBar = CreateFrame("StatusBar", nil, frame)
	castBar:SetMinMaxValues(0, 1)
	castBar.Icon = castBar:CreateTexture(nil, "OVERLAY")
	castBar.Text = NewFontString(castBar, "SystemFont_Shadow_Small", 8)
	castBar:Hide()
	frame.castBar = castBar

	local mark = CreateFrame("Frame", nil, frame)
	mark.RaidTargetIcon = mark:CreateTexture(nil, "OVERLAY")
	mark.RaidTargetIcon:SetAllPoints(mark)
	frame.RaidTargetFrame = mark

	local classification = CreateFrame("Frame", nil, frame)
	classification:SetSize(18, 18)
	classification.classificationIndicator = classification:CreateTexture(nil, "OVERLAY")
	classification.classificationIndicator:SetAllPoints(classification)
	SetEliteTexture(classification.classificationIndicator)
	frame.ClassificationFrame = classification

	return frame
end

local function NewData(scenario)
	local isAlly = scenario.side == "allies"
	return {
		fake = scenario,
		unit = "preview",
		side = isAlly and "allies" or "enemy",
		isAlly = isAlly,
		isPlayer = scenario.isPlayer and true or false,
		class = scenario.class,
		reaction = isAlly and 5 or (scenario.color == NEUTRAL and 4 or 2),
		canAttack = not isAlly,
		isTarget = scenario.isTarget and true or false,
	}
end

-- What the game itself does on a real nameplate, then the modules
local function ApplyExample(example)
	local scenario, frame, data = example.scenario, example.frame, example.data
	local db = ns.db
	local isAlly = data.side == "allies"
	local nameOnly = isAlly and db.allies.nameOnly

	example.label:SetText(L[scenario.label])
	example.desc:SetText(scenario.desc and L[scenario.desc] or "")
	frame:SetSize(ns.GetPlateWidth(), PLATE_HEIGHT)
	frame:SetScale(data.isTarget and db.general.targetScale / 100 or 1)
	frame.IsShowOnlyName = function() return nameOnly end

	frame.name:SetText(scenario.name)
	local classR, classG, classB = ns.GetClassColor(scenario.class)
	if isAlly and classR then
		frame.name:SetVertexColor(classR, classG, classB)
	else
		frame.name:SetVertexColor(1, 1, 1)
	end

	local bar = frame.healthBar
	bar:SetShown(not nameOnly)
	bar:SetValue(scenario.health or 100)

	local castBar = frame.castBar
	if scenario.cast then
		castBar.casting = true
		castBar.Text:SetText(scenario.cast)
		castBar.Icon:SetTexture(scenario.castIcon)
		castBar:SetValue(0.6)
		castBar:Show()
	else
		castBar.casting = nil
		castBar:Hide()
	end

	if scenario.raidMark then
		SetRaidMarkTexture(frame.RaidTargetFrame.RaidTargetIcon, scenario.raidMark)
		frame.RaidTargetFrame:SetSize(20, 20)
		frame.RaidTargetFrame:Show()
		if nameOnly then
			-- The game shows the raid mark of name-only nameplates right over the name (allies: the addon
			-- keeps it there with a health bar too, Modules\Allies.lua)
			frame.RaidTargetFrame:ClearAllPoints()
			frame.RaidTargetFrame:SetPoint("BOTTOM", frame.name, "TOP", 0, 2)
		end
	else
		frame.RaidTargetFrame:Hide()
	end
	frame.ClassificationFrame:SetShown(scenario.elite and true or false)

	-- The fonts the game really uses on its nameplates (seen on the real ones), so the examples show the
	-- real sizes; until a real nameplate was seen, the game's nameplate font objects
	data.nameFont = (ns.gameNameFonts and ns.gameNameFonts[data.side]) or data.nameFont
	data.castFont = ns.gameCastFont or data.castFont

	ns.CallModules("Update", frame, data)

	-- The color of the bar last, after the modules set its texture (the game paints it after them too)
	local r, g, b = ns.Unpack(scenario.color or HOSTILE)
	if scenario.isPlayer and classR and (isAlly or db.enemy.classColor) then
		r, g, b = classR, classG, classB
	end
	bar:SetStatusBarColor(r, g, b)
end

-- Window ---------------------------------------------------------------------------------------------

-- A narrow window: the examples are in a list that scrolls, with the mouse wheel or the bar at the right
local scrollBar, maxScroll = nil, 0

local function CreateScrollArea()
	local scroll = CreateFrame("ScrollFrame", nil, window)
	scroll:SetPoint("TOPLEFT", window, "TOPLEFT", PADDING, -TOP)
	scroll:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -PADDING - SCROLLBAR_WIDTH, PADDING)
	local content = CreateFrame("Frame", nil, scroll)
	content:SetSize(COLUMNS * CELL_WIDTH, MIN_CARD_HEIGHT)
	scroll:SetScrollChild(content)

	local bar = CreateFrame("Slider", nil, window, "BackdropTemplate")
	scrollBar = bar
	bar:SetOrientation("VERTICAL")
	bar:SetWidth(SCROLLBAR_WIDTH - 4)
	bar:SetPoint("TOPRIGHT", window, "TOPRIGHT", -PADDING + 2, -TOP)
	bar:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -PADDING + 2, PADDING)
	bar:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"})
	bar:SetBackdropColor(0, 0, 0, 0.4)
	bar:SetThumbTexture("Interface\\Buttons\\WHITE8X8")
	local thumb = bar:GetThumbTexture()
	thumb:SetVertexColor(0.8, 0.8, 0.8, 0.6)
	thumb:SetSize(SCROLLBAR_WIDTH - 4, 40)
	bar:SetMinMaxValues(0, 0)
	bar:SetValueStep(1)
	bar:SetValue(0)
	bar:SetScript("OnValueChanged", function(_, value)
		scroll:SetVerticalScroll(value)
	end)

	scroll:EnableMouseWheel(true)
	scroll:SetScript("OnMouseWheel", function(_, delta)
		bar:SetValue(math.min(maxScroll, math.max(0, bar:GetValue() - delta * SCROLL_STEP)))
	end)
	return content
end

local function CreateWindow()
	window = CreateFrame("Frame", "KyoryokunaPlatesPreviewWindow", UIParent, "BackdropTemplate")
	window:SetSize(COLUMNS * CELL_WIDTH + PADDING * 2 + SCROLLBAR_WIDTH, VISIBLE_HEIGHT + TOP + PADDING)
	window:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
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
	window:SetBackdropColor(0.12, 0.16, 0.16, 0.97)
	window:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
	tinsert(UISpecialFrames, "KyoryokunaPlatesPreviewWindow")

	window.title = window:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	window.title:SetPoint("TOPLEFT", window, "TOPLEFT", 18, -16)
	window.hint = window:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
	-- Under the title, so a long title (with the page's name) never pushes it under the close button
	window.hint:SetPoint("TOPLEFT", window.title, "BOTTOMLEFT", 0, -3)

	local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", window, "TOPRIGHT", -4, -4)

	local content = CreateScrollArea()
	window.content = content
	for _, scenario in ipairs(SCENARIOS) do
		-- A card: a dark panel with a thin frame, the title in gold, a short description under it and the
		-- example nameplate right below
		local cell = CreateFrame("Frame", nil, content, "BackdropTemplate")
		cell:SetSize(CELL_WIDTH - CARD_GAP, MIN_CARD_HEIGHT)
		cell:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8X8",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 10, insets = {left = 2, right = 2, top = 2, bottom = 2},
		})
		cell:SetBackdropColor(0, 0, 0, 0.3)
		cell:SetBackdropBorderColor(0.45, 0.45, 0.45, 0.7)

		local label = cell:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		local path, _, flags = label:GetFont()
		if path then label:SetFont(path, TITLE_SIZE, flags) end
		label:SetPoint("TOP", cell, "TOP", 0, -9)
		local desc = cell:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
		desc:SetPoint("TOP", label, "BOTTOM", 0, -3)
		local line = cell:CreateTexture(nil, "ARTWORK")
		line:SetColorTexture(1, 0.82, 0, 0.25)
		line:SetHeight(1)
		line:SetPoint("TOPLEFT", cell, "TOPLEFT", 12, -TITLE_BAND + 4)
		line:SetPoint("TOPRIGHT", cell, "TOPRIGHT", -12, -TITLE_BAND + 4)

		local frame = BuildPlate(cell)
		frame:SetPoint("BOTTOM", cell, "BOTTOM", 0, PLATE_BOTTOM)

		examples[#examples + 1] = {
			scenario = scenario, frame = frame, data = NewData(scenario), label = label, desc = desc, cell = cell,
		}
	end
	window:Hide()
end

-- How tall a card needs to be for its example with the current options: the nameplate's content (name,
-- bar, cast bar, debuffs above the name, a name-only ally's name and icons) under the title band.
-- The nameplates ignore the interface's scale and the target's is bigger, so their sizes are converted
-- to the window's units.
local function GetCardHeight(example)
	local db, scenario = ns.db, example.scenario
	local windowScale = ns.Known(window:GetEffectiveScale()) or 1
	local plateScale = scenario.isTarget and db.general.targetScale / 100 or 1
	local toCard = plateScale / windowScale
	local isAlly = scenario.side == "allies"
	local gameFont = ns.gameNameFonts and ns.gameNameFonts[isAlly and "allies" or "enemy"]
	local fontSize = (gameFont and gameFont.size or 9) * ns.NAME_BASE[isAlly and "allies" or "enemy"]
		* db[isAlly and "allies" or "enemy"].nameScale / 100
	-- The name ignores the nameplate's scale too
	local nameHeight = fontSize * 1.3 / windowScale

	-- A raid mark takes room above the name only when it's placed there (Raid Marks page)
	local markAbove = scenario.raidMark and (isAlly and db.raidMarks.allyPosition or db.raidMarks.enemyPosition) == "TOP"
	local markRoom = ((isAlly and db.raidMarks.allySize or db.raidMarks.enemySize) + 4) * toCard
	local top
	if isAlly and db.allies.nameOnly then
		top = db.allies.nameHeight * toCard + nameHeight
		if markAbove then top = top + markRoom end
		if scenario.role and db.allies.roleIcons and db.allies.roleIconPosition == "TOP" then
			top = top + (db.allies.roleIconSize + 2) * toCard
		end
	else
		local barTop = 3 + db.castBar.height + ns.GetCastGap() + db.enemy.barHeight
		top = (barTop + 4) * toCard + nameHeight
		if scenario.debuffs and db.enemy.debuffs then
			top = math.max(top, (barTop + db.enemy.debuffY + db.enemy.debuffSize) * toCard)
		end
		-- The raid mark over the name (or over the debuffs), and an ally's role icon when it's above the name
		if markAbove then top = top + markRoom end
		if isAlly and scenario.role and db.allies.roleIcons and db.allies.roleIconPosition == "TOP" then
			top = top + (db.allies.roleIconSize + 2) * toCard
		end
	end
	local height = PLATE_BOTTOM * toCard + top + CONTENT_GAP + TITLE_BAND
	return math.max(MIN_CARD_HEIGHT, math.ceil(height))
end

-- Only the examples of the current page, two by row, each row as tall as its tallest card. The list goes
-- back to its top when the page changes.
local function LayoutExamples(keepScroll)
	local content = window.content
	local shownList = {}
	for _, example in ipairs(examples) do
		if BelongsToPage(example.scenario) then
			shownList[#shownList + 1] = example
			example.cell:Show()
		else
			example.cell:Hide()
		end
	end
	local y = 0
	for first = 1, #shownList, COLUMNS do
		local rowHeight = MIN_CARD_HEIGHT
		for i = first, math.min(first + COLUMNS - 1, #shownList) do
			rowHeight = math.max(rowHeight, GetCardHeight(shownList[i]))
		end
		for i = first, math.min(first + COLUMNS - 1, #shownList) do
			local cell = shownList[i].cell
			cell:ClearAllPoints()
			cell:SetPoint("TOPLEFT", content, "TOPLEFT", (i - first) * CELL_WIDTH + CARD_GAP / 2, -y)
			cell:SetHeight(rowHeight)
		end
		y = y + rowHeight + CARD_GAP
	end
	local total = math.max(MIN_CARD_HEIGHT, y - CARD_GAP)
	content:SetHeight(total)
	maxScroll = math.max(0, total - VISIBLE_HEIGHT)
	scrollBar:SetMinMaxValues(0, maxScroll)
	if not keepScroll then scrollBar:SetValue(0) end
	scrollBar:SetValue(math.min(scrollBar:GetValue(), maxScroll))
	scrollBar:SetShown(maxScroll > 0)
	return #shownList
end

function Preview.Refresh()
	if not window or not window:IsShown() then return end
	local title = ns.TITLE .. " - " .. L["Test mode"]
	if currentPage then title = title .. ": " .. L[currentPage] end
	window.title:SetText(title)
	window.hint:SetText(L["The examples follow every change of the options."])
	-- The options change the sizes, so the cards are measured again (the list keeps its place)
	LayoutExamples(true)
	for _, example in ipairs(examples) do
		if example.cell:IsShown() then
			ns.SafeCall(ApplyExample, example)
		end
	end
end

-- The options window tells which page is open; General, Import / Export and About show every example
-- (after an import, or a backup put back, all of them may have changed)
local SHOWS_ALL = {General = true, ["Import / Export"] = true, About = true}

function Preview.SetPage(pageName)
	if SHOWS_ALL[pageName] then pageName = nil end
	if pageName == currentPage and window and window.laidOut then return end
	currentPage = pageName
	if not window then return end
	LayoutExamples()
	window.laidOut = true
	Preview.Refresh()
end

-- How many examples are shown (for tests)
function Preview.CountShown()
	local count = 0
	for _, example in ipairs(examples) do
		if example.cell:IsShown() then count = count + 1 end
	end
	return count
end

function Preview.Toggle()
	if not ns.db then return end
	if not window then CreateWindow() end
	if window:IsShown() then
		window:Hide()
	else
		window:Show()
		if not window.laidOut then
			LayoutExamples()
			window.laidOut = true
		end
		Preview.Refresh()
	end
end
