--
-- Masque Blizzard Inventory
--
-- Locales\enUS.lua -- enUS Localization File
--
-- Use of this source code is governed by an MIT-style
-- license that can be found in the LICENSE file or at
-- https://opensource.org/licenses/MIT.
--

-- Please use CurseForge to submit localization content for another language:
-- https://www.curseforge.com/wow/addons/masque-blizz-inventory/localization

-- allow enUS to fill empty strings for other locales
--local Locale = GetLocale()
--if Locale ~= "enUS" then return end

local _, Shared = ...
local L = Shared.Locale

-- Defaults for these are the keys themselves
--L["Bags"] = "Bags"
--L["Backpack"] = "Backpack"
--L["Main Bags"] = "Main Bags"
--L["Reagent Bag"] = "Reagent Bag"
--L["Bank Bags"] = "Bank Bags"
--L["Bank"] = "Bank"
--L["Reagent Bank"] = "Reagent Bank"
--L["Guild Bank"] = "Guild Bank"
--L["Void Storage"] = "Void Storage"
--L["Mail"] = "Mail"
--L["Bag Bar"] = "Bag Bar"
--L["Character"] = "Character"
--L["Inspect Character"] = "Inspect Character"
--L["Equipment Manager"] = "Equipment Manager"
--L["Equipment Flyouts"] = "Equipment Flyouts"
--L["Merchants"] = "Merchants"
--L["Loot"] = "Loot"
--L["Hide Background"] = "Hide Background"
--L["Hide Slots"] = "Hide Slots"
--L["Hide Inbox Background"] = "Hide Inbox Background"
--L["Hide Inbox Slots"] = "Hide Inbox Slots"
--L["Hide Send Mail Attachment Slots"] = "Hide Send Mail Attachment Slots"

-- Using short keys for these long strings, so enUS needs to be defined as well
L["NOTES_BAGS_CLASSIC"] = "This group skins the Backpack, the Keyring, Main Bags, and Bank Bags."
L["NOTES_BACKPACK"] = "This group skins the Backpack.  If you have enabled the Combined Backpack, it will only skin the slots from the real Backpack and not other bags."
L["NOTES_MAIN_BAGS"] = "This group skins the main Bags other than the Backpack and Reagent Bag.  If you have enabled the Combined Backpack, it will only skin the slots from those bags and not the Backpack."
L["NOTES_MAIL"] = "This group skins the Inbox, Send Mail, and Open Mail attachments."
L["OPTIONS_TITLE_MAIN"] = "%s Extended Options"
L["OPTIONS_DESCRIPTION_MAIN"] = "These options allow you to customize inventory elements to make them look better with certain Masque skins, such as by hiding background artwork."
L["OPTIONS_DESCRIPTION_SLOTS"] = "Hide the slot artwork behind items."
L["OPTIONS_DESCRIPTION_GUILDBANK_BACKGROUND"] = "Hide the black background behind Guild Bank items."
L["OPTIONS_DESCRIPTION_MAIL_INBOX_BACKGROUND"] = "Hide the persistent Inbox slot placeholder artwork."
