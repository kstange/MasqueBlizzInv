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
-- Buttons should contain a list of frame names with an integer value
--  If  0, assume to be a singular button with that name
--  If >0, attempt to loop through frames with the name prefix suffixed with
--  the integer range
-- State can be used for storing information about special buttons
local MasqueBlizzInv = {
	Groups = {
		ContainerFrame1 = {
			Title = "Backpack",
			Buttons = {
				-- TODO: Detect bag changes to skin additional buttons
				ContainerFrame1Item = 34
			}
		},
		ContainerFrame2 = {
			Title = "Bag 1",
			Buttons = {
				-- TODO: Detect bag changes to skin additional buttons
				ContainerFrame2Item = 34
			}
		},
		ContainerFrame3 = {
			Title = "Bag 2",
			Buttons = {
				-- TODO: Detect bag changes to skin additional buttons
				ContainerFrame3Item = 34
			}
		},
		ContainerFrame4 = {
			Title = "Bag 3",
			Buttons = {
				-- TODO: Detect bag changes to skin additional buttons
				ContainerFrame4Item = 34
			}
		},
		ContainerFrame5 = {
			Title = "Bag 4",
			Buttons = {
				-- TODO: Detect bag changes to skin additional buttons
				ContainerFrame5Item = 34
			}
		},
		ContainerFrame6 = {
			Title = "Reagent Bag",
			Buttons = {
				-- TODO: Detect bag changes to skin additional buttons
				ContainerFrame6Item = 34
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
				-- TODO: Detect bag changes to skin additional buttons
				ContainerFrame7Item  = 34,
				ContainerFrame8Item  = 34,
				ContainerFrame9Item  = 34,
				ContainerFrame10Item = 34,
				ContainerFrame11Item = 34,
				ContainerFrame12Item = 34,
				ContainerFrame13Item = 34,
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
				GuildBankTab1 = { Button = 0 },
				GuildBankTab2 = { Button = 0 },
				GuildBankTab3 = { Button = 0 },
				GuildBankTab4 = { Button = 0 },
				GuildBankTab5 = { Button = 0 },
				GuildBankTab6 = { Button = 0 },
				GuildBankTab7 = { Button = 0 },
				GuildBankTab8 = { Button = 0 },
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

-- Skin any buttons in the buttons table in Masque group group.  If parent
-- is set, then the button names are children of the parent table.
-- Buttons can be a nested table.
function MasqueBlizzInv:Skin(buttons, group, parent)
	if not parent then parent = _G end
	for button, children in pairs(buttons) do
		if (type(children) == "table") then
			if parent[button] then
				--print('recurse:', button, parent[button])
				MasqueBlizzInv:Skin(children, group, parent[button])
			end
		else
			-- If zero, assume button is the actual button name
			if (children == 0) then
				--print("button:", button, children, parent[button])
				group:AddButton(parent[button])

			-- Otherwise, append the range of numbers to the name
			else
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
