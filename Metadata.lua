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

local AddonName, Shared = ...

-- From Locales/Locales.lua
local L = Shared.Locale

-- Push us into shared object
local Metadata = {}
Shared.Metadata = Metadata

Metadata.FriendlyName = "Masque Blizzard Inventory"
Metadata.MasqueFriendlyName = "Blizzard Inventory"

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
Metadata.Groups = {
	ContainerFrameClassic = {
		Title = "Bags",
		Notes = L["NOTES_BAGS_CLASSIC"],
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
		Notes = L["NOTES_BACKPACK"],
		Versions = { 100000, nil },
		Buttons = {
			ContainerFrame1Item = 0
		}
	},
	ContainerFrames = {
		Title = "Main Bags",
		Notes = L["NOTES_MAIN_BAGS"],
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
		Versions = { 20300, nil },
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
		Notes = L["NOTES_MAIL"],
		Init = function (buttons)
				-- Send buttons only use NormalTexture, so
				-- create an icon for Masque to display
				for i = 1, buttons.SendMailAttachment do
					local button = _G['SendMailAttachment'..i]
					button.icon = button:CreateTexture()
				end
				-- FIXME: This should be handled with regions
				-- Define the icon border where Masque expects
				for i = 1, INBOXITEMS_TO_DISPLAY do
					local button = _G['MailItem'..i..'Button']
					button.Border = button.IconBorder
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
			OpenMailLetterButton = -1,
			SendMailAttachment = ATTACHMENTS_MAX_SEND,
		}
	}
}

-- A table indicating the defaults for Options by key.
-- Only populate options where the default isn't false
Metadata.Defaults = {
}

-- A table of function callbacks to call upon setting certain options.
-- This has to be populated by the Addon during its init process, since
-- the functions won't exist by this point, so this should remain empty
-- here.
Metadata.OptionCallbacks = {}

-- AceConfig Options table used to display a panel.
Metadata.Options = {
	type = "group",
	name = format(L["OPTIONS_TITLE_MAIN"], Metadata.FriendlyName),
	args = {
		Description = {
			name = L["OPTIONS_DESCRIPTION_MAIN"] .. "\n ",
			type = "description",
			fontSize = "medium",
		},
		BankFrame = {
			name = L["Bank"],
			type = "group",
			args = {
				BankFrameHideSlots = {
					name = L["Hide Slots"],
					desc = L["OPTIONS_DESCRIPTION_SLOTS"],
					type = "toggle",
				},
			}
		},
		ReagentBankFrame = {
			name = L["Reagent Bank"],
			type = "group",
			args = {
				ReagentBankFrameHideSlots = {
					name = L["Hide Slots"],
					desc = L["OPTIONS_DESCRIPTION_SLOTS"],
					type = "toggle",
				},
			}
		},
		GuildBankFrame = {
			name = L["Guild Bank"],
			type = "group",
			args = {
				GuildBankFrameHideSlots = {
					name = L["Hide Slots"],
					desc = L["OPTIONS_DESCRIPTION_SLOTS"],
					type = "toggle",
				},
				GuildBankFrameHideBackground = {
					name = L["Hide Background"],
					desc = L["OPTIONS_DESCRIPTION_GUILDBANK_BACKGROUND"],
					type = "toggle",
				},
			}
		},
		VoidStorageFrame = {
			name = L["Void Storage"],
			type = "group",
			args = {
				VoidStorageFrameHideSlots = {
					name = L["Hide Slots"],
					desc = L["OPTIONS_DESCRIPTION_SLOTS"],
					type = "toggle",
				},
			}
		}
	}
}

