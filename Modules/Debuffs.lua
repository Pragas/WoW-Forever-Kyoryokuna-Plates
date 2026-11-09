-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The player's own debuffs on an enemy, in a row above its name, starting at the left end of the health
-- bar: square icons with a thin black edge and the seconds left in red in the middle.
--
-- The icons are kept by the game's own aura container (an "AuraContainer" frame): the game picks the
-- debuffs, follows their duration and updates the icons, including when those values are secret in
-- combat. This addon only says which debuffs (the player's, those meant for nameplates), the size and
-- the look. The game's own debuff icons are turned off meanwhile (Engine\CVars.lua).

local _, ns = ...

local Debuffs = ns.RegisterModule("Debuffs", {})

local GROUP = "mine"
local GAP = 4
local EDGE = 1
local COUNTDOWN_SIZE = 12
local COUNTDOWN_COLOR = {1, 0.1, 0.1}

local function GetFilter()
	local util = AuraUtil
	local filters = util and util.AuraFilters
	if util and util.CreateFilterString and filters then
		return util.CreateFilterString(filters.Harmful, filters.Player, filters.IncludeNameplateOnly)
	end
	return "HARMFUL|PLAYER"
end

local function GetSort()
	local method = AuraContainerSortMethod and AuraContainerSortMethod.Default
	local direction = AuraContainerSortDirection and AuraContainerSortDirection.Normal
	return method, direction
end

local function GetLayout(size)
	return {
		elementSpacing = GAP,
		lineSpacing = GAP,
		elementWidth = size,
		elementHeight = size,
		layoutIndex = 1,
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

local function InitButton(button)
	local size = ns.db.enemy.debuffSize

	local edge = button:CreateTexture(nil, "BACKGROUND")
	edge:SetAllPoints(button)
	edge:SetColorTexture(0, 0, 0, 1)

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
	container:AddAuraGroup(GROUP, GetFilter(), {
		maxFrameCount = settings.debuffMax,
		sortMethod = method,
		sortDirection = direction,
		initializeFrame = function(button)
			ns.SafeCall(InitButton, button)
		end,
		layout = GetLayout(settings.debuffSize),
	})
	data.debuffContainer = container
	data.debuffSize = settings.debuffSize
	data.debuffMax = settings.debuffMax
	return container
end

-- A size or count changed in the options: the container and the icons it already made follow
local function ApplySettings(container, data)
	local settings = ns.db.enemy
	if data.debuffSize ~= settings.debuffSize then
		data.debuffSize = settings.debuffSize
		if container.SetAuraGroupLayout then
			container:SetAuraGroupLayout(GROUP, GetLayout(settings.debuffSize))
		end
		-- The icons it already made follow too, when the game lets the addon change them: they can be
		-- protected (changing them fails), and then the layout above sizes them
		if container.GetAuraGroupFrameCount and container.GetAuraGroupFrame then
			local ok, count = pcall(container.GetAuraGroupFrameCount, container, GROUP)
			count = ok and ns.Known(count) or 0
			for i = 1, count do
				local styled = pcall(function()
					local button = container:GetAuraGroupFrame(GROUP, i)
					if button and not (button.IsForbidden and button:IsForbidden()) then
						StyleButton(button, settings.debuffSize)
					end
				end)
				if not styled then break end
			end
		end
	end
	if data.debuffMax ~= settings.debuffMax and container.SetAuraGroupMaxFrameCount then
		data.debuffMax = settings.debuffMax
		container:SetAuraGroupMaxFrameCount(GROUP, settings.debuffMax)
	end
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
	for i = 1, math.max(count, #icons) do
		local button = icons[i]
		if i <= count then
			if not button then
				button = CreateFrame("Frame", nil, ns.GetOverlay(frame, data))
				InitButton(button)
				icons[i] = button
			end
			StyleButton(button, settings.debuffSize)
			button.kpIcon:SetTexture(EXAMPLE_ICONS[(i - 1) % #EXAMPLE_ICONS + 1])
			button:ClearAllPoints()
			button:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", (i - 1) * (settings.debuffSize + GAP), settings.debuffY)
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
	local ok, count = pcall(container.GetAuraGroupFrameCount, container, GROUP)
	count = ok and ns.Known(count)
	if not count or count == 0 then return false end
	-- The game's icons can be protected from addons (reading them fails): then the count decides
	for i = 1, count do
		local okButton, shown = pcall(function()
			local button = container:GetAuraGroupFrame(GROUP, i)
			return button and button:IsShown()
		end)
		if not okButton then return true end
		if ns.Known(shown) then return true end
	end
	return false
end

function Debuffs.Update(frame, data)
	local settings = ns.db.enemy
	local bar = frame.HealthBarsContainer
	if not settings.debuffs or data.side ~= "enemy" or not ns.HasHealthBar(frame) then
		HideContainer(data)
		HideExamples(data)
		return
	end
	if data.fake then
		ShowExamples(frame, data)
		return
	end
	local container = data.debuffContainer or CreateContainer(frame, data)
	if not container then return end
	ApplySettings(container, data)
	container:ClearAllPoints()
	container:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, settings.debuffY)
	if data.debuffUnit ~= data.unit then
		data.debuffUnit = data.unit
		container:SetUnit(data.unit)
	end
	container:SetEnabled(true)
	container:Show()
end

-- The health bar can come and go (name-only nameplates); the debuffs follow it
Debuffs.Layout = Debuffs.Update

function Debuffs.Removed(_, data)
	HideContainer(data)
end
