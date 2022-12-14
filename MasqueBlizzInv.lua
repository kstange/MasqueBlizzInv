-- 
-- Masque Blizzard Inventory
-- Enables Masque to skin the built-in inventory UI
--
-- Copyright 2022 SimGuy
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
				ContainerFrame1Item = 34
			}
		},
		ContainerFrame2 = {
			Title = "Bag 1",
			Buttons = {
				ContainerFrame2Item = 34
			}
		},
		ContainerFrame3 = {
			Title = "Bag 2",
			Buttons = {
				ContainerFrame3Item = 34
			}
		},
		ContainerFrame4 = {
			Title = "Bag 3",
			Buttons = {
				ContainerFrame4Item = 34
			}
		},
		ContainerFrame5 = {
			Title = "Bag 4",
			Buttons = {
				ContainerFrame5Item = 34
			}
		},
		ContainerFrame6 = {
			Title = "Reagent Bag",
			Buttons = {
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
				ContainerFrame7Item  = 34,
				ContainerFrame8Item  = 34,
				ContainerFrame9Item  = 34,
				ContainerFrame10Item = 34,
				ContainerFrame11Item = 34,
				ContainerFrame12Item = 34,
				ContainerFrame13Item = 34,
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
				group:AddButton(parent[button])
				--print("button:", button, children, parent[button]:GetName())

			-- Otherwise, append the range of numbers to the name
			else
				for i = 1, children do
					group:AddButton(parent[button..i])
					--print("button:", button, children, parent[button..i]:GetName())
				end
			end
		end
	end
end

function MasqueBlizzInv:Init()
	-- Hook functions to skin elusive buttons

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
