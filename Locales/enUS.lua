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

local Locale = GetLocale()
if Locale ~= "enUS" then return end

local _, Shared = ...
local L = Shared.Locale

-- These all reference the names of containers in game. Try to label them the way Blizzard refers to them.
L["Backpack"] = "Backpack"
L["This group skins the Backpack.  If you have enabled the Combined Backpack, it will only skin the slots from the real Backpack and not other bags."] = "This group skins the Backpack.  If you have enabled the Combined Backpack, it will only skin the slots from the real Backpack and not other bags."
L["Main Bags"] = "Main Bags"
L["This group skins the main Bags other than the Backpack and Reagent Bag.  If you have enabled the Combined Backpack, it will only skin the slots from those bags and not the Backpack."] = "This group skins the main Bags other than the Backpack and Reagent Bag.  If you have enabled the Combined Backpack, it will only skin the slots from those bags and not the Backpack."
L["Reagent Bag"] = "Reagent Bag"
L["Bank Bags"] = "Bank Bags"
L["Bank"] = "Bank"
L["Reagent Bank"] = "Reagent Bank"
L["Guild Bank"] = "Guild Bank"
L["Void Storage"] = "Void Storage"
L["Mail"] = "Mail"
L["This group skins the Inbox, Send Mail, and Open Mail attachment icons."] = "This group skins the Inbox, Send Mail, and Open Mail attachment icons."

