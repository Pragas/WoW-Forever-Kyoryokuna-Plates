-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The engine. This addon doesn't build nameplates of its own: it takes the game's nameplates as they
-- appear and changes how they look. The game keeps doing the secure part (health values, positions,
-- clicks, its threat glow and health text), so nothing breaks when values are secret or in combat.
--
-- Each nameplate frame gets a table of data, kept here and never written into the game's frames, and
-- every module (Modules\*.lua) is called with that frame and its data:
--   Update(frame, data)         everything the module does, when the nameplate appears or a setting changes
--   Layout(frame, data)         what has to be done again after the game lays the nameplate out
--   TargetChanged(frame, data)  when the player's target changes
--   Removed(frame, data)        when the nameplate goes away

local _, ns = ...

local plates = setmetatable({}, {__mode = "k"})
local framesByUnit = {}
local modules = {}

function ns.RegisterModule(name, module)
	module.name = name
	modules[#modules + 1] = module
	ns[name] = module
	return module
end

-- The data of a nameplate that is shown and managed by this addon, nil otherwise
function ns.GetPlateData(frame)
	local data = plates[frame]
	if data and data.unit then return data end
end

function ns.GetFrameForUnit(unit)
	local frame = framesByUnit[unit]
	if frame then return frame, plates[frame] end
end

function ns.ForEachPlate(func)
	for frame, data in pairs(plates) do
		if data.unit then
			ns.SafeCall(func, frame, data)
		end
	end
end

function ns.CallModules(method, frame, data)
	for i = 1, #modules do
		local func = modules[i][method]
		if func then
			ns.SafeCall(func, frame, data)
		end
	end
end

-- A frame of this addon over the nameplate, for the arrow, texts and icons. It follows the nameplate,
-- so it's hidden and scaled with it.
function ns.GetOverlay(frame, data)
	if not data.overlay then
		local overlay = CreateFrame("Frame", nil, frame)
		overlay:SetAllPoints(frame)
		overlay:SetFrameLevel(frame:GetFrameLevel() + 20)
		data.overlay = overlay
	end
	return data.overlay
end

function ns.GetHealthBar(frame)
	return frame.healthBar or (frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar)
end

function ns.GetCastBar(frame)
	return frame.castBar or (frame.CastBarsContainer and frame.CastBarsContainer.castBar)
end

-- Whether the nameplate shows its health bar. Name-only nameplates (allies, and units that can't be
-- attacked) keep the bar's frame around the name, but nothing that belongs to the bar may be drawn there.
function ns.HasHealthBar(frame)
	-- A dead unit (e.g. a selected corpse) shows only its name: no bar, border, health, level or arrow
	local data = plates[frame]
	if data and data.unit and data.isDead then return false end
	if frame.IsShowOnlyName then
		local ok, nameOnly = pcall(frame.IsShowOnlyName, frame)
		if ok and ns.Known(nameOnly) then return false end
	end
	local container = frame.HealthBarsContainer
	if not container or container.alphaZero == true then return false end
	local bar = ns.GetHealthBar(frame)
	if not bar then return false end
	return ns.Known(bar:IsShown()) ~= false
end

-- What the addon needs to know about the unit. Secret answers count as unknown.
function ns.UpdateUnitInfo(data)
	local unit = data.unit
	local known = ns.Known

	data.isPlayer = known(UnitIsPlayer(unit)) and true or false
	data.reaction = known(UnitReaction(unit, "player"))

	local isFriend = known(UnitIsFriend("player", unit))
	if isFriend == nil then
		isFriend = data.reaction ~= nil and data.reaction >= 5
	end
	data.isAlly = isFriend and true or false
	data.side = data.isAlly and "allies" or "enemy"
	data.canAttack = known(UnitCanAttack("player", unit)) and true or false
	data.class = data.isPlayer and known(UnitClassBase(unit)) or nil
	data.isTarget = known(UnitIsUnit(unit, "target")) and true or false
	data.isDead = known(UnitIsDead(unit)) and true or false
end

local function GetUnitFrame(unit)
	if not (C_NamePlate and C_NamePlate.GetNamePlateForUnit) then return end
	local plate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
	local frame = plate and plate.UnitFrame
	-- Forbidden nameplates (allies inside dungeons and raids) can't be touched by addons
	if not frame or frame:IsForbidden() then return end
	return frame
end

local function OnPlateRemoved(unit)
	local frame = framesByUnit[unit]
	if not frame then return end
	framesByUnit[unit] = nil
	local data = plates[frame]
	if data then
		ns.CallModules("Removed", frame, data)
		data.unit = nil
	end
end

local function OnPlateAdded(unit)
	if not ns.db then return end
	-- The player's own nameplate (personal resource display) is left as it is
	if UnitIsUnit(unit, "player") then return end

	local frame = GetUnitFrame(unit)
	if not frame then return end

	if framesByUnit[unit] then
		OnPlateRemoved(unit)
	end

	local data = plates[frame]
	if not data then
		data = {}
		plates[frame] = data
	end
	data.unit = unit
	framesByUnit[unit] = frame

	if not data.hooked then
		data.hooked = true
		ns.HookFrame(frame)
	end

	ns.UpdateUnitInfo(data)
	ns.CallModules("Update", frame, data)
end

function ns.RefreshAll()
	ns.ForEachPlate(function(frame, data)
		ns.UpdateUnitInfo(data)
		ns.CallModules("Update", frame, data)
	end)
end

-- The nameplates already shown, e.g. after a /reload
local function ScanPlates()
	if not (C_NamePlate and C_NamePlate.GetNamePlates) then return end
	for _, plate in ipairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
		local frame = plate.UnitFrame
		local unit = plate.namePlateUnitToken or (frame and frame.unit)
		if unit then
			OnPlateAdded(unit)
		end
	end
end

-- Events -------------------------------------------------------------------------------------------

ns.RegisterEvent("NAME_PLATE_UNIT_ADDED", function(_, unit)
	OnPlateAdded(unit)
end)

ns.RegisterEvent("NAME_PLATE_UNIT_REMOVED", function(_, unit)
	OnPlateRemoved(unit)
end)

ns.RegisterEvent("PLAYER_TARGET_CHANGED", function()
	ns.ForEachPlate(function(frame, data)
		data.isTarget = ns.Known(UnitIsUnit(data.unit, "target")) and true or false
		ns.CallModules("TargetChanged", frame, data)
	end)
end)

local function OnUnitChanged(_, unit)
	local frame, data = ns.GetFrameForUnit(unit)
	if frame and data and data.unit then
		ns.UpdateUnitInfo(data)
		ns.CallModules("Update", frame, data)
	end
end
ns.RegisterEvent("UNIT_FACTION", OnUnitChanged)
ns.RegisterEvent("UNIT_FLAGS", OnUnitChanged)

-- When a unit dies (or comes back to life), its nameplate changes to name only (and back)
ns.RegisterEvent("UNIT_HEALTH", function(_, unit)
	local frame, data = ns.GetFrameForUnit(unit)
	if not (frame and data and data.unit) then return end
	local isDead = ns.Known(UnitIsDead(unit)) and true or false
	if isDead ~= data.isDead then
		data.isDead = isDead
		ns.CallModules("Update", frame, data)
	end
end)

ns.RegisterEvent("PLAYER_ENTERING_WORLD", function()
	if not ns.db then return end
	ns.ApplyGameSettings()
	ScanPlates()
end)

-- Settings -----------------------------------------------------------------------------------------

function ns.OnSettingChanged(path)
	-- Turning "manage game settings" off puts the game's own values back
	if path == "general.manageGameSettings" and not ns.db.general.manageGameSettings then
		ns.RestoreGameSettings()
		ns.Print(ns.L["The game's nameplate settings were put back."])
	end
	-- A new language: every text of the options is made again
	if path == "general.language" then
		ns.language = ns.db.general.language
		if ns.RebuildOptions then ns.RebuildOptions() end
	end
	ns.ApplyGameSettings()
	ns.RefreshAll()
	if ns.UpdateMinimapButton then
		ns.UpdateMinimapButton()
	end
	if ns.Preview then
		ns.Preview.Refresh()
	end
	if ns.RefreshOptions then
		ns.RefreshOptions()
	end
end

function ns.OnDatabaseReady()
	ns.ApplyGameSettings()
end
