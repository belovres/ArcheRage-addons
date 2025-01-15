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
ADDON:ImportAPI(API_TYPE.RESIDENT.id)

local okButton = nil
local toggleButton = nil
local exampleWindow = nil
local function CreateButton()
    if okButton ~= nil then
        return
    end

    okButton = UIParent:CreateWidget("button", "exampleButton", "UIParent", "")
    okButton:SetText("Board")

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
    okButton:AddAnchor("BOTTOM", "UIParent", 700, -180)
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
        local contents = ""
        local materials = {"Fabric", "Leather", "Lumber", "Iron Ingots"}
        local boardLocator = X2Resident:GetResidentBoardContent(1)
        X2Chat:DispatchChatMessage(CMF_SYSTEM, "---- Bonds for: " .. boardLocator.faction .. " -----")
        for index = 1, 4 do
            local contentA = X2Resident:GetResidentBoardContent(index)
            local contents = ""
            for i = 1, #contentA.contents do
                if contents == "" then
                    contents = contentA.contents[i]
                else
                    contents = contents .. "\n" .. contentA.contents[i] -- Add newline between entries
                end
            end
            X2Chat:DispatchChatMessage(CMF_SYSTEM, "-- " ..materials[index] .. " --\n")
            X2Chat:DispatchChatMessage(CMF_SYSTEM, contents .. "\n")
        end
        X2Chat:DispatchChatMessage(CMF_SYSTEM, "-------------------------------")
    end
    okButton:SetHandler("OnClick", okButton.OnClick)

end
CreateButton()
