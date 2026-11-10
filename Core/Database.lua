-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The saved settings: their defaults, the limits of the numbers, and the checks done when they load.
-- A missing setting gets its default, a setting of the wrong kind goes back to it, and a number outside
-- its limits is brought back inside them. Settings are shared by every character of the account.

local addonName, ns = ...

local DB_VERSION = 11

-- The defaults are the author's own setup (1.11.0): a new install starts with it, and each player changes
-- what they like from there. Settings already saved are never changed by a new default.
ns.DEFAULTS = {
	general = {
		language = "enUS",
		manageGameSettings = true,
		stackNameplates = false,
		targetScale = 115,
		minimapIcon = true,
		minimapAngle = 225,
		reportErrors = true,
	},

	enemy = {
		barWidth = 150,
		barHeight = 20,
		-- The border around the health bar, in screen pixels (the target has its own, Target page)
		borderSize = 1,
		classColor = true,
		nameScale = 110,
		showHealthText = true,
		healthTextPosition = "INSIDE_RIGHT",
		healthTextScale = 110,
		showLevel = true,
		levelPosition = "INSIDE_LEFT",
		levelScale = 90,
		questIcon = true,
		-- Elites, rares and bosses: the game's dragon, the skull of the level, and a border fading from
		-- black to a color of their own
		eliteIcon = true,
		skullIcon = true,
		rankBorder = true,
		eliteColor = {1, 0.82, 0},
		rareColor = {0.78, 0.8, 0.86},
		bossColor = {1, 1, 1},
		threatGlow = true,
		threatFlash = true,
		debuffs = true,
		-- The row of icons over the bar: from its left end, or from its right end
		debuffAlign = "LEFT",
		-- My crowd control (stuns, roots...) first in the row, and its border in a color of its own
		debuffCCFirst = true,
		debuffCCBorder = true,
		debuffCCBorderColor = {0.2, 0.85, 0.35},
		-- The seconds left on each debuff
		debuffTimerColor = {1, 0.1, 0.1},
		debuffTimerSize = 12,
		debuffSize = 25,
		debuffMax = 6,
		debuffY = 20,
	},

	target = {
		arrow = true,
		-- Above the target, or beside its health bar: left, right or both sides
		arrowPosition = "TOP",
		arrowScale = 150,
		arrowX = 0,
		arrowY = 0,
		borderColor = {1, 1, 1},
		borderSize = 1,
		targetText = true,
	},

	castBar = {
		attached = true,
		width = 144,
		gap = 2,
		offsetX = 0,
		height = 15,
		showIcon = false,
		iconScale = 100,
		-- The spell icon at the left or right end of the bar; the spell name at its left, middle or right
		iconPosition = "LEFT",
		showText = true,
		textPosition = "CENTER",
		textScale = 110,
		-- Can be interrupted / my interrupt on cooldown / can't be interrupted
		-- Can be interrupted: the game's own default cast bar color (CASTBAR_CLASSIC_YELLOW)
		readyColor = {1, 0.7, 0},
		notReadyColor = {1, 0, 0.02},
		nonInterruptibleColor = {0.25, 0.28, 0.24},
		hideOnAllies = true,
	},

	allies = {
		nameOnly = true,
		clickThrough = true,
		nameScale = 120,
		nameHeight = 10,
		roleIcons = true,
		roleTank = true,
		roleHealer = true,
		roleDamager = false,
		roleIconSize = 16,
		roleIconPosition = "LEFT",
		manaBar = true,
		manaBarFollowName = true,
		manaBarWidth = 60,
		manaBarHeight = 4,
	},

	-- Where the raid mark sits: left or right of the health bar (or of the name when only the name
	-- shows), or above the name; and its size
	raidMarks = {
		enemyPosition = "RIGHT",
		enemySize = 35,
		allyPosition = "TOP",
		allySize = 35,
	},
}

-- {minimum, maximum} of each number, by section
ns.LIMITS = {
	general = {targetScale = {100, 200}, minimapAngle = {0, 360}},
	enemy = {
		barWidth = {60, 300}, barHeight = {4, 40}, borderSize = {1, 5}, nameScale = {50, 200}, healthTextScale = {50, 200}, levelScale = {50, 200},
		debuffSize = {12, 48}, debuffMax = {1, 12}, debuffTimerSize = {6, 24},
		debuffY = {0, 60},
	},
	target = {arrowScale = {50, 300}, arrowX = {-100, 100}, arrowY = {-100, 100}, borderSize = {1, 5}},
	castBar = {
		width = {30, 300}, gap = {0, 40}, offsetX = {-100, 100}, height = {6, 30}, iconScale = {50, 250}, textScale = {50, 200},
	},
	allies = {
		nameScale = {50, 200}, nameHeight = {0, 60}, roleIconSize = {8, 40}, manaBarWidth = {20, 150}, manaBarHeight = {2, 12},
	},
	raidMarks = {enemySize = {10, 60}, allySize = {10, 60}},
}

