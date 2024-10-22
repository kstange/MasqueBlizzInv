--
-- Masque Blizzard Inventory
-- Enables Masque to skin the built-in inventory UI
--
-- Copyright 2022 - 2024 SimGuy
--
-- Use of this source code is governed by an MIT-style
-- license that can be found in the LICENSE file or at
-- https://opensource.org/licenses/MIT.
--

local _, Shared = ...

-- From Locales/Locales.lua
-- Not used yet
--local L = Shared.Locale

-- From Metadata.lua
local Metadata = Shared.Metadata
local Groups = Metadata.Groups
local Callbacks = Metadata.OptionCallbacks

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

	-- This handles Character Inspection
	if event == "INSPECT_READY" and InspectPaperDollFrame then
		frame = Groups.InspectPaperDollFrame
		--print("skinning:", frame.Title, frame.Skinned)
		if not frame.Skinned then
			Core:Skin(frame.Buttons, frame.Group)
			frame.Skinned = true
		end
	end

	-- This handles Cataclysm Classic or later
	if event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
		if target == 8 then -- Bank
			frame = Groups.BankFrame
			Addon:Options_BankFrame_Update()
		elseif target == 10 then -- Guild Bank
			frame = Groups.GuildBankFrame
			Addon:Options_GuildBankFrame_Update()
		elseif target == 26 then -- Void Storage
			frame = Groups.VoidStorageFrame
			Addon:Options_VoidStorageFrame_Update()
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
--  * ContainerFrameCombinedBags is always the Combined Backpack
--  * ContainerFrame1 is always standard Backpack
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
-- If the Combined Backpack appears in 10.0, it just adds all the other
-- buttons to itself from their true parents, and sets its size to 0,
-- so we'll have to simulate skinning the bags one by one. In 11.0,
-- the Combined Backpack uses an itemButtonPool of its own.
--
-- However, if this is Classic then we just treat all bags the same
-- because the frames get reused arbitrarily depending on which opens
-- first.
function Addon:ContainerFrame_GenerateFrame(slots, target, parent)
	-- Work on whichever frame Blizzard is giving us
	if self and not parent then
		parent = self
	elseif not parent then
		return
	end
	local frame = parent:GetName()
	local frameitem = frame .. "Item"
	local group

	-- If this is the Combined Bag, simulate skinning the bags one by one
	if frame == "ContainerFrameCombinedBags" and Core:CheckVersion({ nil, 110000 }) then
		--print("bag combined:", frame, slots, target)
		for i = 1, 5 do
			-- Figure out the number of slots in each bag
			local bagslots = C_Container.GetContainerNumSlots(i-1)
			Addon:ContainerFrame_GenerateFrame(bagslots, i-1, _G["ContainerFrame"..i])
		end
		return
	end

	-- Skip processing if the bag has no slots
	if slots == 0 and frame ~= "ContainerFrameCombinedBags" then return end

	--print("bag update:", frame, slots, target)

	-- Identify which group this bag belongs to by ID or name
	if target >= 13 then -- We don't know about this bag
		print("MBI Error: Unknown bag opened", frame, slots, target)
		return
	elseif Core:CheckVersion({ nil, 100000 }) then
		group = Groups.ContainerFrameClassic
	elseif target >= 6 then -- This is a bank bag
		group = Groups.BankContainerFrames
	elseif target >= 1 and target < 5 then -- This is a held (main) bag
		group = Groups.ContainerFrames
	else -- This frame matches its name (reagent, backpack, combined)
		group = Groups[frame]
	end

	Core:Skin(group.Buttons, group.Group, frameitem, slots)
	if group.ButtonPools then
		Core:SkinButtonPool(group.ButtonPools, group.Group)
	end
end

