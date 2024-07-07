--
-- Masque Blizzard Inventory
-- Enables Masque to skin the built-in inventory UI
--
-- Copyright 2022 - 2023 SimGuy
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

-- Compatibility for WoW 10.1.0
local GetAddOnMetadata = _G.GetAddOnMetadata or C_AddOns.GetAddOnMetadata

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
		Versions = { 100000, nil },
		Buttons = {
			ContainerFrame1Item = 0
		},
		ButtonPools = {
			ContainerFrame1
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
		},
		ButtonPools = {
			ContainerFrame2,
			ContainerFrame3,
			ContainerFrame4,
			ContainerFrame5
		}
	},
	ContainerFrame6 = {
		Title = "Reagent Bag",
		Versions = { 100000, nil },
		Buttons = {
			ContainerFrame6Item = 0
		},
		ButtonPools = {
			ContainerFrame6
		}
	},
	ContainerFrameCombinedBags = {
		Title = "Combined Backpack",
		Versions = { 110000, nil },
		Buttons = { },
		ButtonPools = {
			ContainerFrameCombinedBags
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
		},
		ButtonPools = {
			ContainerFrame7,
			ContainerFrame8,
			ContainerFrame9,
			ContainerFrame10,
			ContainerFrame11,
			ContainerFrame12,
			ContainerFrame13
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
	AccountBankPanel = {
		Title = "Warband Bank",
		Delayed = true,
		Skinned = false,
		Versions = { 110000, nil },
		Buttons = { },
		ButtonPools = {
			AccountBankPanel
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
		-- Originally added in 4.3.0, but not being added in
		-- Cata Classic, so mark as unsupported until 10.0.0
		Versions = { 100000, nil },
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
			OpenMailMoneyButton = -1,
			SendMailAttachment = ATTACHMENTS_MAX_SEND,
		}
	},
	-- Classic Only
	MainMenuBarBags = {
		Title = "Bag Bar",
		Versions = { nil, 100000 },
		Buttons = {
			MainMenuBarBackpackButton = -1,
			CharacterBag0Slot = -1,
			CharacterBag1Slot = -1,
			CharacterBag2Slot = -1,
			CharacterBag3Slot = -1,
		}
	},
	InspectPaperDollFrame = {
		Title = "Inspect Character",
		Delayed = true,
		Skinned = false,
		Buttons = {
			InspectHeadSlot = -1,
			InspectNeckSlot = -1,
			InspectShoulderSlot = -1,
			InspectBackSlot = -1,
			InspectChestSlot = -1,
			InspectShirtSlot = -1,
			InspectTabardSlot = -1,
			InspectWristSlot = -1,
			InspectHandsSlot = -1,
			InspectWaistSlot = -1,
			InspectLegsSlot = -1,
			InspectFeetSlot = -1,
			InspectFinger0Slot = -1,
			InspectFinger1Slot = -1,
			InspectTrinket0Slot = -1,
			InspectTrinket1Slot = -1,
			InspectMainHandSlot = -1,
			InspectSecondaryHandSlot = -1,
			InspectRangedSlot = -1,
			InspectAmmoSlot = -1,
		}
	},
	PaperDollFrame = {
		Title = "Character",
		Init = function(buttons)
			-- Replace the highlight manually on the PaperDollFrame
			-- AzeritePaperDollItemOverlayMixin:ResetAzeriteTextures()
			-- aggressively resets the regular highlight to stock
			for b, _ in pairs(buttons) do
				local button = _G[b]
				if button then
					if not button.HighlightTexture then
						button.HighlightTexture = button:GetHighlightTexture()
					end
					button.NewHighlight = button:CreateTexture()
					button.NewHighlight:SetDrawLayer("HIGHLIGHT")
					button.HighlightTexture:SetAlpha(0)
					button.NewHighlight:SetTexture(button.HighlightTexture:GetTexture())
				end
			end
		end,
		Buttons = {
			CharacterHeadSlot = -1,
			CharacterNeckSlot = -1,
			CharacterShoulderSlot = -1,
			CharacterBackSlot = -1,
			CharacterChestSlot = -1,
			CharacterShirtSlot = -1,
			CharacterTabardSlot = -1,
			CharacterWristSlot = -1,
			CharacterHandsSlot = -1,
			CharacterWaistSlot = -1,
			CharacterLegsSlot = -1,
			CharacterFeetSlot = -1,
			CharacterFinger0Slot = -1,
			CharacterFinger1Slot = -1,
			CharacterTrinket0Slot = -1,
			CharacterTrinket1Slot = -1,
			CharacterMainHandSlot = -1,
			CharacterSecondaryHandSlot = -1,
			CharacterRangedSlot = -1,
			CharacterAmmoSlot = -1,
		}
	},
	-- Wrath Classic Only
	GearManagerDialog = {
		Title = "Equipment Manager",
		Versions = { 30300, 40300 },
		Init = function(buttons)
			-- Fix icon visibility on Equipment Manager
			for i = 1, buttons.GearSetButton do
				local button = _G['GearSetButton'..i]
				button.icon:SetDrawLayer("BACKGROUND", 4)
			end
		end,
		Buttons = {
			GearSetButton = 10,
		}
	},
	-- Wrath Classic Only
	PaperDollFrameItemFlyout = {
		Title = "Equipment Flyouts",
		Versions = { 30300, 40300 },
		Buttons = {
			PaperDollFrameItemFlyoutButtons = 0,
		}
	},
	EquipmentFlyoutFrame = {
		Title = "Equipment Flyouts",
		Versions = { 40300, nil },
		Buttons = {
			EquipmentFlyoutFrameButton = 0,
		}
	},
	MerchantFrame = {
		Title = "Merchants",
		Buttons = {
			MerchantItem1ItemButton = -1,
			MerchantItem2ItemButton = -1,
			MerchantItem3ItemButton = -1,
			MerchantItem4ItemButton = -1,
			MerchantItem5ItemButton = -1,
			MerchantItem6ItemButton = -1,
			MerchantItem7ItemButton = -1,
			MerchantItem8ItemButton = -1,
			MerchantItem9ItemButton = -1,
			MerchantItem10ItemButton = -1,
			MerchantItem11ItemButton = -1,
			MerchantItem12ItemButton = -1,
			MerchantBuyBackItemItemButton = -1,
		}
	},
	LootFrame = {
		Title = "Loot",
		Versions = { 100000, nil },
		State = {
			LootFrameItem = {},
		},
		Buttons = {}
	},
	LootFrameClassic = {
		Title = "Loot",
		Versions = { nil, 100000 },
		Buttons = {
			LootButton = 4,
		}
	}
}

-- Specify Button Types and Regions for Buttons that need them
Metadata.Types = {
	-- This will be passed for all buttons unless it's otherwise overridden
	DEFAULT = { type = "Item" },

	GuildBankTab1Button = { type = "Action" },
	GuildBankTab2Button = { type = "Action" },
	GuildBankTab3Button = { type = "Action" },
	GuildBankTab4Button = { type = "Action" },
	GuildBankTab5Button = { type = "Action" },
	GuildBankTab6Button = { type = "Action" },
	GuildBankTab7Button = { type = "Action" },
	GuildBankTab8Button = { type = "Action" },
	SendMailAttachment = { map = { Icon = "icon" } },
	GearSetButton = { map = { Icon = "icon" } },
	CharacterHeadSlot = { map = { Highlight = "NewHighlight" } },
	CharacterNeckSlot = { map = { Highlight = "NewHighlight" } },
	CharacterShoulderSlot = { map = { Highlight = "NewHighlight" } },
	CharacterBackSlot = { map = { Highlight = "NewHighlight" } },
	CharacterChestSlot = { map = { Highlight = "NewHighlight" } },
	CharacterShirtSlot = { map = { Highlight = "NewHighlight" } },
	CharacterTabardSlot = { map = { Highlight = "NewHighlight" } },
	CharacterWristSlot = { map = { Highlight = "NewHighlight" } },
	CharacterHandsSlot = { map = { Highlight = "NewHighlight" } },
	CharacterWaistSlot = { map = { Highlight = "NewHighlight" } },
	CharacterLegsSlot = { map = { Highlight = "NewHighlight" } },
	CharacterFeetSlot = { map = { Highlight = "NewHighlight" } },
	CharacterFinger0Slot = { map = { Highlight = "NewHighlight" } },
	CharacterFinger1Slot = { map = { Highlight = "NewHighlight" } },
	CharacterTrinket0Slot = { map = { Highlight = "NewHighlight" } },
	CharacterTrinket1Slot = { map = { Highlight = "NewHighlight" } },
	CharacterMainHandSlot = { map = { Highlight = "NewHighlight" } },
	CharacterSecondaryHandSlot = { map = { Highlight = "NewHighlight" } },
	CharacterRangedSlot = { map = { Highlight = "NewHighlight" } },
	CharacterAmmoSlot = { map = { Highlight = "NewHighlight" } },
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
	name = format(L["OPTIONS_TITLE_MAIN"], Metadata.FriendlyName) .. "     |cFFAAAAAA" ..
	              (GetAddOnMetadata(AddonName, "Version") or "Unknown"),
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
					width = "full",
				},
				GuildBankFrameHideBackground = {
					name = L["Hide Background"],
					desc = L["OPTIONS_DESCRIPTION_GUILDBANK_BACKGROUND"],
					type = "toggle",
					width = "full",
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
		},
		MailFrame = {
			name = L["Mail"],
			type = "group",
			args = {
				MailFrameHideInboxSlots = {
					name = L["Hide Inbox Slots"],
					desc = L["OPTIONS_DESCRIPTION_SLOTS"],
					type = "toggle",
					width = "full",
				},
				MailFrameHideInboxBackground = {
					name = L["Hide Inbox Background"],
					desc = L["OPTIONS_DESCRIPTION_MAIL_INBOX_BACKGROUND"],
					type = "toggle",
					width = "full",
				},
				MailFrameHideSendSlots = {
					name = L["Hide Send Mail Attachment Slots"],
					desc = L["OPTIONS_DESCRIPTION_SLOTS"],
					type = "toggle",
					width = "full",
				},
			}
		},
--[[
		InspectPaperDollFrame = {
			name = L["Inspect Character"],
			type = "group",
			args = {
				InspectPaperDollFrameHideSlots = {
					name = L["Hide Slots"],
					desc = L["OPTIONS_DESCRIPTION_SLOTS"],
					type = "toggle",
				},
			}
		},
		PaperDollFrame = {
			name = L["Character"],
			type = "group",
			args = {
				PaperDollFrameHideSlots = {
					name = L["Hide Slots"],
					desc = L["OPTIONS_DESCRIPTION_SLOTS"],
					type = "toggle",
				},
			}
		},
]]--
		EquipmentFlyoutFrame = {
			name = L["Equipment Flyouts"],
			type = "group",
			args = {
				EquipmentFlyoutFrameHideSlots = {
					name = L["Hide Slots"],
					desc = L["OPTIONS_DESCRIPTION_SLOTS"],
					type = "toggle",
				},
			}
		},
--[[
		MerchantFrame = {
			name = L["Merchants"],
			type = "group",
			args = {
				MerchantFrameHideSlots = {
					name = L["Hide Slots"],
					desc = L["OPTIONS_DESCRIPTION_SLOTS"],
					type = "toggle",
				},
			}
		},
]]
	}
}