-- The values a choice can take; anything else goes back to the default
-- Where a text sits: inside the bar (left, center, right) or outside it (left, right)
local TEXT_POSITIONS = {
	INSIDE_LEFT = true, INSIDE_CENTER = true, INSIDE_RIGHT = true, OUTSIDE_LEFT = true, OUTSIDE_RIGHT = true,
}

ns.CHOICES = {
	general = {language = {enUS = true, ptPT = true}},
	enemy = {
		healthTextPosition = TEXT_POSITIONS, levelPosition = TEXT_POSITIONS,
		debuffAlign = {LEFT = true, RIGHT = true},
	},
	target = {arrowPosition = {TOP = true, LEFT = true, RIGHT = true, BOTH = true}},
	castBar = {iconPosition = {LEFT = true, RIGHT = true}, textPosition = {LEFT = true, CENTER = true, RIGHT = true}},
	allies = {roleIconPosition = {LEFT = true, RIGHT = true, TOP = true}},
	raidMarks = {enemyPosition = {LEFT = true, RIGHT = true, TOP = true}, allyPosition = {LEFT = true, RIGHT = true, TOP = true}},
}

local function CopyValue(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for k, v in pairs(value) do copy[k] = CopyValue(v) end
	return copy
end
ns.CopyValue = CopyValue

local function IsValidColor(value)
	return type(value) == "table" and type(value[1]) == "number" and type(value[2]) == "number" and type(value[3]) == "number"
end

local function ValidateSection(name, saved, defaults)
	local limits = ns.LIMITS[name] or {}
	local choices = ns.CHOICES[name] or {}
	for key, default in pairs(defaults) do
		local value = saved[key]
		if type(value) ~= type(default) then
			saved[key] = CopyValue(default)
		elseif type(default) == "table" then
			if not IsValidColor(value) then saved[key] = CopyValue(default) end
		elseif type(default) == "number" and limits[key] then
			saved[key] = math.min(limits[key][2], math.max(limits[key][1], value))
		elseif type(default) == "string" and choices[key] and not choices[key][value] then
			saved[key] = default
		end
	end
	-- Settings that no longer exist are removed
	for key in pairs(saved) do
		if defaults[key] == nil then saved[key] = nil end
	end
end

-- A size of 100% that became what an older percentage was: the saved number changes, the look doesn't
local function RescaleName(section, oldPercentForNew100)
	local converted = math.floor(section.nameScale * 100 / oldPercentForNew100 / 5 + 0.5) * 5
	return converted
end

-- What changed between versions, for settings saved by an older one
local function Migrate(db, savedVersion)
	-- Version 3: the cast bar got the height of the health bar. The heights saved by older versions were
	-- never chosen (they were defaults), so they move to the new one.
	if savedVersion < 3 then
		db.castBar.height = ns.DEFAULTS.castBar.height
	end
	-- Version 5: for allies, 100% became what 80% was
	if savedVersion < 5 then
		db.allies.nameScale = RescaleName(db.allies, 80)
	end
	-- Version 6: the spell name of the cast bar matches the reference (110%, before 120%)
	if savedVersion < 6 and db.castBar.textScale == 120 then
		db.castBar.textScale = ns.DEFAULTS.castBar.textScale
	end
	-- Version 7: the arrow's size measured against the reference: 150% matches it
	if savedVersion < 7 then
		db.target.arrowScale = ns.DEFAULTS.target.arrowScale
	end
	-- Version 8: for enemies too, 100% became what 80% was
	if savedVersion < 8 then
		db.enemy.nameScale = RescaleName(db.enemy, 80)
	end
	-- Version 10: the spell icon fits inside the cast bar and its size became a part of the bar's height
	-- (100% = as tall as the bar); the old sizes meant something else, so they start again from there
	if savedVersion < 10 then
		db.castBar.iconScale = ns.DEFAULTS.castBar.iconScale
	end
	-- Version 11: the crowd control border's default went from gold to green; a gold one was never chosen
	if savedVersion < 11 then
		local color = db.enemy.debuffCCBorderColor
		if math.abs(color[1] - 1) < 0.001 and math.abs(color[2] - 0.82) < 0.001 and math.abs(color[3]) < 0.001 then
			db.enemy.debuffCCBorderColor = CopyValue(ns.DEFAULTS.enemy.debuffCCBorderColor)
		end
	end
	-- Rescaled sizes stay inside their limits
	for _, name in ipairs({"enemy", "allies"}) do
		local limits = ns.LIMITS[name].nameScale
		db[name].nameScale = math.min(limits[2], math.max(limits[1], db[name].nameScale))
	end
end

local function Validate(db)
	local savedVersion = tonumber(db.version) or 0
	-- Version 9: the nameplate width (General) became the bar width (Enemies), 16 less. Read before the
	-- old setting is removed below.
	local oldPlateWidth = type(db.general) == "table" and tonumber(db.general.width)
	-- Sections of older versions are removed
	for name in pairs(db) do
		if type(db[name]) == "table" and not ns.DEFAULTS[name] and name ~= "errors" and name ~= "gameBackup"
			and name ~= "backups" then
			db[name] = nil
		end
	end
	for name, defaults in pairs(ns.DEFAULTS) do
		if type(db[name]) ~= "table" then db[name] = {} end
		ValidateSection(name, db[name], defaults)
	end
	if type(db.errors) ~= "table" then db.errors = {} end
	if type(db.gameBackup) ~= "table" then db.gameBackup = {} end
	-- Backups of the settings (Core\Backups.lua): only whole ones are kept
	if type(db.backups) ~= "table" then db.backups = {} end
	for i = #db.backups, 1, -1 do
		local backup = db.backups[i]
		if type(backup) ~= "table" or type(backup.settings) ~= "table" then table.remove(db.backups, i) end
	end
	-- Settings saved by an older version are brought up to date; new settings already have today's defaults
	if savedVersion > 0 then
		Migrate(db, savedVersion)
		if savedVersion < 9 and oldPlateWidth then
			local limits = ns.LIMITS.enemy.barWidth
			db.enemy.barWidth = math.min(limits[2], math.max(limits[1], oldPlateWidth - 16))
		end
	end
	db.version = DB_VERSION
end

-- Every setting checked again (after an import or a restore put many in place at once)
function ns.ValidateSettings()
	for name, defaults in pairs(ns.DEFAULTS) do
		if type(ns.db[name]) ~= "table" then ns.db[name] = {} end
		ValidateSection(name, ns.db[name], defaults)
	end
end

-- Reading and writing by path, e.g. "enemy.classColor" ----------------------------------------------

local function Split(path)
	return path:match("^([^.]+)%.(.+)$")
end

function ns.Get(path)
	local section, key = Split(path)
	return ns.db[section][key]
end

function ns.GetLimits(path)
	local section, key = Split(path)
	local limits = ns.LIMITS[section] and ns.LIMITS[section][key]
	if limits then return limits[1], limits[2] end
end

-- Every change refreshes the nameplates (and the game settings, when they depend on it)
function ns.Set(path, value)
	local section, key = Split(path)
	local default = ns.DEFAULTS[section][key]
	if type(value) == "number" and ns.LIMITS[section] and ns.LIMITS[section][key] then
		local limits = ns.LIMITS[section][key]
		value = math.min(limits[2], math.max(limits[1], value))
	end
	if type(value) ~= type(default) then return end
	ns.db[section][key] = CopyValue(value)
	if ns.OnSettingChanged then
		ns.OnSettingChanged(path)
	end
end

-- Loading ------------------------------------------------------------------------------------------

ns.RegisterEvent("ADDON_LOADED", function(_, loadedName)
	if loadedName ~= addonName then return end
	if type(KyoryokunaPlatesDB) ~= "table" then
		KyoryokunaPlatesDB = {}
	end
	-- Nothing saved yet: the addon's first use. The welcome window then says what the addon is, until
	-- its OK is clicked (Core\ReleaseNotes.lua)
	if KyoryokunaPlatesDB.version == nil then KyoryokunaPlatesDB.firstWelcome = true end
	-- The game settings saved by the first version keep their place
	if type(KyoryokunaPlatesDB.cvarBackup) == "table" and type(KyoryokunaPlatesDB.gameBackup) ~= "table" then
		KyoryokunaPlatesDB.gameBackup = {cvars = KyoryokunaPlatesDB.cvarBackup}
	end
	KyoryokunaPlatesDB.cvarBackup = nil
	Validate(KyoryokunaPlatesDB)
	ns.db = KyoryokunaPlatesDB
	ns.language = ns.db.general.language
	ns.FlushSessionErrors()
	if ns.OnDatabaseReady then
		ns.OnDatabaseReady()
	end
end)