-- Skin the ReagentBank and AccountBank the first time the user opens them.
-- There's no event to capture and it doesn't exist on initial bank open.
function Addon:BankFrame_ShowPanel()
	local rbframe = Groups.ReagentBankFrame
	if BankFrame.activeTabIndex == 2 then
		Addon:Options_ReagentBankFrame_Update()
		if not rbframe.Skinned then
			Core:Skin(rbframe.Buttons, rbframe.Group)
			rbframe.Skinned = true
		end
	end

	local abframe = Groups.AccountBankPanel
	if BankFrame.activeTabIndex == 3 then
		Addon:Options_AccountBankPanel_Update()
		Core:SkinButtonPool(abframe.ButtonPools, abframe.Group)
	end
end

-- Update the visibility of Bank elements based on settings
function Addon:Options_BankFrame_Update()
	-- This only works on Retail due to frame design
	if not Core:CheckVersion({ 100000, nil }) then return end

	local show = not Core:GetOption('BankFrameHideSlots')
	local frame = BankSlotsFrame
	-- This is the texture map used for bank slot artwork
	local texture = 590156

	-- Find regions that use the texture and hide (or show) them
	if frame then
		for i = 1, select("#", frame:GetRegions()) do
			local child = select(i, frame:GetRegions())
			if type(child) == "table" and child.GetTexture and child:GetTexture() == texture then
				child:SetShown(show)
			end
		end
	end
end

-- Update the visibility of Reagent Bank elements based on settings
function Addon:Options_ReagentBankFrame_Update()
	-- This only works on Retail due to frame design
	if not Core:CheckVersion({ 100000, nil }) then return end

	local show = not Core:GetOption('ReagentBankFrameHideSlots')
	local frame = ReagentBankFrame
	-- This is the texture map used for reagent bank slot artwork
	local texture = 997675

	-- Find regions that use the texture and hide (or show) them
	if frame then
		for i = 1, select("#", frame:GetRegions()) do
			local child = select(i, frame:GetRegions())
			if type(child) == "table" and child.GetTexture and child:GetTexture() == texture then
				child:SetShown(show)
			end
		end
	end
end

-- Update the visibility of Warband Bank elements based on settings
function Addon:Options_AccountBankPanel_Update()
	-- This only works on Retail due to frame design
	if not Core:CheckVersion({ 110000, nil }) then return end

	local show = not Core:GetOption('AccountBankPanelHideSlots')

	-- Find all the item buttons in the Warband Bank and hide (or show) them
	for itemButton in AccountBankPanel.itemButtonPool:EnumerateActive() do
		itemButton.Background:SetShown(show)
	end
end

-- Update the visibility of Guild Bank elements based on settings
function Addon:Options_GuildBankFrame_Update()
	-- This only works on Retail due to frame design
	if not Core:CheckVersion({ 100000, nil }) then return end

	local show = not Core:GetOption('GuildBankFrameHideSlots')
	local showbg = not Core:GetOption('GuildBankFrameHideBackground')
	local frame = GuildBankFrame

	-- Find regions that use the texture and hide (or show) them
	if frame then
		for i = 1, 7 do
			local column = frame['Column' .. i]
			if column and column.Background then
				column.Background:SetShown(show)
			end
		end
		if frame.BlackBG then
			frame.BlackBG:SetShown(showbg)
		end
	end
end

-- Update the visibility of Void Storage elements based on settings
function Addon:Options_VoidStorageFrame_Update()
	-- This only works on Retail due to frame design
	if not Core:CheckVersion({ 100000, nil }) then return end

	local show = not Core:GetOption('VoidStorageFrameHideSlots')
	local buttons = Groups.VoidStorageFrame.Buttons

	-- Find regions that use the texture and hide (or show) them
	for button, count in pairs(buttons) do
		for i = 1, count do
			local bg = _G[button .. i .. "Bg"]
			if bg then
				bg:SetShown(show)
			end
		end
	end
end

-- Update the visibility of Equipment Flyout Frame background based on settings
function Addon:Options_EquipmentFlyout_Show()
	-- This frame only exists on Retail
	if not Core:CheckVersion({ 100000, nil }) then return end

	local show = not Core:GetOption('EquipmentFlyoutFrameHideSlots')
	local frame = EquipmentFlyoutFrameButtons

	if not show then
		local i = 1
		while frame['bg' .. i] do
			frame['bg' .. i]:Hide()
			i = i + 1
		end
	end
