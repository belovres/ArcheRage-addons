-------------- Original Author: Strawberry --------------
----------------- Discord: exec_noir --------------------
ADDON:ImportObject(OBJECT_TYPE.TEXT_STYLE)
ADDON:ImportObject(OBJECT_TYPE.BUTTON)
ADDON:ImportObject(OBJECT_TYPE.DRAWABLE)
ADDON:ImportObject(OBJECT_TYPE.NINE_PART_DRAWABLE)
ADDON:ImportObject(OBJECT_TYPE.COLOR_DRAWABLE)
ADDON:ImportObject(OBJECT_TYPE.WINDOW)
ADDON:ImportObject(OBJECT_TYPE.LABEL)
ADDON:ImportObject(OBJECT_TYPE.ICON_DRAWABLE)
ADDON:ImportObject(OBJECT_TYPE.IMAGE_DRAWABLE)

ADDON:ImportAPI(API_TYPE.OPTION.id)
ADDON:ImportAPI(API_TYPE.CHAT.id)
ADDON:ImportAPI(API_TYPE.ACHIEVEMENT.id)
ADDON:ImportAPI(API_TYPE.UNIT.id)
ADDON:ImportAPI(API_TYPE.LOCALE.id)

-- Create a basic invisible window to attach icons to
local buffAnchor = CreateEmptyWindow("buffAnchor", "UIParent")
buffAnchor:Show(true)

local target_buffs = {}
local target_buffDebugMessages = false
local showAllBuffs = false

local buffAllString = ""
local lastBuffString = ""

local drawableNmyIcons = {}
local drawableNmyLabels = {} 
-- helper function for array dumping --
local function dump(o)
 if type(o) == 'table' then
  local s = '{ '
  for k,v in pairs(o) do
    if type(k) ~= 'number' then k = '"'..k..'"' end
    s = s .. '['..k..'] = ' .. dump(v) .. ','
  end
  return s .. '} '
 else
  return tostring(o)
 end
end

local drawableIcons = {}

local roleIcons = {
    Tank = "ui/icon/icon_skill_adamant15.dds",
    Songer = "ui/icon/icon_skill_romance15.dds",
    Melee = "ui/icon/icon_skill_fight37.dds",
    Archer = "ui/icon/icon_skill_wild35.dds",
    Mage = "ui/icon/icon_skill_magic40.dds",
    Gunner = "ui/icon/icon_skill_madness07.dds",
    Malediction = "ui/icon/icon_skill_hatred25.dds",
    Dancer = "ui/icon/icon_skill_pleasure02.dds",
    Swiftblade = "ui/icon/icon_skill_assassin43.dds",
    Healer = "ui/icon/icon_skill_love01.dds",
    unknown = "ui/icon/top_question_mark.dds",
    npc = ""
}

local function initializeIcons(w)
    for role, iconPath in pairs(roleIcons) do
        local drawableIcon = w:CreateIconDrawable("artwork")
        drawableIcon:SetExtent(35, 35)
        drawableIcon:AddAnchor("LEFT", w, 0, 0) 
        drawableIcon:ClearAllTextures()
        drawableIcon:AddTexture(iconPath)
        drawableIcon:SetVisible(false)
        drawableIcons[role] = drawableIcon
    end
end

local function setRoleIconVisible(role)
    for key, icon in pairs(drawableIcons) do
        if key == role then
            icon:SetVisible(true)
        else
            icon:SetVisible(false)
        end
    end
end
initializeIcons(buffAnchor)

