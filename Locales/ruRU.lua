--
-- Masque Blizzard Inventory
--
-- Locales\ruRU.lua -- ruRU Localization File
--
-- Use of this source code is governed by an MIT-style
-- license that can be found in the LICENSE file or at
-- https://opensource.org/licenses/MIT.
--

-- Please use CurseForge to submit localization content for another language:
-- https://www.curseforge.com/wow/addons/masque-blizz-inventory/localization

-- luacheck: no max line length

local Locale = GetLocale()
if Locale ~= "ruRU" then return end

local _, Shared = ...
local L = Shared.Locale

L["Backpack"] = "Рюкзак"
L["Bag Bar"] = "Панель сумки"
L["Bags"] = "Сумки"
L["Bank"] = "Банк"
L["Bank Bags"] = "Сумки Банка"
L["Character"] = "Персонаж"
L["Combined Backpack"] = "Комбинированный рюкзак"
L["Equipment Flyouts"] = "Всплывающие окна с экипировкой"
L["Equipment Manager"] = "Менеджер по экипировке"
L["Guild Bank"] = "Банк Гильдии"
L["Hide Background"] = "Скрыть фон"
L["Hide Inbox Background"] = "Скрыть фон почтового ящика"
L["Hide Inbox Slots"] = "Скрыть ячейки для входящих сообщений"
L["Hide Send Mail Attachment Slots"] = "Скрыть слоты для вложений в письмах"
L["Hide Slots"] = "Скрыть слоты"
L["Inspect Character"] = "Осмотреть персонажа"
L["Loot"] = "Добыча"
L["Mail"] = "Почта"
L["Main Bags"] = "Основные сумки"
L["Merchants"] = "Торговцы"
L["Reagent Bag"] = "Сумка с реагентами"
L["Reagent Bank"] = "Банк реагентов"
L["Void Storage"] = "Хранилище Бездны"
L["Warband Bank"] = "Банк отряда"

L["NOTES_BAGS_CLASSIC"] = "Эта группа занимается скинами для рюкзака, брелока для ключей, основных и банковских сумок."
L["NOTES_MAIL"] = "Эта группа создает скины для вложений в папки «Входящие», «Отправить письмо» и «Открыть письмо»."
L["NOTES_MAIN_BAGS"] = "Эта группа занимается обработкой основных сумок, кроме рюкзака и сумки для реагентов."
L["OPTIONS_DESCRIPTION_GUILDBANK_BACKGROUND"] = "Скройте черный фон за предметами Банка гильдии."
L["OPTIONS_DESCRIPTION_MAIL_INBOX_BACKGROUND"] = "Скрыть графическое изображение-заполнитель ячейки для постоянных входящих сообщений."
L["OPTIONS_DESCRIPTION_MAIN"] = "Эти опции позволяют настраивать элементы инвентаря таким образом, чтобы они лучше смотрелись с определенными скинами Masque, например, скрывая фоновые рисунки."
L["OPTIONS_DESCRIPTION_SLOTS"] = "Скройте изображение слота за предметами."
L["OPTIONS_TITLE_MAIN"] = "%s Расширенные параметры"
