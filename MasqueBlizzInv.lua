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

local AddonName, Shared = ...

-- From Locales/Locales.lua
local L = Shared.Locale

-- From Metadata.lua
local Metadata = Shared.Metadata
local Groups = Metadata.Groups

-- From Core.lua
local Core = Shared.Core

-- Push us into shared object
local Addon = {}
Shared.Addon = Addon

-- Handle events for buttons that get created dynamically by Blizzard
function Addon:HandleEvent(event, target)
	local frame

	-- Handle Classic Era Bank
	if event == "BANKFRAME_OPENED" then
		event = "PLAYER_INTERACTION_MANAGER_FRAME_SHOW"
		target = 8
	end

	-- This handles Wrath Classic or later
	if event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
		if target == 8 then -- Bank
			frame = Groups.BankFrame
		elseif target == 10 then -- Guild Bank
			frame = Groups.GuildBankFrame
		elseif target == 26 then -- Void Storage
			frame = Groups.VoidStorageFrame
		end
		if not frame then
			--print("unknown frame", target)
			return
		end
		--print("skinning:", frame.Title, frame.Skinned)
		if not frame.Skinned then
			Core:Skin(frame.Buttons, frame.Group)
			frame.Skinned = true
		end
	end
end

-- Retail Bags are mapped in this way:
--  * ContainerFrame1 is always Backpack
--  * ContainerFrame2 - 5 are the Held Bags
--  * ContainerFrame6 is always Reagent Bag
--  * ContainerFrame7 - 13 are the Bank Bags
--
-- Held and Bank bags use whichever frame is next available and not
-- already showing when they are opened.  This means that Bank Bag
-- 7 could use Frame7 if opened first, or Frame13 if opened after
-- all other bags, so each time a bag is opened we need to check if
-- all its buttons are skinned and skin the ones that are new.
--
-- If the Combined Bag appears, it just adds all the other buttons
-- to itself from their true parents, and sets its size to 0,
-- so we'll have to simulate skinning the bags one by one.
--
-- However, if this is Classic then we just treat all bags the same.
function Addon:ContainerFrame_GenerateFrame(slots, target, parent)
	-- Work on whichever frame Blizzard is giving us
	if self and not parent then
		parent = self
	elseif not parent then
		return
	end
	local frame = parent:GetName()
	local frameitem = frame .. "Item"
	local group = nil

	-- If this is the Combined Bag, simulate skinning the bags one by one.
	if frame == "ContainerFrameCombinedBags" then
		--print("bag combined:", frame, slots, target)
		for i = 1, 5 do
			-- Figure out the number of slots in each bag
			local slots = C_Container.GetContainerNumSlots(i-1)
			Core:ContainerFrame_GenerateFrame(slots, i-1, _G["ContainerFrame"..i])
		end
		return
	end

	-- Skip processing if the bag has no slots
	if slots == 0 then return end

	--print("bag update:", frame, slots, target)

	-- Identify which group this bag belongs to by ID
	if target >= 13 then -- We don't know about this bag
		print("MBI Error: Unknown bag opened", frame, slots, target)
		return
	elseif Core:CheckVersion({ nil, 100000 }) then
		group = Groups.ContainerFrameClassic
	elseif target >= 6 then -- This is a bank bag
		group = Groups.BankContainerFrames
	elseif target == 5 then -- This is the reagent bag
		group = Groups.ContainerFrame6
	elseif target >= 1 then -- This is a held (main) bag
		group = Groups.ContainerFrames
	elseif target == 0 then -- This is the backpack
		group = Groups.ContainerFrame1
	end

	local skinned = group.Buttons[frameitem]

	-- If skinned isn't -1 (a singular button) and there are more
	-- slots than already skinned, skin those new slots
	if skinned >= 0 and skinned < slots then
		for i = group.Buttons[frameitem] + 1, slots do
			group.Group:AddButton(_G[frameitem .. i])
			--print("skinning:", frameitem, i)
		end
		group.Buttons[frameitem] = slots
	end
end

-- Skin the ReagentBank the first time the user opens it.  There's
-- no event to capture and it doesn't exist on initial bank open.
function Addon:BankFrame_ShowPanel()
	local frame = Groups.ReagentBankFrame
	--print("skinning:", frame.Title, frame.Skinned)
	if BankFrame.activeTabIndex == 2 and not frame.Skinned then
		Core:Skin(frame.Buttons, frame.Group)
		frame.Skinned = true
	end
end

-- When new items are being rendered upon opening the mailbox, sometimes
-- the backdrop frame ends up in front of the icon.  Set the draw layer
-- to prevent that.
function Addon:InboxFrame_Update()
	local frame = Groups.MailFrame
	for i=1, INBOXITEMS_TO_DISPLAY do
		local icon = _G["MailItem"..i.."ButtonIcon"]
		icon:SetDrawLayer("ARTWORK", -1)
	end
end

-- Blizzard uses SetNormalTexture() for SendMailAttachment icons but Masque
-- doesn't so we have to set the icons for items when the frame updates.
function Addon:SendMailFrame_Update()
	local frame = Groups.MailFrame
	local button = "SendMailAttachment"
	for i=1, frame.Buttons[button] do
		local icon = _G[button..i].icon
		if HasSendMailItem(i) then
			local _, _, itemTexture, _, _ = GetSendMailItem(i)
			icon:SetTexture(itemTexture or "Interface\\Icons\\INV_Misc_QuestionMark")
		else
			icon:SetTexture(nil)
		end
		-- If we don't do this, sometimes the icon ends up behind the backdrop
		icon:SetDrawLayer("ARTWORK")
	end
end

-- These are init steps specific to this addon
-- This should be run before Core:Init()
function Addon:Init()
	-- All Bag types
	hooksecurefunc("ContainerFrame_GenerateFrame",
	               Addon.ContainerFrame_GenerateFrame)

	-- Inbox
	hooksecurefunc("InboxFrame_Update",
	               Addon.InboxFrame_Update)

	-- Send Mail
	hooksecurefunc("SendMailFrame_Update",
	               Addon.SendMailFrame_Update)

	-- Reagent Bank
	if Core:CheckVersion({ 60000, nil }) then
		hooksecurefunc("BankFrame_ShowPanel",
		               Addon.BankFrame_ShowPanel)
	end

	Addon.Events = CreateFrame("Frame")

	if Core:CheckVersion({ nil, 30401 }) then
		-- Bank (Classic Era)
		Addon.Events:RegisterEvent("BANKFRAME_OPENED")
	end

	if Core:CheckVersion({ 30401, nil }) then
		-- Bank, Guild Bank, and Void Storage
		Addon.Events:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
	end

	Addon.Events:SetScript("OnEvent", Addon.HandleEvent)

	-- Register Callbacks for Various Options here, like:
	-- Metadata.OptionCallbacks.BankFrame = Addon.Update_BankFrame

end

Addon:Init()
Core:Init()
