-------------- Original Author: Strawberry --------------
----------------- Discord: exec.noir --------------------
ADDON:ImportObject(OBJECT_TYPE.TEXT_STYLE)
ADDON:ImportObject(OBJECT_TYPE.BUTTON)
ADDON:ImportObject(OBJECT_TYPE.DRAWABLE)
ADDON:ImportObject(OBJECT_TYPE.NINE_PART_DRAWABLE)
ADDON:ImportObject(OBJECT_TYPE.COLOR_DRAWABLE)
ADDON:ImportObject(OBJECT_TYPE.LABEL)
ADDON:ImportObject(OBJECT_TYPE.ICON_DRAWABLE)
ADDON:ImportObject(OBJECT_TYPE.IMAGE_DRAWABLE)

ADDON:ImportAPI(API_TYPE.OPTION.id)
ADDON:ImportAPI(API_TYPE.CHAT.id)

local contentState = 1
local okButton = nil
local toggleButton = nil
local function CreateButton(portalOption)
    if okButton ~= nil then
        return
    end

    okButton = UIParent:CreateWidget("button", "exampleButton", "UIParent", "")
    okButton:SetText("Portal")

    local color = {}
    color.normal    = UIParent:GetFontColor("red")
    color.highlight = UIParent:GetFontColor("red")
    color.pushed    = UIParent:GetFontColor("red")
    color.disabled  = UIParent:GetFontColor("btn_dis")
    if portalOption == 0 then
        color.normal    = UIParent:GetFontColor("green")
        color.highlight = UIParent:GetFontColor("green")
        color.pushed    = UIParent:GetFontColor("green")
        X2Chat:DispatchChatMessage(CMF_SYSTEM, "Using all portals.")
    else
        X2Chat:DispatchChatMessage(CMF_SYSTEM, "Using only your portals.")
    end

    local buttonskin = {
        drawableType = "ninePart",
        path = "ui/common/default.dds",
        coordsKey = "btn",
        autoResize = true,
        fontColor =  color,
        fontInset = {
            left = 11,
            right = 11,
            top = 0,
            bottom = 0,
        },
    }
    ApplyButtonSkin(okButton, buttonskin)
    -- okButton:SetUILayer("game")
    okButton:AddAnchor("BOTTOM", "UIParent", 700, -300)
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
        local portalOption = X2Option:GetOptionItemValue(OPTION_ITEM_USE_ONLY_MY_PORTAL)
        if portalOption == 1 then
            color.normal = UIParent:GetFontColor("green")
            color.highlight = UIParent:GetFontColor("green")
            color.pushed = UIParent:GetFontColor("green")
            X2Chat:DispatchChatMessage(CMF_SYSTEM, "Using ALL portals.")
            X2Option:SetItemFloatValue(OPTION_ITEM_USE_ONLY_MY_PORTAL, 0)
        else
            color.normal = UIParent:GetFontColor("red")
            color.highlight = UIParent:GetFontColor("red")
            color.pushed = UIParent:GetFontColor("red")
            X2Chat:DispatchChatMessage(CMF_SYSTEM, "Using ONLY YOUR portals.")
            X2Option:SetItemFloatValue(OPTION_ITEM_USE_ONLY_MY_PORTAL, 1)
        end
        ApplyButtonSkin(okButton, buttonskin)
    end
    okButton:SetHandler("OnClick", okButton.OnClick)

end

local function EnteredWorld()
    --optional: force to 1 on login
    --X2Option:SetItemFloatValue(OPTION_ITEM_USE_ONLY_MY_PORTAL, 1)
    local portalOption = X2Option:GetOptionItemValue(OPTION_ITEM_USE_ONLY_MY_PORTAL)
    CreateButton(portalOption)
end
UIParent:SetEventHandler(UIEVENT_TYPE.ENTERED_WORLD, EnteredWorld)