end

-- Update the visibility of Mail elements based on settings
function Addon:Options_MailFrame_Update()
	-- This only works on Retail due to frame design
	if not Core:CheckVersion({ 100000, nil }) then return end

	local showbg = not Core:GetOption('MailFrameHideInboxBackground')
	local showinbox = not Core:GetOption('MailFrameHideInboxSlots')
	local showsend = not Core:GetOption('MailFrameHideSendSlots')

	-- Find regions that use the texture and hide (or show) them
	for i = 1, INBOXITEMS_TO_DISPLAY do
		-- There is slot artwork in the parent frame
		local frame = _G['MailItem' .. i]
		local texture = 136383

		-- Find regions that use the texture and hide (or show) them
		if frame then
			for r = 1, select("#", frame:GetRegions()) do
				local child = select(r, frame:GetRegions())
				if type(child) == "table" and child.GetTexture and child:GetTexture() == texture then
					child:SetShown(showbg)
				end
			end
		end

		-- The button's also got slot artwork
		local slot = _G['MailItem' .. i .. 'ButtonSlot']
		if slot then
			slot:SetShown(showinbox)
		end
	end

	for i = 1, Groups.MailFrame.Buttons.SendMailAttachment do
		local frame = _G['SendMailAttachment' .. i]
		local texture = 130862

		-- Find regions that use the texture and hide (or show) them
		if frame then
			for r = 1, select("#", frame:GetRegions()) do
				local child = select(r, frame:GetRegions())
				if type(child) == "table" and child.GetTexture and child:GetTexture() == texture then
					child:SetShown(showsend)
				end
			end
		end
	end
end

-- Fix some weird button behavior upon showing the icons in the Equipment Manager
function Addon:GearManagerDialog_Update()
	local bar = Groups.GearManagerDialog
	for i = 1, bar.Buttons.GearSetButton do
		local button = _G['GearSetButton'..i]
		if button.icon:GetTexture() ~= nil then
			button.icon:SetAlpha(1)
			button.icon:Show()
		end
	end
end

-- A shared function to handle dynamic flyout allocation
function Addon:HandleFlyout(group, bname, maxslots)
	local activeSlots = 0
	for slot = 1, maxslots + 1 do
		if _G[bname .. slot] then
			activeSlots = slot
		end
	end

        -- Skin any extra buttons found
	local numButtons = group.Buttons[bname]
	if (numButtons < activeSlots) then
		for i = numButtons + 1, activeSlots do
                        -- TODO: Update this to use Core:Skin()
			local button = _G[bname .. i]
                        group.Group:AddButton(button, { Highlight = button.HighlightTexture }, "Item")
                end
                group.Buttons[bname] = activeSlots
        end

end

-- Paper Doll Frame Item Flyout buttons are created as needed when a flyout is opened, so
-- check for any new buttons any time that happens
function Addon:PaperDollFrameItemFlyout_Show()
	local group = Groups.PaperDollFrameItemFlyout
	Addon:HandleFlyout(group, 'PaperDollFrameItemFlyoutButtons', PDFITEMFLYOUT_MAXITEMS)
end

-- Equipment Flyout buttons are created as needed when a flyout is opened, so
-- check for any new buttons any time that happens
function Addon:EquipmentFlyout_Show()
	local group = Groups.EquipmentFlyoutFrame
	Addon:HandleFlyout(group, 'EquipmentFlyoutFrameButton', EQUIPMENTFLYOUT_ITEMS_PER_PAGE)
	Addon:Options_EquipmentFlyout_Show()
end

