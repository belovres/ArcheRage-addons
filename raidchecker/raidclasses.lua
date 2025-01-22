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

ADDON:ImportAPI(API_TYPE.CHAT.id)
ADDON:ImportAPI(API_TYPE.UNIT.id)
ADDON:ImportAPI(API_TYPE.LOCALE.id)

--i'm sure these namemappings will be useful at some point
--maybe put them in global?
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

function checkClasses()
    local classCounts = {}
    for team = 1, 2 do
        for member = 1, 50 do
            local teamId = string.format("team_%02d_%02d", team, member)
            local playerName = X2Unit:UnitName(teamId)
            local templates = X2Unit:GetTargetAbilityTemplates(teamId)

            if templates and templates[1] and templates[2] and templates[3] then
                local indices = {
                    templates[1].index,
                    templates[2].index,
                    templates[3].index
                }
                table.sort(indices)

                local keyStr = string.format("name_%d_%d_%d", indices[1], indices[2], indices[3])
                local name = ""
                if keyStr ~= "name_30_30_30" then
                    name = X2Locale:LocalizeUiText(COMBINED_ABILITY_NAME_TEXT, keyStr, "")
                    if name ~= nil and name ~= "" then
                        classCounts[name] = (classCounts[name] or 0) + 1
                    end
                end
            end
        end
    end
    local classArray = {}
    for className, count in pairs(classCounts) do
        table.insert(classArray, {name = className, count = count})
    end

    table.sort(classArray, function(a, b)
        return a.count > b.count
    end)
    local soloClasses = {}
    local tallyMessage = "Class distribution:\n"

    for _, entry in ipairs(classArray) do
        if entry.count > 1 then
            tallyMessage = tallyMessage .. string.format("You have %d of class %s\n", entry.count, entry.name)
        else
            table.insert(soloClasses, entry.name)
        end
    end
    X2Chat:DispatchChatMessage(CMF_SYSTEM, tallyMessage)
    if #soloClasses > 0 then
        local soloMessage = "You have one of the following: " .. table.concat(soloClasses, ", ")
        X2Chat:DispatchChatMessage(CMF_SYSTEM, soloMessage)
    end
end


local okButton = nil
local toggleButton = nil
local exampleWindow = nil
local function CreateButton()
    if okButton ~= nil then
        return
    end

    okButton = UIParent:CreateWidget("button", "exampleButton", "UIParent", "")
    okButton:SetText("Class Check")

    local color = {}
    color.normal    = UIParent:GetFontColor("btn_df")
    color.highlight = UIParent:GetFontColor("btn_ov")
    color.pushed    = UIParent:GetFontColor("btn_on")
    color.disabled  = UIParent:GetFontColor("btn_dis")

    local buttonskin = {
        drawableType = "ninePart",
        path = "ui/common/default.dds",
        coordsKey = "btn",
        autoResize = true,
        fontColor = color,
        fontInset = {
            left = 11,
            right = 11,
            top = 0,
            bottom = 0,
        },
    }
    ApplyButtonSkin(okButton, buttonskin)
    -- okButton:SetUILayer("game")
    okButton:AddAnchor("BOTTOM", "UIParent", 700, -100)
    okButton:Show(true)
    okButton:EnableDrag(true)

    function okButton:OnDragStart()
        self:StartMoving()
        self.moving = true
    end
    okButton:SetHandler("OnDragStart", okButton.OnDragStart)

    function okButton:OnDragStop()
        self:StopMovingOrSizing()
        self.moving = false
    end
    okButton:SetHandler("OnDragStop", okButton.OnDragStop)

    function okButton:OnClick()
            checkClasses()
    end
    okButton:SetHandler("OnClick", okButton.OnClick)

end

local function EnteredWorld()
    CreateButton()
end
UIParent:SetEventHandler(UIEVENT_TYPE.ENTERED_WORLD, EnteredWorld)
