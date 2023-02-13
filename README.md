# About Masque Blizzard Inventory

This addon enables [Masque](https://github.com/SFX-WoW/Masque) ([CurseForge](https://www.curseforge.com/wow/addons/masque), [Wago](https://addons.wago.io/addons/masque), [WoWInterface](https://www.wowinterface.com/downloads/info12097-Masque.html)) to skin built-in WoW inventory elements.  An up-to-date version of Masque is required for it to work.

If you like the base WoW interface and don't want to use a separate bag or inventory mod, you're in the right place.

You can install this addon from [CurseForge](https://www.curseforge.com/wow/addons/masque-blizz-inventory "CurseForge"), [Wago](https://addons.wago.io/addons/masqueblizzinv), or [WoWInterface](https://www.wowinterface.com/downloads/info26503-MasqueBlizzardInventory.html).

## Features

Masque Blizzard Inventory can currently skin the following elements:

* Backpack
* Main Bags
* Combined Backpack
* Reagent Bag
* Keyring (Classic only)
* Bank
* Bank Bags
* Reagent Bank
* Guild Bank
* Void Storage
* Mail

Each element type is its own group so you can configure them independently from Masque's Skin Settings.  The Combined Backpack will inherit the Backpack and Main Bags configuration.

An additional options panel is provided to hide background and slot artwork that might clash with certain Masque skins.

## Classic Support

Classic is missing many features from Retail, so unsupported groups will not appear in Masque options.  Currently, only the following elements are supported by the game:

* Bags (including Keyring)
* Bank
* Mail
* Guild Bank (Wrath Classic only)

In Classic, all bags are consolidated to a single Bags group, including the Keyring.  This is due to the way the game reuses Bag windows.

Most interface frames in Classic are built using a single background image, rather than multiple layers, so the options to hide background and slot artwork are not feasible.  Adding this feature would require drawing replacement artwork and including it with the addon, so it is not planned.

I've done limited testing with Classic Era and Wrath Classic because I don't play them, but I believe everything should work.  If you report bugs or submit patches, I'll do my best to address them.

## Compatibility

This addon is not intended to apply Masque skins over addons that replace or heavily modify parts of the base interface and may conflict with them.  If you experience a conflict, use Masque's Skin Settings to disable the affected group and reload your UI. This should allow the other addon to control the interface without interference.

If you'd like to see Masque support in a conflicting addon, try sending a feature request to that addon's author directly.

## Localization

If you'd like to help localize this addon, please submit translations [here](https://www.curseforge.com/wow/addons/masque-blizz-inventory/localization).

## Other Mods

If you're looking to skin the built-in action bars as well, check out [Masque Blizzard Bars](/kstange/MasqueBlizzBars) ([CurseForge](https://www.curseforge.com/wow/addons/masque-blizz-bars-revived "CurseForge"), [Wago](https://addons.wago.io/addons/masqueblizzbars), [WoWInterface](https://www.wowinterface.com/downloads/info26502-MasqueBlizzardBars.html))!
