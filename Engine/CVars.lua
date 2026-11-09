-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Part of the look comes from the game's own nameplate settings (CVars): which nameplates show, the
-- class colors of players, name-only allies, the size of the target and the width. The game keeps them
-- even after this addon is turned off, so the value each one had before is saved the first time it's
-- changed, and "manage the game's nameplate settings" off puts them all back. They can't be changed in
-- combat, so a change waits until the combat ends.
--
-- The game's own aura icons on nameplates (buffs, debuffs, crowd control) are turned off while this
-- addon shows its debuffs (Modules\Debuffs.lua), so nothing shows twice or beside the bar. The game's
-- threat glow and aggro flash on enemies are turned on (Enemies page).

local _, ns = ...

local function Bool(value)
	return value and "1" or "0"
end

local CVARS = {
	-- Overlapping nameplates (not pushed apart) and the size of the target
	nameplateMotion = function() return "0" end,
	nameplateSelectedScale = function(db) return tostring(db.general.targetScale / 100) end,
	-- The game shrinks the nameplates with the distance, down to 80%: they keep their full size instead
	nameplateMinScale = function() return "1" end,
	nameplateMaxScale = function() return "1" end,

	-- Enemies: pets, guardians and minions hidden; totems shown; players in their class color
	nameplateShowEnemyPets = function() return "0" end,
	nameplateShowEnemyGuardians = function() return "0" end,
	nameplateShowEnemyMinions = function() return "0" end,
	nameplateShowEnemyTotems = function() return "1" end,
	nameplateShowClassColor = function(db) return Bool(db.enemy.classColor) end,

	-- Allies: players only, name only, in their class color
	nameplateShowFriendlyNPCs = function() return "0" end,
	nameplateShowFriendlyPets = function() return "0" end,
	nameplateShowFriendlyGuardians = function() return "0" end,
	nameplateShowFriendlyMinions = function() return "0" end,
	nameplateShowFriendlyTotems = function() return "0" end,
	nameplateShowFriendlyClassColor = function() return "1" end,
	nameplateShowOnlyNameForFriendlyPlayerUnits = function(db) return Bool(db.allies.nameOnly) end,
	nameplateUseClassColorForFriendlyPlayerUnitNames = function() return "1" end,
}

local function SameValue(a, b)
	if a == b then return true end
	local na, nb = tonumber(a), tonumber(b)
	return na ~= nil and nb ~= nil and math.abs(na - nb) < 0.001
end

local function GetCVarValue(name)
	if C_CVar and C_CVar.GetCVar then return C_CVar.GetCVar(name) end
	return GetCVar and GetCVar(name)
end

local function SetCVarValue(name, value)
	if C_CVar and C_CVar.SetCVar then
		C_CVar.SetCVar(name, value)
	elseif SetCVar then
		SetCVar(name, value)
	end
end

local function GetBackup()
	local backup = ns.db.gameBackup
	backup.cvars = backup.cvars or {}
	backup.bits = backup.bits or {}
	return backup
end

local function ApplyCVars()
	local db = ns.db
	if not db.general.manageGameSettings then return end
	local backup = GetBackup()
	for name, getValue in pairs(CVARS) do
		local current = GetCVarValue(name)
		-- A CVar this client doesn't have is skipped
		if current ~= nil then
			local wanted = getValue(db)
			if not SameValue(current, wanted) then
				if backup.cvars[name] == nil then
					backup.cvars[name] = current
				end
				SetCVarValue(name, wanted)
			end
		end
	end
end

-- The game's debuff icons on enemy nameplates -----------------------------------------------------

-- The game's own aura lists on nameplates: buffs, debuffs, and crowd control / loss of control (shown
-- right of the bar). All of them are turned off while this addon shows its debuffs, as the reference
-- look has only those, above the name.
local AURA_LISTS = {
	{"ENEMY_NPC_AURA_DISPLAY_CVAR", "NamePlateEnemyNpcAuraDisplay", {"Buffs", "Debuffs", "CrowdControl"}},
	{"ENEMY_PLAYER_AURA_DISPLAY_CVAR", "NamePlateEnemyPlayerAuraDisplay", {"Buffs", "Debuffs", "LossOfControl"}},
	{"FRIENDLY_PLAYER_AURA_DISPLAY_CVAR", "NamePlateFriendlyPlayerAuraDisplay", {"Buffs", "Debuffs", "LossOfControl"}},
}

