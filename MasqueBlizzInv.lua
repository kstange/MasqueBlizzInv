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

-- Title will be used for the group name shown in Masque
-- Delayed indicates this group will be deferred to a hook or event
-- Buttons should contain a list of frame names with an integer value
--  If -1, assume to be a singular button with that name
--  If  0, this is a dynamic frame to be skinned later
--  If >0, attempt to loop through frames with the name prefix suffixed with
--  the integer range
-- State can be used for storing information about special buttons
local MasqueBlizzInv = {
	Groups = {
		ContainerFrame1 = {
			Title = "Backpack",
			Buttons = {
				ContainerFrame1Item = 0
			}
		},
		ContainerFrames = {
			Title = "Main Bags",
			Buttons = {
				ContainerFrame2Item = 0,
				ContainerFrame3Item = 0,
				ContainerFrame4Item = 0,
				ContainerFrame5Item = 0,
			}
		},
		ContainerFrame6 = {
			Title = "Reagent Bag",
			Buttons = {
				ContainerFrame6Item = 0
			}
		},
		BankContainerFrames = {
			Title = "Bank Bags",
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
			Buttons = {
				VoidStorageStorageButton = 80,
				VoidStorageDepositButton = 9,
				VoidStorageWithdrawButton = 9,
				-- Tab buttons don't have icon in a reliable place
				--VoidStorageFrame = {
				--	Page = 2
				--}
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

-- Bags are mapped in this way:
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

function MasqueBlizzInv:Init()
	-- Hook functions to skin elusive buttons
	hooksecurefunc("ContainerFrame_GenerateFrame",
	               MasqueBlizzInv.ContainerFrame_GenerateFrame)
	hooksecurefunc("BankFrame_ShowPanel",
	               MasqueBlizzInv.BankFrame_ShowPanel)

	-- Capture events to skin elusive buttons
	MasqueBlizzInv.Events = CreateFrame("Frame")
	MasqueBlizzInv.Events:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
	MasqueBlizzInv.Events:SetScript("OnEvent", MasqueBlizzInv.HandleEvent)

	-- Create groups for each defined button group and add any buttons
	-- that should exist at this point
	for _, cont in pairs(MasqueBlizzInv.Groups) do
		cont.Group = MSQ:Group("Blizzard Inventory", cont.Title)
		if not cont.Delayed then
			MasqueBlizzInv:Skin(cont.Buttons, cont.Group)
		end
	end
end

MasqueBlizzInv:Init()
