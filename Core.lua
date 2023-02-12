-- 
-- Masque Blizzard Inventory
-- Enables Masque to skin the built-in inventory UI
--
-- Copyright 2022 SimGuy
--
-- Use of this source code is governed by an MIT-style
-- license that can be found in the LICENSE file or at
-- https://opensource.org/licenses/MIT.
--

local Masque = LibStub("Masque")
local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

local AddonName, Shared = ...
local L = Shared.Locale

-- From Locales/Locales.lua
local L = Shared.Locale

-- From Metadata.lua
local Metadata = Shared.Metadata
local Groups = Metadata.Groups
local Types = Metadata.Types

-- Push us into shared object
local Core = {}
Shared.Core = Core

local _, _, _, ver = GetBuildInfo()

-- Get an option for the AceConfigDialog
function Core:GetOption(key)
	if not key then
		if self and self[#self] then
			key = self[#self]
		else
			return nil
		end
	end

	local value = false;
	local settings = _G[AddonName]

	if settings and settings[key] ~= nil then
		value = settings[key]
	elseif Metadata.Defaults and Metadata.Defaults[key] ~= nil then
		value = Metadata.Defaults[key]
	end

	--print("GetOption", key, value)
	return value
end

-- Set an option from the AceConfigDialog
function Core:SetOption(...)
	local key = self[#self]
	if not key then	return nil end

	local value = ...
	local settings = _G[AddonName]

	--print("SetOption", key, value)
	if settings and settings[key] ~= value then
		settings[key] = value
	end
	if Metadata.OptionCallbacks and Metadata.OptionCallbacks[key] then
		--print("OptionCallback", key)
		local func = Metadata.OptionCallbacks[key]
		func(key, value)
	end
end

-- Handle the load event to initialize things that require Saved Variables
function Core:HandleEvent(event, target)
	if event == "ADDON_LOADED" and target == AddonName then
		if not  _G[AddonName] then
			_G[AddonName] = {}
		end
		-- Don't register options unless they're defined.
		if Metadata.Options then
			Metadata.Options.get = Core.GetOption
			Metadata.Options.set = Core.SetOption
			ACR:RegisterOptionsTable(AddonName, Metadata.Options)
			ACD:AddToBlizOptions(AddonName, Metadata.FriendlyName)
		end
	end
end

-- Return a regions table based on the information passed for this button
function Core:MakeRegions(button, map)
	-- If map is empty, then do nothing
	if not map then return nil end

	local regions = {}
	for region, key in pairs(map) do
		frame = button[key]
		if frame then
			-- If this is a function, call it now to get
			-- the object for the Masque region, otherwise
			-- assume the object is literal.
			if type(frame) == "function" then
				--print("regions function:", region, key, frame)
				regions[region] = frame(button)
			else
				--print("regions frame:", region, key, frame)
				regions[region] = frame
			end
		end
	end
	return regions
end

-- Skin any buttons in the table as members of the given Masque group.
-- If parent is set, then the button names are children of the parent
-- table. The buttons value can be a nested table.
function Core:Skin(buttons, group, parent)
	if not parent then parent = _G end
	for button, children in pairs(buttons) do
		if (type(children) == "table") then
			if parent[button] then
				--print('recurse:', button, parent[button])
				Core:Skin(children, group, parent[button])
			end
		else
			-- Pass the correct type for this button so that Masque
			-- doesn't have to try to figure it out.
			local btype = Types[button] or {}
			local dtype = Types['DEFAULT'] or {}
			local type = btype.type or dtype.type or nil
			local map = btype.map or nil

			-- If -1, assume button is the actual button name
			if children == -1 then
				--print("button:", button, children, parent[button])
				local frame = parent[button]
				local regions = Core:MakeRegions(frame, map)
				group:AddButton(frame, regions, type)

			-- Otherwise, append the range of numbers to the name
			elseif children > 0 then
				for i = 1, children do
					--print("button:", button, children, parent[button..i])
					local frame = parent[button..i]
					local regions = Core:MakeRegions(frame, map)
					group:AddButton(frame, regions, type)
				end
			end
		end
	end
end

-- Check if the current interface version is between the low number (inclusive)
-- and the high number (exclusive) for implementations that are dependent upon
-- client version.
function Core:CheckVersion(versions)
	if not versions or
	   (versions and
	    (not versions[1] or ver >= versions[1]) and
	    (not versions[2] or ver <  versions[2])
	   ) then
		return true
	else
		return false
	end
end

function Core:Init()
	-- Init Custom Options
	Core.Events = CreateFrame("Frame")
	Core.Events:RegisterEvent("ADDON_LOADED")
	Core.Events:SetScript("OnEvent", Core.HandleEvent)

	-- Create groups for each defined button group and add any buttons
	-- that should exist at this point
	for id, cont in pairs(Metadata.Groups) do
		if Core:CheckVersion(cont.Versions) then
			cont.Group = Masque:Group(Metadata.MasqueFriendlyName, cont.Title, id)
			-- Reset l10n group names after ensuring migration to Static IDs
			cont.Group:SetName(L[cont.Title])
			if cont.Init then
				cont.Init(cont.Buttons)
			end
			if cont.Notes then
				cont.Group.Notes = cont.Notes
			end
			if not cont.Delayed then
				Core:Skin(cont.Buttons, cont.Group)
			end
		end
	end
end
