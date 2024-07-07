--
-- Masque Blizzard Inventory
--
-- Locales\zhCN.lua -- zhCN Localization File
--
-- Use of this source code is governed by an MIT-style
-- license that can be found in the LICENSE file or at
-- https://opensource.org/licenses/MIT.
--

-- Please use CurseForge to submit localization content for another language:
-- https://www.curseforge.com/wow/addons/masque-blizz-inventory/localization

local Locale = GetLocale()
if Locale ~= "zhCN" then return end

local _, Shared = ...
local L = Shared.Locale

L["Backpack"] = "背包"
L["Bag Bar"] = "背包条"
L["Bags"] = "袋子"
L["Bank"] = "银行"
L["Bank Bags"] = "银行袋"
L["Character"] = "字符"
L["Equipment Flyouts"] = "装备弹出按钮"
L["Equipment Manager"] = "装备管理"
L["Guild Bank"] = "公会银行"
L["Hide Background"] = "隐藏背景"
L["Hide Inbox Background"] = "隐藏收件箱背景"
L["Hide Inbox Slots"] = "隐藏收件箱插槽"
L["Hide Send Mail Attachment Slots"] = "隐藏发送邮件附件插槽"
L["Hide Slots"] = "隐藏插槽"
L["Inspect Character"] = "检查字符"
L["Loot"] = "拾取"
L["Mail"] = "邮件"
L["Main Bags"] = "主背包"
L["Merchants"] = "商人"
L["Reagent Bag"] = "试剂袋"
L["Reagent Bank"] = "试剂库"
L["Void Storage"] = "无效存储"

L["NOTES_BAGS_CLASSIC"] = "该组为背包、钥匙圈、主袋和银行袋设计皮肤。"
L["NOTES_MAIL"] = "此组设置“收件箱”、“发送邮件”和“打开邮件”附件的外观。"
L["NOTES_MAIN_BAGS"] = "该组为除背包和试剂包以外的主要袋子换皮。"
L["OPTIONS_DESCRIPTION_GUILDBANK_BACKGROUND"] = "隐藏公会银行物品后面的黑色背景。"
L["OPTIONS_DESCRIPTION_MAIL_INBOX_BACKGROUND"] = "隐藏永久收件箱槽占位符图稿。"
L["OPTIONS_DESCRIPTION_MAIN"] = "这些选项允许您自定义库存元素，使其与某些Masque皮肤搭配时看起来更好，例如隐藏背景艺术品。"
L["OPTIONS_DESCRIPTION_SLOTS"] = "将插槽隐藏在物品后面。"
L["OPTIONS_TITLE_MAIN"] = "%s扩展选项"