-- Locate the LootFrameItems  when the LootFrame opens and skin them since
-- they are generated dynamically.
function Addon:LootFrame_Open()
	local lfc = LootFrame.ScrollBox.ScrollTarget
	local group = Groups.LootFrame

	for i = 1, select("#", lfc:GetChildren()) do
		local lfi = select(i, lfc:GetChildren())

		-- Try not to add buttons that are already added
		--
		-- I'm not sure if the Frame created for the Loot button is used for
		-- the whole life of the UI so if the frame changes, we'll
		-- skin whatever replaced it.
		if lfi and lfi.Item and lfi.Item:GetObjectType() == "Button" then
			local name = lfi:GetDebugName()
			if group.State.LootFrameItem[name] ~= lfi then

				-- TODO: Update this to use Core:Skin()
				group.Group:AddButton(lfi.Item, nil, "Item")
				group.State.LootFrameItem[name] = lfi
			end
		end
	end
end

-- When new items are being rendered upon opening the mailbox, sometimes
-- the backdrop frame ends up in front of the icon.  Set the draw layer
-- to prevent that.
function Addon:InboxFrame_Update()
	Addon:Options_MailFrame_Update()
	for i=1, INBOXITEMS_TO_DISPLAY do
		local icon = _G["MailItem"..i.."ButtonIcon"]
	end
end

-- Blizzard sets the icon non-standardly for SendMailAttachment icons
-- so we have to set the icons for items when the frame updates.
function Addon:SendMailFrame_Update()
	local frame = Groups.MailFrame
	local button = "SendMailAttachment"
	Addon:Options_MailFrame_Update()
	for i=1, frame.Buttons[button] do
		local icon = _G[button..i].icon
		if HasSendMailItem(i) then
			local _, _, itemTexture, _, _ = GetSendMailItem(i)
			icon:SetTexture(itemTexture or "Interface\\Icons\\INV_Misc_QuestionMark")
		else
			icon:SetTexture(nil)
		end
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

	-- EquipmentFlyout
	if Core:CheckVersion({ 40300, nil }) then
		hooksecurefunc("EquipmentFlyout_Show",
		               Addon.EquipmentFlyout_Show)
	end

	-- LootFrame (Retail only)
	if Core:CheckVersion({ 100000, nil }) then
		hooksecurefunc(LootFrame, "Open",
		               Addon.LootFrame_Open)
	end

	Addon.Events = CreateFrame("Frame")
	Addon.Events:RegisterEvent("INSPECT_READY")

	if Core:CheckVersion({ nil, 30401 }) then
		-- Bank (Classic Era)
		Addon.Events:RegisterEvent("BANKFRAME_OPENED")
	end

	if Core:CheckVersion({ 30401, nil }) then
		-- Bank, Guild Bank, and Void Storage
		Addon.Events:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
	end

	Addon.Events:SetScript("OnEvent", Addon.HandleEvent)

	if Core:CheckVersion({ 100000, nil }) then
		-- Register Callbacks for various options here
		Callbacks.BankFrameHideSlots = Addon.Options_BankFrame_Update
		Callbacks.ReagentBankFrameHideSlots = Addon.Options_ReagentBankFrame_Update
		Callbacks.GuildBankFrameHideSlots = Addon.Options_GuildBankFrame_Update
		Callbacks.GuildBankFrameHideBackground = Addon.Options_GuildBankFrame_Update
		Callbacks.VoidStorageFrameHideSlots = Addon.Options_VoidStorageFrame_Update
		Callbacks.MailFrameHideInboxSlots = Addon.Options_MailFrame_Update
		Callbacks.MailFrameHideInboxBackground = Addon.Options_MailFrame_Update
		Callbacks.MailFrameHideSendSlots = Addon.Options_MailFrame_Update
		Callbacks.EquipmentFlyoutFrameHideSlots = Addon.Options_EquipmentFlyout_Show
		if Core:CheckVersion({ 110000, nil }) then
			Callbacks.AccountBankPanelHideSlots = Addon.Options_AccountBankPanel_Update
		else
			Metadata.Options.args.AccountBankPanel = nil
		end

	else
		-- Empty the whole options table because we don't support it on Classic
		Metadata.Options = nil
	end
end

Addon:Init()
Core:Init()