local nameMappings = {
    ["name_3_4_5"] = "Tank", -- Skullknight
    ["name_2_3_4"] = "Tank", -- Dreambreaker
    ["name_1_5_8"] = "Melee", -- Executioner
    ["name_1_3_5"] = "Melee", -- Doomlord
    ["name_1_8_9"] = "Melee", -- Blade Dancer
    ["name_1_3_4"] = "Melee", -- Abolisher
    ["name_1_4_8"] = "Melee", -- Darkrunner
    ["name_1_4_9"] = "Melee", -- Herald
    ["name_1_8_12"] = "Swiftblade", -- Deathwish
    ["name_1_5_12"] = "Swiftblade", -- Deathwish
    ["name_7_8_11"] = "Malediction", -- Fanatic
    ["name_7_9_11"] = "Malediction", -- Spectre
    ["name_7_8_9"] = "Mage", -- I forgot
    ["name_4_7_8"] = "Mage", -- Enigmatist
    ["name_3_4_7"] = "Mage", -- Thaumaturge
    ["name_2_7_8"] = "Mage", -- Daggerspell
    ["name_6_8_9"] = "Archer", -- Ebonsong
    ["name_6_9_10"] = "Archer", -- Soulsong
    ["name_2_6_9"] = "Archer", -- Hex Ranger
    ["name_6_8_13"] = "Gunner", -- Deathtrigger
    ["name_4_8_13"] = "Gunner", -- Bounty Hunter
    ["name_5_6_13"] = "Gunner", -- Banebolt
    ["name_8_9_13"] = "Gunner", -- Privateer
    ["name_4_9_13"] = "Gunner", -- Minstrel
    ["name_3_4_9"] = "Songer", -- Tomb Warden
    ["name_9_10_14"] = "Dancer", -- Glamorous Savior
    ["name_8_10_14"] = "Dancer", -- Darkness Savior
    ["name_2_10_14"] = "Dancer", -- Fear Savior
    ["name_8_9_14"] = "Dancer", -- Bloody Dancer
    ["name_2_8_10"] = "Healer", -- Assassin
    ["name_4_8_10"] = "Healer", -- Soothsayer
    ["name_2_9_10"] = "Healer", -- Athame
    ["name_8_9_10"] = "Healer", -- Confessor
    ["name_3_9_10"] = "Healer",-- Caretaker
    ["name_2_4_10"] = "Healer"-- Hierophant
}

local function hideNonMatchingIcons(currentClassName)
    for className, drawableIcon in pairs(drawableIcons) do
        if className ~= currentClassName then
            drawableIcon:SetVisible(false)
        end
    end
end

local function drawIcon(w, iconPath, id, xOffset, yOffset, className, actualClassName)
    hideNonMatchingIcons(className)
    if drawableNmyLabels[id] ~= nil then
        if not drawableIcons[className]:IsVisible() then
            drawableIcons[className]:SetVisible(true)
            drawableNmyLabels[id]:Show(true)
        end
        drawableNmyLabels[id]:SetText(actualClassName)
        drawableIcons[className]:AddAnchor("LEFT", w, xOffset, yOffset) 
        drawableNmyLabels[id]:AddAnchor("LEFT", w, xOffset, yOffset+20) 
        return
    end
    drawableIcons[className]:SetVisible(true)
    local lblDuration = w:CreateChildWidget("label", "lblDuration", 0, true)
    lblDuration:Show(true)
    lblDuration:EnablePick(false)
    lblDuration.style:SetColor(1, 1, 1, 1.0)
    lblDuration.style:SetOutline(true)
    lblDuration.style:SetAlign(ALIGN_LEFT)
    lblDuration:AddAnchor("LEFT",w,xOffset,yOffset+20)
    lblDuration:SetText(actualClassName)
    drawableNmyLabels[id] = lblDuration
    --drawableNmyIcons[id] = drawableIcon
end

function buffAnchor:OnUpdate(dt)
    local nScrX_Tar, nScrY_Tar, nScrZ_Tar = X2Unit:GetUnitScreenPosition("target")
    if nScrX_Tar == nil or nScrY_Tar == nil or nScrZ_Tar == nil then
        buffAnchor:AddAnchor("TOPLEFT", "UIParent", 5000, 5000) 
    elseif nScrZ_Tar > 0 then
        local x = math.floor(0.5+nScrX_Tar)
        local y = math.floor(0.5+nScrY_Tar)
        buffAnchor:Show(true)
        buffAnchor:Enable(true)
        buffAnchor:AddAnchor("TOPLEFT", "UIParent", x+40, y+10)

        local templates = X2Unit:GetTargetAbilityTemplates("target")
		local indices = {
		  templates[1].index,
		  templates[2].index,
		  templates[3].index
		}
		table.sort(indices)
		local keyStr = string.format("name_%d_%d_%d", indices[1], indices[2], indices[3])
		--X2Chat:DispatchChatMessage(CMF_SYSTEM, keyStr)
		fakeClassName = nameMappings[keyStr] or "unknown"
		local name = X2Locale:LocalizeUiText(COMBINED_ABILITY_NAME_TEXT, keyStr, "")
		if name == nil then
		  name = GetUIText(COMBINED_ABILITY_NAME_TEXT, "name_9_9_9")
		end
        local actualClassName = name
        if keyStr ~= "name_30_30_30" then
        	--drawableNmyLabels[1]:Show(true)
            drawIcon(buffAnchor, iconPath, 1, 0, 0, fakeClassName, actualClassName)
        else
        	drawableNmyLabels[1]:Show(false)
	        hideNonMatchingIcons("npc")
	        --drawableNmyIcons[1]:SetVisible(false)
        end
    end
end

buffAnchor:SetHandler("OnUpdate", buffAnchor.OnUpdate)