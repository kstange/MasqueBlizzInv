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

local MSQ = LibStub("Masque")

local _, Shared = ...
local L = Shared.Locale

local _, _, _, ver = GetBuildInfo()

-- Title will be used for the group name shown in Masque
-- Delayed indicates this group will be deferred to a hook or event
-- Init is a function that will be run at load time for this group
-- Notes will be displayed (if provided) in the Masque settings UI
-- Versions specifies which WoW clients this group supports:
--  To match it must be >= low and < high.
--  High number is the first interface unsupported
-- Buttons should contain a list of frame names with an integer value
--  If -1, assume to be a singular button with that name
--  If  0, this is a dynamic frame to be skinned later
--  If >0, attempt to loop through frames with the name prefix suffixed with
--  the integer range
-- State can be used for storing information about special buttons
local MasqueBlizzInv = {
	Groups = {
		ContainerFrameClassic = {
			Title = "Bags",
			Notes = L["This group skins the Backpack, the Keyring, Main Bags, and Bank Bags"],
			Versions = { nil, 100000 },
			Buttons = {
				ContainerFrame1Item = 0,
				ContainerFrame2Item = 0,
				ContainerFrame3Item = 0,
				ContainerFrame4Item = 0,
				ContainerFrame5Item = 0,
				ContainerFrame6Item = 0,
				ContainerFrame7Item = 0,
				ContainerFrame8Item = 0,
				ContainerFrame9Item = 0,
				ContainerFrame10Item = 0,
				ContainerFrame11Item = 0,
				ContainerFrame12Item = 0,
				ContainerFrame13Item = 0,
			}
		},
		ContainerFrame1 = {
			Title = "Backpack",
			Notes = L["This group skins the Backpack.  If you have enabled the Combined Backpack, it will only skin the slots from the real Backpack and not other bags."],
			Versions = { 100000, nil },
			Buttons = {
				ContainerFrame1Item = 0
			}
		},
		ContainerFrames = {
			Title = "Main Bags",
			Notes = L["This group skins the main Bags other than the Backpack and Reagent Bag.  If you have enabled the Combined Backpack, it will only skin the slots from those bags and not the Backpack."],
			Versions = { 100000, nil },
			Buttons = {
				ContainerFrame2Item = 0,
				ContainerFrame3Item = 0,
				ContainerFrame4Item = 0,
				ContainerFrame5Item = 0,
			}
		},
		ContainerFrame6 = {
			Title = "Reagent Bag",
			Versions = { 100000, nil },
			Buttons = {
				ContainerFrame6Item = 0
			}
		},
		BankContainerFrames = {
			Title = "Bank Bags",
			Versions = { 100000, nil },
			Buttons = {
				ContainerFrame7Item  = 0,
				ContainerFrame8Item  = 0,
				ContainerFrame9Item  = 0,
				ContainerFrame10Item = 0,
				ContainerFrame11Item = 0,
				ContainerFrame12Item = 0,
				ContainerFrame13Item = 0,
			}
		},
		BankFrame = {
			Title = "Bank",
			Delayed = true,
			Skinned = false,
			Buttons = {
				BankSlotsFrame = {
					Item = 28,
					Bag = 7,
				},
			}
		},
		ReagentBankFrame = {
			Title = "Reagent Bank",
			Delayed = true,
			Skinned = false,
			Versions = { 60000, nil },
			Buttons = {
				ReagentBankFrameItem = 98
			}
		},
		GuildBankFrame = {
			Title = "Guild Bank",
			Delayed = true,
			Skinned = false,
			Buttons = {
				GuildBankFrame = {
					Column1 = { Button = 14 },
					Column2 = { Button = 14 },
					Column3 = { Button = 14 },
					Column4 = { Button = 14 },
					Column5 = { Button = 14 },
					Column6 = { Button = 14 },
					Column7 = { Button = 14 },
				},
				GuildBankTab1 = { Button = -1 },
				GuildBankTab2 = { Button = -1 },
				GuildBankTab3 = { Button = -1 },
				GuildBankTab4 = { Button = -1 },
				GuildBankTab5 = { Button = -1 },
				GuildBankTab6 = { Button = -1 },
				GuildBankTab7 = { Button = -1 },
				GuildBankTab8 = { Button = -1 },
			}
		},
		VoidStorageFrame = {
			Title = "Void Storage",
			Delayed = true,
			Skinned = false,
			Versions = { 40300, nil },
			Buttons = {
				VoidStorageStorageButton = 80,
				VoidStorageDepositButton = 9,
				VoidStorageWithdrawButton = 9,
				-- Tab buttons don't have icon in a reliable place
				--VoidStorageFrame = {
				--	Page = 2
				--}
			}
		},
		MailFrame = {
			Title = "Mail",
			Notes = L["This group skins the Inbox, Send Mail, and Open Mail attachments."],
			Init = function (buttons)
					-- Send buttons only use NormalTexture, so
					-- create an icon for Masque to display
					for i = 1, buttons.SendMailAttachment do
						button = _G['SendMailAttachment'..i]
						button.icon = button:CreateTexture()
					end
				end,
			Buttons = {
				MailItem1Button = -1,
				MailItem2Button = -1,
				MailItem3Button = -1,
				MailItem4Button = -1,
				MailItem5Button = -1,
				MailItem6Button = -1,
				MailItem7Button = -1,
				-- It appears the game defines 16 attachment
				-- slots even though players can only use 12
				OpenMailAttachmentButton = ATTACHMENTS_MAX,
				SendMailAttachment = ATTACHMENTS_MAX_SEND,
			}
		}
	}
}

