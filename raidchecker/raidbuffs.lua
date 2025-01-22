--todo
--statue (red, blue | nuia haranya pirate)
--drum, goblet, food (max rank, table rank, max-1 rank), resi/toughness book
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

--https://wiki.archerage.to/ru-en/search/q is your friend
local buffsToCheck = {
    drum = {5700},
    statue = {30768, 30765, 1, 1, 1, 1},
    book = {20552, 21795},
    ribs = {685, 597, 689, 693, 21791, 21792, 21793, 21794},
    goblet = {7685, 21796, 21801, 21806, 21811, 21819, 21846, 7686, 21797, 21802, 21807, 21812, 21820, 7687, 21798, 21803, 21808, 21813, 21821, 7688, 21799, 21804, 21809, 21814, 21822, 7689, 21800, 21805, 21810, 21815, 21823, 24469, 24470, 24471, 24472, 24473, 24474}
}

function checkBuffs()
    local missingByBuff = {}
    for category in pairs(buffsToCheck) do
        missingByBuff[category] = {}
    end
    for team = 1, 2 do
        for member = 1, 50 do
            local teamId = string.format("team_%02d_%02d", team, member)
            local playerName = X2Unit:UnitName(teamId)
            if playerName then
                local UBuffCount = X2Unit:UnitBuffCount(teamId)
                local hasBuff = {}
                for category in pairs(buffsToCheck) do
                    hasBuff[category] = false
                end
                for i = 1, UBuffCount do
                    local buffExtra = X2Unit:UnitBuff("target", i)
                    local buffId = tonumber(buffExtra["buff_id"])
                    for category, ids in pairs(buffsToCheck) do
                        for _, id in ipairs(ids) do
                            if id == buffId then
                                hasBuff[category] = true
                                break
                            end
                        end
                    end
                end
                for category, present in pairs(hasBuff) do
                    if not present then
                        table.insert(missingByBuff[category], playerName)
                    end
                end
            end
        end
    end
    for category, missingList in pairs(missingByBuff) do
        if #missingList > 0 then
            local message = string.format("The following people are missing the %s buff: %s", category, table.concat(missingList, ", "))
            X2Chat:DispatchChatMessage(CMF_SYSTEM, message)
        end
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
    okButton:SetText("Buff Check")

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
            checkBuffs()
    end
    okButton:SetHandler("OnClick", okButton.OnClick)

end

local function EnteredWorld()
    CreateButton()
end
UIParent:SetEventHandler(UIEVENT_TYPE.ENTERED_WORLD, EnteredWorld)