local function GetDebuffBits()
	local constants, enum = NamePlateConstants, Enum
	if not (constants and enum and C_CVar and C_CVar.GetCVarBitfield and C_CVar.SetCVarBitfield) then return {} end
	local bits = {}
	for _, list in ipairs(AURA_LISTS) do
		local cvarName, kinds = constants[list[1]], enum[list[2]]
		if cvarName and kinds then
			for _, kind in ipairs(list[3]) do
				if kinds[kind] then
					bits[#bits + 1] = {cvarName, kinds[kind]}
				end
			end
		end
	end
	return bits
end

-- Sets one switch of a game setting made of switches (a "bitfield"), keeping the value it had before
local function SetBit(backup, name, index, wanted)
	if not (name and index) then return end
	local key = name .. ":" .. index
	local current = C_CVar.GetCVarBitfield(name, index)
	if current ~= wanted then
		if backup.bits[key] == nil then
			backup.bits[key] = current and true or false
		end
		C_CVar.SetCVarBitfield(name, index, wanted)
	end
end

local function ApplyDebuffBits()
	local db = ns.db
	if not db.general.manageGameSettings then return end
	local backup = GetBackup()
	-- With this addon's debuffs on, the game's are off; with them off, the game's come back
	local wanted = not db.enemy.debuffs or ns.debuffsUnavailable == true
	for _, bit in ipairs(GetDebuffBits()) do
		SetBit(backup, bit[1], bit[2], wanted)
	end
end

-- The game's threat display on enemy nameplates -----------------------------------------------------

-- The game shows threat on enemies with switches of its own: an orange glow rising above the health bar
-- ("Progressive": the mob is on you, or you're about to pull it) and a short flash on the bar when you
-- gain or lose aggro. Both are off unless something turns them on, so the addon does (Enemies page).
local function ApplyThreatBits()
	local db = ns.db
	if not db.general.manageGameSettings then return end
	local kinds = Enum and Enum.NamePlateThreatDisplay
	if not (kinds and C_CVar and C_CVar.GetCVarBitfield and C_CVar.SetCVarBitfield) then return end
	local name = (NamePlateConstants and NamePlateConstants.THREAT_DISPLAY_CVAR) or "nameplateThreatDisplay"
	local backup = GetBackup()
	SetBit(backup, name, kinds.Progressive, db.enemy.threatGlow and true or false)
	SetBit(backup, name, kinds.Flash, db.enemy.threatFlash and true or false)
end

-- Every switch changed by the addon goes back to the value it had before
local function RestoreBits(backup)
	for key, saved in pairs(backup.bits) do
		local name, index = key:match("^(.+):(%d+)$")
		if name and index then
			C_CVar.SetCVarBitfield(name, tonumber(index), saved)
		end
	end
end

-- Width of the nameplates ----------------------------------------------------------------------------

-- The height of the nameplates: the room for the name, the health bar and the cast bar, and the area
-- that can be clicked
local PLATE_HEIGHT = 55
-- The nameplate is as wide as the health bar plus this much (8 on each side)
local PLATE_SIDES = 16

function ns.GetPlateWidth()
	return ns.db.enemy.barWidth + PLATE_SIDES
end

-- The game's own size is remembered, so it can be put back
local gameWidth, gameHeight, appliedWidth, appliedHeight

function ns.ApplyNameplateSize()
	if not ns.db or not (C_NamePlate and C_NamePlate.SetNamePlateSize and C_NamePlate.GetNamePlateSize) then return end
	ns.RunOutOfCombat("size", function()
		local width, height = C_NamePlate.GetNamePlateSize()
		width, height = ns.Known(width), ns.Known(height)
		if not width or not height then return end
		-- A size this addon didn't set is the game's own
		if not (appliedWidth and SameValue(width, appliedWidth) and SameValue(height, appliedHeight)) then
			gameWidth, gameHeight = width, height
		end
		local general = ns.db.general
		local wantedWidth = general.manageGameSettings and ns.GetPlateWidth() or gameWidth
		local wantedHeight = general.manageGameSettings and PLATE_HEIGHT or gameHeight
		if not SameValue(width, wantedWidth) or not SameValue(height, wantedHeight) then
			appliedWidth, appliedHeight = wantedWidth, wantedHeight
			C_NamePlate.SetNamePlateSize(wantedWidth, wantedHeight)
		end
	end)
end

local function RestoreNameplateSize()
	if not gameWidth or not (C_NamePlate and C_NamePlate.SetNamePlateSize) then return end
	appliedWidth, appliedHeight = nil, nil
	C_NamePlate.SetNamePlateSize(gameWidth, gameHeight)
end

-- All together ---------------------------------------------------------------------------------------

function ns.ApplyGameSettings()
	if not ns.db then return end
	ns.RunOutOfCombat("cvars", function()
		ApplyCVars()
		ApplyDebuffBits()
		ApplyThreatBits()
	end)
	ns.ApplyNameplateSize()
	if ns.Allies and ns.Allies.ApplyClickThrough then
		ns.Allies.ApplyClickThrough()
	end
end

function ns.RestoreGameSettings()
	ns.RunOutOfCombat("restore", function()
		local backup = GetBackup()
		for name, value in pairs(backup.cvars) do
			SetCVarValue(name, value)
		end
		RestoreBits(backup)
		wipe(backup.cvars)
		wipe(backup.bits)
		RestoreNameplateSize()
	end)
end
