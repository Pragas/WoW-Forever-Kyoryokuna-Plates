-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The game redraws its nameplates often: it sets the name again, lays everything out again when a
-- setting changes, and runs its cast bar on each cast event. Each of those is followed here
-- (hooksecurefunc and HookScript run after the game's own code and never change it), and this addon's
-- look is applied again right after.

local _, ns = ...

-- Hooks on each nameplate frame, done once per frame (the game reuses its frames for new units)
function ns.HookFrame(frame)
	if frame.UpdateAnchors then
		hooksecurefunc(frame, "UpdateAnchors", function(self)
			local data = ns.GetPlateData(self)
			if data then
				ns.CallModules("Layout", self, data)
			end
		end)
	end

	-- The game sets the size and place of the health bar again; this addon's are put back right after
	local container = frame.HealthBarsContainer
	if container then
		local function OnBarMoved()
			local data = ns.GetPlateData(frame)
			if data and not data.sizingBar and ns.HealthBar then
				ns.SafeCall(ns.HealthBar.ApplySize, frame, data)
			end
		end
		hooksecurefunc(container, "SetHeight", OnBarMoved)
		hooksecurefunc(container, "SetPoint", OnBarMoved)
	end

	-- The game shows or hides the health bar (name-only nameplates); everything tied to it follows
	local bar = ns.GetHealthBar(frame)
	if bar then
		local function OnBarShownChanged()
			local data = ns.GetPlateData(frame)
			if data then
				ns.CallModules("Layout", frame, data)
			end
		end
		hooksecurefunc(bar, "Show", OnBarShownChanged)
		hooksecurefunc(bar, "Hide", OnBarShownChanged)
		hooksecurefunc(bar, "SetShown", OnBarShownChanged)
	end

	local castBar = ns.GetCastBar(frame)
	if castBar then
		castBar:HookScript("OnEvent", function(_, event)
			local data = ns.GetPlateData(frame)
			if data and ns.CastBar then
				ns.SafeCall(ns.CastBar.OnCastEvent, frame, data, event)
			end
		end)
	end

	-- The game shows or hides its mark of an elite or a rare on its own (a new unit, a new
	-- classification, a raid mark set or gone): the icons left of the bar are placed again, so it's in
	-- their row and a raid mark on the left goes past it (Modules\LeftIcons.lua)
	local classification = frame.ClassificationFrame
	if type(classification) == "table" and classification.Show then
		local function OnClassificationShownChanged()
			local data = ns.GetPlateData(frame)
			if data and not data.placingIcons and ns.LeftIcons then
				ns.SafeCall(ns.LeftIcons.Update, frame, data)
			end
		end
		hooksecurefunc(classification, "Show", OnClassificationShownChanged)
		hooksecurefunc(classification, "Hide", OnClassificationShownChanged)
		hooksecurefunc(classification, "SetShown", OnClassificationShownChanged)
	end
end

local function GetNameplateData(frame)
	if ns.IsSecret(frame) or type(frame) ~= "table" then return end
	return ns.GetPlateData(frame)
end

if CompactUnitFrame_UpdateName then
	hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
		local data = GetNameplateData(frame)
		if data and ns.Name then
			ns.SafeCall(ns.Name.Update, frame, data)
		end
	end)
end

if CompactUnitFrame_UpdatePlayerLevelDiff then
	hooksecurefunc("CompactUnitFrame_UpdatePlayerLevelDiff", function(frame)
		local data = GetNameplateData(frame)
		if data and ns.Level then
			ns.SafeCall(ns.Level.Update, frame, data)
		end
	end)
end

-- When the game recalculates the size of the nameplates, the width is applied again
if NamePlateDriverFrame then
	local function Reapply()
		C_Timer.After(0, function()
			ns.SafeCall(ns.ApplyNameplateSize)
		end)
	end
	if NamePlateDriverFrame.UpdateNamePlateSize then
		hooksecurefunc(NamePlateDriverFrame, "UpdateNamePlateSize", Reapply)
	end
	if NamePlateDriverFrame.UpdateNamePlateOptions then
		hooksecurefunc(NamePlateDriverFrame, "UpdateNamePlateOptions", Reapply)
	end
end
