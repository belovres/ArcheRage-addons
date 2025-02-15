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

function checkClasses()
    local classCounts = {}
    local bannedPlayers = {}
    local bannedClasses = { "Blade Dancer", "Fanatic" }
    local hasCoRaid = false
    local amountOfRaids = 1
    if X2Unit:UnitName("team_1_1") == nil and X2Unit:UnitName("team1") == nil then
        X2Chat:DispatchChatMessage(CMF_SYSTEM, "Not in a raid.")
        amountOfRaids = 0
    end
    if X2Unit:UnitName("team_1_1") ~= nil then
        amountOfRaids = 2
        hasCoRaid = true
    end
    for team = 1, amountOfRaids do
        for member = 1, 50 do
            local teamId = ""
            if hasCoRaid then
                teamId = string.format("team_%02d_%02d", team, member)
            else
                teamId = string.format("team%02d", member)
            end
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

                        for _, bannedClass in ipairs(bannedClasses) do
                            if name == bannedClass then
                                table.insert(bannedPlayers, string.format("%s(%s)", playerName, name))
                            end
                        end
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
        if entry.count >= 3 then
            tallyMessage = tallyMessage .. string.format("You have %d of class %s\n", entry.count, entry.name)
        else
            table.insert(soloClasses, entry.name)
        end
    end

    local lessThanFourClasses = {}
    for _, entry in ipairs(classArray) do
        if entry.count < 3 then
            table.insert(lessThanFourClasses, string.format("%s (%d)", entry.name, entry.count))
        end
    end

    X2Chat:DispatchChatMessage(CMF_SYSTEM, tallyMessage)

    if #lessThanFourClasses > 0 then
        local lessThanFourMessage = "You have less than 3 of the following: " .. table.concat(lessThanFourClasses, ", ")
        X2Chat:DispatchChatMessage(CMF_SYSTEM, lessThanFourMessage)
    end



    --if #soloClasses > 0 then
    --    local soloMessage = "You have one of the following: " .. table.concat(soloClasses, ", ")
    --    X2Chat:DispatchChatMessage(CMF_SYSTEM, soloMessage)
    --end

    if #bannedPlayers > 0 then
        local bannedMessage = "The following people are playing banned classes: " .. table.concat(bannedPlayers, ", ")
        X2Chat:DispatchChatMessage(CMF_SYSTEM, bannedMessage)
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
    okButton:AddAnchor("BOTTOM", "UIParent", 700, -260)
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

CreateButton()