-- Handle events for buttons that get created dynamically by Blizzard
function MasqueBlizzInv:HandleEvent(event, target)
	local frame
	if event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
		if target == 8 then -- Bank
			frame = MasqueBlizzInv.Groups.BankFrame
		elseif target == 10 then -- Guild Bank
			frame = MasqueBlizzInv.Groups.GuildBankFrame
		elseif target == 26 then -- Void Storage
			frame = MasqueBlizzInv.Groups.VoidStorageFrame
		end
		if not frame then
			--print("unknown frame", target)
			return
		end
		--print("skinning:", frame.Title, frame.Skinned)
		if not frame.Skinned then
			MasqueBlizzInv:Skin(frame.Buttons, frame.Group)
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
function MasqueBlizzInv:ContainerFrame_GenerateFrame(slots, target, parent)
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
			MasqueBlizzInv:ContainerFrame_GenerateFrame(slots, i-1, _G["ContainerFrame"..i])
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
	elseif MasqueBlizzInv:CheckVersion({ nil, 100000 }) then
		group = MasqueBlizzInv.Groups.ContainerFrameClassic
	elseif target >= 6 then -- This is a bank bag
		group = MasqueBlizzInv.Groups.BankContainerFrames
	elseif target == 5 then -- This is the reagent bag
		group = MasqueBlizzInv.Groups.ContainerFrame6
	elseif target >= 1 then -- This is a held (main) bag
		group = MasqueBlizzInv.Groups.ContainerFrames
	elseif target == 0 then -- This is the backpack
		group = MasqueBlizzInv.Groups.ContainerFrame1
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

-- Skin any buttons in the table as members of the given Masque group.
-- If parent is set, then the button names are children of the parent
-- table. The buttons value can be a nested table.
function MasqueBlizzInv:Skin(buttons, group, parent)
	if not parent then parent = _G end
	for button, children in pairs(buttons) do
		if (type(children) == "table") then
			if parent[button] then
				--print('recurse:', button, parent[button])
				MasqueBlizzInv:Skin(children, group, parent[button])
			end
		else
			-- If -1, assume button is the actual button name
			if children == -1 then
				--print("button:", button, children, parent[button])
				group:AddButton(parent[button])

			-- Otherwise, append the range of numbers to the name
			elseif children > 0 then
				for i = 1, children do
					--print("button:", button, children, parent[button..i])
					group:AddButton(parent[button..i])
				end
			end
		end
	end
end

-- Skin the ReagentBank the first time the user opens it.  There's
-- no event to capture and it doesn't exist on initial bank open.
function MasqueBlizzInv:BankFrame_ShowPanel()
	local frame = MasqueBlizzInv.Groups.ReagentBankFrame
	--print("skinning:", frame.Title, frame.Skinned)
	if BankFrame.activeTabIndex == 2 and not frame.Skinned then
		MasqueBlizzInv:Skin(frame.Buttons, frame.Group)
		frame.Skinned = true
	end
end

-- Blizzard uses SetNormalTexture() for SendMailAttachment icons but Masque
-- doesn't so we have to set the icons for items when the frame updates.
function MasqueBlizzInv:SendMailFrame_Update()
	local frame = MasqueBlizzInv.Groups.MailFrame
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

-- Check if the current interface version is between the low number (inclusive)
-- and the high number (exclusive) for implementations that are dependent upon
-- client version.
function MasqueBlizzInv:CheckVersion(versions)
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

function MasqueBlizzInv:Init()
	-- Hook functions to skin elusive buttons

	-- All Bag types
	hooksecurefunc("ContainerFrame_GenerateFrame",
	               MasqueBlizzInv.ContainerFrame_GenerateFrame)

	-- Send Mail
	hooksecurefunc("SendMailFrame_Update",
	               MasqueBlizzInv.SendMailFrame_Update)

	-- Reagent Bank
	if MasqueBlizzInv:CheckVersion({ 60000, nil }) then
		hooksecurefunc("BankFrame_ShowPanel",
		               MasqueBlizzInv.BankFrame_ShowPanel)
	end

	-- Capture events to skin elusive buttons
	MasqueBlizzInv.Events = CreateFrame("Frame")

	if MasqueBlizzInv:CheckVersion({ 30401, nil }) then
		-- Bank, Guild Bank, and Void Storage
		MasqueBlizzInv.Events:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
	end

	MasqueBlizzInv.Events:SetScript("OnEvent", MasqueBlizzInv.HandleEvent)

	-- Create groups for each defined button group and add any buttons
	-- that should exist at this point
	for id, cont in pairs(MasqueBlizzInv.Groups) do
		if MasqueBlizzInv:CheckVersion(cont.Versions) then
			cont.Group = MSQ:Group("Blizzard Inventory", cont.Title, id)
			-- Reset l10n group names after ensuring migration to Static IDs
			cont.Group:SetName(L[cont.Title])
			if cont.Init then
				cont.Init(cont.Buttons)
			end
			if cont.Notes then
				cont.Group.Notes = cont.Notes
			end
			if not cont.Delayed then
				MasqueBlizzInv:Skin(cont.Buttons, cont.Group)
			end
		end
	end
end

MasqueBlizzInv:Init()
