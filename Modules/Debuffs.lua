-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The player's own debuffs on an enemy, in a row above its name: square icons with a black border and
-- the seconds left in red in the middle. With "my crowd control first", the game's crowd control (stuns,
-- roots, polymorph...) gets a group of its own at the start of the row, whose icons can have a border
-- color of their own: the game hides from addons which aura an icon shows, so a group of their own is
-- the only way to tell them apart. The row starts at the left end of the health bar (default), or
-- ends at its right end (Enemies page). A centered row was tried (1.8.0) and dropped: the game's row only
-- grows from one end, and in combat the game hides from addons how many debuffs there are (auras and
-- icons alike), so the addon can't center it itself.
--
-- The icons are kept by the game's own aura container (an "AuraContainer" frame): the game picks the
-- debuffs, follows their duration and updates the icons, including when those values are secret in
-- combat. This addon only says which debuffs (the player's, those meant for nameplates), the size and
-- the look. The game's own debuff icons are turned off meanwhile (Engine\CVars.lua).

local _, ns = ...

local Debuffs = ns.RegisterModule("Debuffs", {})

local GROUP = "mine"
-- With "my crowd control first": a group of their own, laid out before the others
local CC_GROUP = "mineCC"
local GAP = 4
-- The border of every icon: black, or for crowd control (when it has a color of its own) that color.
-- Two pixels, so it shows on the nameplate (which is scaled down).
local EDGE = 2
local COUNTDOWN_SIZE = 12
local COUNTDOWN_COLOR = {1, 0.1, 0.1}

-- Which of the player's debuffs: all of them, only crowd control ("cc"), or all but it ("notcc"). The
-- game marks crowd control itself (stuns, roots, fears, polymorph...); a "!" leaves a kind out.
local function GetFilter(kind)
	local util = AuraUtil
	local filters = util and util.AuraFilters or {}
	local parts = {filters.Harmful or "HARMFUL", filters.Player or "PLAYER"}
	if filters.IncludeNameplateOnly then parts[#parts + 1] = filters.IncludeNameplateOnly end
	local crowdControl = filters.CrowdControl or "CROWD_CONTROL"
	if kind == "cc" then
		parts[#parts + 1] = crowdControl
	elseif kind == "notcc" then
		parts[#parts + 1] = "!" .. crowdControl
	end
	if util and util.CreateFilterString then return util.CreateFilterString(unpack(parts)) end
	return table.concat(parts, "|")
end

-- The groups of the row, in their order
local function GetGroups()
	if ns.db.enemy.debuffCCFirst then
		return {
			{key = CC_GROUP, kind = "cc", cc = true, index = 1},
			{key = GROUP, kind = "notcc", index = 2},
		}
	end
	return {{key = GROUP, index = 1}}
end

local function GetSort()
	local method = AuraContainerSortMethod and AuraContainerSortMethod.Default
	local direction = AuraContainerSortDirection and AuraContainerSortDirection.Normal
	return method, direction
end

local function GetLayout(size, index)
	return {
		elementSpacing = GAP,
		lineSpacing = GAP,
		elementWidth = size,
		elementHeight = size,
		layoutIndex = index or 1,
	}
end

-- One icon, made once by the game when it needs it
local function StyleButton(button, size)
	button:SetSize(size, size)
	if button.kpIcon then
		button.kpIcon:ClearAllPoints()
		button.kpIcon:SetPoint("TOPLEFT", button, "TOPLEFT", EDGE, -EDGE)
		button.kpIcon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -EDGE, EDGE)
	end
end

-- The border around an icon: black, or for crowd control (with its color on) in that color
local function SetEdge(button, cc)
	local settings = ns.db.enemy
	local bordered = cc and settings.debuffCCFirst and settings.debuffCCBorder
	if button.kpEdge then
		if bordered then
			local r, g, b = ns.Unpack(settings.debuffCCBorderColor)
			button.kpEdge:SetColorTexture(r, g, b, 1)
		else
			button.kpEdge:SetColorTexture(0, 0, 0, 1)
		end
	end
end

local function InitButton(button, cc)
	local size = ns.db.enemy.debuffSize

	local edge = button:CreateTexture(nil, "BACKGROUND")
	edge:SetAllPoints(button)
	button.kpEdge = edge
	SetEdge(button, cc)

	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.kpIcon = icon
	if button.SetIcon then button:SetIcon(icon) end

	local timer = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	timer:SetAllPoints(icon)
	timer:SetReverse(true)
	if timer.SetDrawSwipe then timer:SetDrawSwipe(false) end
	if timer.SetDrawEdge then timer:SetDrawEdge(false) end
	if timer.SetDrawBling then timer:SetDrawBling(false) end
	if timer.SetHideCountdownNumbers then timer:SetHideCountdownNumbers(false) end
	if timer.SetMinimumCountdownDuration then timer:SetMinimumCountdownDuration(0) end
	timer.noCooldownCount = true
	local countdown = timer.GetCountdownFontString and timer:GetCountdownFontString()
	if countdown then
		countdown:SetFont(ns.FONT, COUNTDOWN_SIZE, "OUTLINE")
		countdown:SetTextColor(unpack(COUNTDOWN_COLOR))
		-- Always in the middle of the icon: cooldown text addons (e.g. OmniCC) may move the game's number
		-- to their own place, so it's put back whenever it's moved
		local centering = false
		local function Center()
			if centering then return end
			centering = true
			countdown:ClearAllPoints()
			countdown:SetPoint("CENTER", timer, "CENTER", 0, 0)
			if countdown.SetJustifyH then countdown:SetJustifyH("CENTER") end
			centering = false
		end
		Center()
		hooksecurefunc(countdown, "SetPoint", Center)
	end
	if button.SetDurationCooldown then button:SetDurationCooldown(timer) end
	button.kpTimer = timer

	local stacks = button:CreateFontString(nil, "OVERLAY")
	stacks:SetFont(ns.FONT, 10, "OUTLINE")
	stacks:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	if button.SetApplicationCount then button:SetApplicationCount(stacks) end

	if button.SetMouseMotionEnabled and not InCombatLockdown() then
		button:SetMouseMotionEnabled(false)
	end

	StyleButton(button, size)
end

local function CreateContainer(frame, data)
	if data.noDebuffContainer then return end
	local ok, container = pcall(CreateFrame, "AuraContainer", nil, ns.GetOverlay(frame, data), "CustomAuraContainerTemplate")
	if not ok or not container or not container.AddAuraGroup then
		-- This client can't do it: the game's own debuffs are turned back on instead
		data.noDebuffContainer = true
		if not ns.debuffsUnavailable then
			ns.debuffsUnavailable = true
			ns.ApplyGameSettings()
		end
		return
	end
	container:SetEnabled(false)
	if container.SetEditModePreviewEnabled then container:SetEditModePreviewEnabled(false) end
	if container.SetFlattensRenderLayers then container:SetFlattensRenderLayers(true) end
	local flow = AnchorUtil and AnchorUtil.FlowDirection
	container:SetFlowLayoutAnchorPoint("BOTTOMLEFT")
	if flow then
		container:SetFlowLayoutGrowthDirection(flow.Right, flow.Up)
	end

	local settings = ns.db.enemy
	local method, direction = GetSort()
	local groups = GetGroups()
	for _, group in ipairs(groups) do
		container:AddAuraGroup(group.key, GetFilter(group.kind), {
			maxFrameCount = settings.debuffMax,
			sortMethod = method,
			sortDirection = direction,
			initializeFrame = function(button)
				ns.SafeCall(InitButton, button, group.cc)
			end,
			layout = GetLayout(settings.debuffSize, group.index),
		})
	end
	data.debuffContainer = container
	data.debuffGroups = groups
	data.debuffSize = settings.debuffSize
	data.debuffMax = settings.debuffMax
	return container
end

-- The groups (and the look of their icons) a container is made with: when these options change, the
-- container is made again, as the game's groups can't be changed once made
local function GroupsKey()
	local settings = ns.db.enemy
	if not settings.debuffCCFirst then return "all" end
	local r, g, b = ns.Unpack(settings.debuffCCBorderColor)
	return string.format("cc:%s:%.3f:%.3f:%.3f", tostring(settings.debuffCCBorder), r, g, b)
end

-- A size or count changed in the options: the container and the icons it already made follow
local function ApplySettings(container, data)
	local settings = ns.db.enemy
	local groups = data.debuffGroups or GetGroups()
	if data.debuffSize ~= settings.debuffSize then
		data.debuffSize = settings.debuffSize
		for _, group in ipairs(groups) do
			if container.SetAuraGroupLayout then
				container:SetAuraGroupLayout(group.key, GetLayout(settings.debuffSize, group.index))
			end
			-- The icons it already made follow too, when the game lets the addon change them: they can be
			-- protected (changing them fails), and then the layout above sizes them
			if container.GetAuraGroupFrameCount and container.GetAuraGroupFrame then
				local ok, count = pcall(container.GetAuraGroupFrameCount, container, group.key)
				count = ok and ns.Known(count) or 0
				for i = 1, count do
					local styled = pcall(function()
						local button = container:GetAuraGroupFrame(group.key, i)
						if button and not (button.IsForbidden and button:IsForbidden()) then
							StyleButton(button, settings.debuffSize)
						end
					end)
					if not styled then break end
				end
			end
		end
	end
	if data.debuffMax ~= settings.debuffMax and container.SetAuraGroupMaxFrameCount then
		data.debuffMax = settings.debuffMax
		for _, group in ipairs(groups) do
			container:SetAuraGroupMaxFrameCount(group.key, settings.debuffMax)
		end
	end
end

-- Where the row goes over the bar: the corner of the row and the bar's point it's held to
local function RowPlace()
	if ns.db.enemy.debuffAlign == "RIGHT" then
		return "BOTTOMRIGHT", "TOPRIGHT"
	end
	return "BOTTOMLEFT", "TOPLEFT"
end

local function PlaceContainer(frame, data, container)
	local settings = ns.db.enemy
	local point, barPoint = RowPlace()
	-- The game's row grows from that corner: right, or left when it ends at the right end of the bar
	if data.debuffAlign ~= settings.debuffAlign then
		data.debuffAlign = settings.debuffAlign
		local flow = AnchorUtil and AnchorUtil.FlowDirection
		container:SetFlowLayoutAnchorPoint(point)
		if flow then
			container:SetFlowLayoutGrowthDirection(point == "BOTTOMRIGHT" and flow.Left or flow.Right, flow.Up)
		end
	end
	container:ClearAllPoints()
	container:SetPoint(point, frame.HealthBarsContainer, barPoint, 0, settings.debuffY)
end

local function HideContainer(data)
	local container = data.debuffContainer
	if container then
		container:SetEnabled(false)
		container:Hide()
	end
	data.debuffUnit = nil
end

-- The test mode has no real unit to read debuffs from: its examples get icons made the same way, with
-- a running countdown, so they look like the real ones
local EXAMPLE_ICONS = {
	"Interface\\Icons\\Spell_Frost_FrostBolt02",
	"Interface\\Icons\\Spell_Fire_FlameBolt",
	"Interface\\Icons\\Spell_Nature_Polymorph",
}
-- With "my crowd control first", the first example is crowd control
local EXAMPLE_CC_ICON = "Interface\\Icons\\Spell_Frost_FrostNova"

local function HideExamples(data)
	for _, button in ipairs(data.exampleIcons or {}) do
		button:Hide()
	end
end

local function ShowExamples(frame, data)
	local settings = ns.db.enemy
	local count = math.min(data.fake.debuffs or 0, settings.debuffMax)
	data.exampleIcons = data.exampleIcons or {}
	local icons = data.exampleIcons
	local bar = frame.HealthBarsContainer
	local point, barPoint = RowPlace()
	-- Ending at the right end of the bar, the first icon is the rightmost
	local step = (settings.debuffSize + GAP) * (point == "BOTTOMRIGHT" and -1 or 1)
	for i = 1, math.max(count, #icons) do
		local button = icons[i]
		if i <= count then
			if not button then
				button = CreateFrame("Frame", nil, ns.GetOverlay(frame, data))
				InitButton(button)
				icons[i] = button
			end
			local cc = settings.debuffCCFirst and i == 1
			SetEdge(button, cc)
			StyleButton(button, settings.debuffSize)
			button.kpIcon:SetTexture(cc and EXAMPLE_CC_ICON or EXAMPLE_ICONS[(i - 1) % #EXAMPLE_ICONS + 1])
			button:ClearAllPoints()
			button:SetPoint(point, bar, barPoint, (i - 1) * step, settings.debuffY)
			button.kpTimer:SetCooldown(GetTime() - i * 2, 12)
			button:Show()
		elseif button then
			button:Hide()
		end
	end
end

-- Whether this nameplate shows at least one of the player's debuffs right now (so what goes above the
-- name, like the raid mark, goes above them)
function ns.HasShownDebuffs(data)
	if not ns.db.enemy.debuffs then return false end
	if data.fake then
		for _, button in ipairs(data.exampleIcons or {}) do
			if button:IsShown() then return true end
		end
		return false
	end
	local container = data.debuffContainer
	if not container or not container:IsShown() or not container.GetAuraGroupFrameCount then return false end
	for _, group in ipairs(data.debuffGroups or GetGroups()) do
		local ok, count = pcall(container.GetAuraGroupFrameCount, container, group.key)
		count = ok and ns.Known(count) or 0
		-- The game's icons can be protected from addons (reading them fails): then the count decides
		for i = 1, count do
			local okButton, shown = pcall(function()
				local button = container:GetAuraGroupFrame(group.key, i)
				return button and button:IsShown()
			end)
			if not okButton then return true end
			if ns.Known(shown) then return true end
		end
	end
	return false
end

function Debuffs.Update(frame, data)
	local settings = ns.db.enemy
	if not settings.debuffs or data.side ~= "enemy" or not ns.HasHealthBar(frame) then
		HideContainer(data)
		HideExamples(data)
		return
	end
	if data.fake then
		ShowExamples(frame, data)
		return
	end
	-- "My crowd control first" or its border color changed: the old container goes, a new one is made
	local key = GroupsKey()
	if data.debuffContainer and data.debuffGroupsKey ~= key then
		HideContainer(data)
		data.debuffContainer, data.debuffGroups, data.debuffAlign = nil, nil, nil
	end
	local container = data.debuffContainer or CreateContainer(frame, data)
	if not container then return end
	data.debuffGroupsKey = key
	ApplySettings(container, data)
	if data.debuffUnit ~= data.unit then
		data.debuffUnit = data.unit
		container:SetUnit(data.unit)
	end
	container:SetEnabled(true)
	container:Show()
	PlaceContainer(frame, data, container)
end

-- The health bar can come and go (name-only nameplates); the debuffs follow it
Debuffs.Layout = Debuffs.Update

function Debuffs.Removed(_, data)
	HideContainer(data)
end
