--
-- Masque Blizzard Inventory
-- Enables Masque to skin the built-in inventory UI
--
-- Copyright 2022 - 2026 SimGuy
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

	-- Skip processing if the bag has no slots
	if slots == 0 and frame ~= "ContainerFrameCombinedBags" then return end

	--print("bag update:", frame, slots, target)

	-- Identify which group this bag belongs to by ID or name
	if target >= 13 then -- We don't know about this bag
		print("MBI Error: Unknown bag opened", frame, slots, target)
		return
	elseif Core:CheckVersion({ nil, 16000, 20000, 100000 }) then
		group = Groups.ContainerFrameClassic
	elseif target >= 6 then -- This is a bank bag
		group = Groups.BankContainerFrames
	elseif (target >= 1 and target < 5) or target == -1 then -- This is a held (main) bag, -1 is keyring
		group = Groups.ContainerFrames
	else -- This frame matches its name (reagent, backpack, combined)
		group = Groups[frame]
	end

	Core:Skin(group.Buttons, group.Group, frameitem, slots)
	if group.ButtonPools then
		if frame == "ContainerFrameCombinedBags" then
			Addon:Options_ContainerFrameCombinedBags_Update()
		end
		Core:SkinButtonPool(group.ButtonPools, group.Group)
	end
end

-- Skin the Bank when the panel is refreshed. This is the unified bank from
-- 11.2.0 onward.
function Addon:BankPanel_RefreshBankPanel()
	local bpframe = Groups.BankPanel
	Addon:Options_BankFrame_Update()
	Core:SkinButtonPool(bpframe.ButtonPools, bpframe.Group)
end


-- Update the visibility of Bank elements based on settings
function Addon:Options_BankFrame_Update()
	-- This only works on Retail due to frame design
	local show = not Core:GetOption('BankFrameHideSlots')
	if Core:CheckVersion({ 110200, nil, 16001, 20000 }) then
		-- Find all the item buttons in the Warband Bank and hide (or show) them
		for itemButton in BankPanel.itemButtonPool:EnumerateActive() do
			itemButton.Background:SetShown(show)
		end
	end

end

-- Update the visibility of Reagent Bank elements based on settings
function Addon:Options_ReagentBankFrame_Update()
	-- This only works on Retail due to frame design
	if not Core:CheckVersion({ 100000, 110200 }) then return end

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

-- Update the visibility of Guild Bank elements based on settings
function Addon:Options_GuildBankFrame_Update()
	-- This only works on Retail due to frame design
	if not Core:CheckVersion({ 100000, nil, 16001, 20000 }) then return end

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

-- Update the visibility of Combined Backpack elements based on settings
function Addon:Options_ContainerFrameCombinedBags_Update()
	-- This only works on Retail due to frame design
	if not Core:CheckVersion({ 110000, nil, 16001, 20000 }) then return end

	local show = not Core:GetOption('ContainerFrameCombinedBagsHideSlots')

	-- Find regions that use the texture and hide (or show) them
	for button in ContainerFrameCombinedBags.itemButtonPool:EnumerateActive() do
		if button.ItemSlotBackground then
			button.ItemSlotBackground:SetShown(show)
		end
		Addon:HandleEmptyBackgroundAtlas(button, show)
	end
end

-- Handle the empty slot artwork that blizzard puts behind buttons in Forever
function Addon:HandleEmptyBackgroundAtlas(button, show)
	if button.emptyBackgroundAtlas and not button.originalEmptyBackground then
		button.originalEmptyBackground = button.emptyBackgroundAtlas
	end

	if button.originalEmptyBackground then
		if show then
			button.emptyBackgroundAtlas = button.originalEmptyBackground
			if not button.icon:GetAtlas() and not button.icon:GetTexture() then
				button.icon:SetAtlas(button.emptyBackgroundAtlas)
			end
		else
			button.emptyBackgroundAtlas = nil
			if button.icon:GetAtlas() == button.originalEmptyBackground then
				button.icon:SetAtlas(nil)
			end
		end
	end
end

-- Update the visibility of Equipment Flyout Frame background based on settings
function Addon:Options_EquipmentFlyout_Show()
	-- This frame only exists on Retail
	if not Core:CheckVersion({ 100000, nil, 16001, 20000 }) then return end

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
	if not Core:CheckVersion({ 100000, nil, 16001, 20000 }) then return end

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

	-- Mailbox Tabs
	-- There's a new implementation in 1.60, probably coming to 12.2 or 13.0?
	if Core:CheckVersion({ 16001, 20000 }) then
		hooksecurefunc(InboxFrame, "Update",
		               Addon.InboxFrame_Update)
	else
		hooksecurefunc("InboxFrame_Update",
		               Addon.InboxFrame_Update)
	end
	hooksecurefunc("SendMailFrame_Update",
	               Addon.SendMailFrame_Update)

	if Core:CheckVersion({ 110200, nil, 16001, 20000 }) then
		hooksecurefunc(BankPanel, "RefreshBankPanel",
		               Addon.BankPanel_RefreshBankPanel)
	end

	-- Equipment Flyout
	if Core:CheckVersion({ 40300, nil, 16001, 20000 }) then
		hooksecurefunc("EquipmentFlyout_Show",
		               Addon.EquipmentFlyout_Show)
	end

	-- LootFrame (Retail & Forever)
	if Core:CheckVersion({ 100000, nil, 16001, 20000 }) then
		hooksecurefunc(LootFrame, "Open",
		               Addon.LootFrame_Open)
	end

	Addon.Events = CreateFrame("Frame")
	Addon.Events:RegisterEvent("INSPECT_READY")

	if Core:CheckVersion({ nil, 16000, 20000, 30401 }) then
		-- Bank (Classic Era)
		Addon.Events:RegisterEvent("BANKFRAME_OPENED")
	end

	if Core:CheckVersion({ 30401, nil, 16001, 20000 }) then
		-- Bank, Guild Bank
		Addon.Events:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
	end

	Addon.Events:SetScript("OnEvent", Addon.HandleEvent)

	if Core:CheckVersion({ 100000, nil, 16001, 20000 }) then
		-- Register Callbacks for various options here
		Callbacks.BankFrameHideSlots = Addon.Options_BankFrame_Update
		Callbacks.GuildBankFrameHideSlots = Addon.Options_GuildBankFrame_Update
		Callbacks.GuildBankFrameHideBackground = Addon.Options_GuildBankFrame_Update
		Callbacks.MailFrameHideInboxSlots = Addon.Options_MailFrame_Update
		Callbacks.MailFrameHideInboxBackground = Addon.Options_MailFrame_Update
		Callbacks.MailFrameHideSendSlots = Addon.Options_MailFrame_Update
		Callbacks.EquipmentFlyoutFrameHideSlots = Addon.Options_EquipmentFlyout_Show
	end
	if Core:CheckVersion({ 110000, 110200 }) then
		Callbacks.AccountBankPanelHideSlots = Addon.Options_AccountBankPanel_Update
	else
		Metadata.Options.args.AccountBankPanel = nil
	end
	if Core:CheckVersion({ 110000, nil, 16001, 20000 }) then
		Callbacks.ContainerFrameCombinedBagsHideSlots = Addon.Options_ContainerFrameCombinedBags_Update
	else
		Metadata.Options.args.ContainerFrameCombinedBags = nil
	end
	if Core:CheckVersion({ nil, 16000, 20000, 100000 }) then
		-- Empty the whole options table because we don't support it on Classic
		Metadata.Options = nil
	end
end

Addon:Init()
Core:Init()
