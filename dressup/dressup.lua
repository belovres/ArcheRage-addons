-------------- Original Author: Strawberry --------------
----------------- Discord: exec.noir --------------------
---------------- Thanks to Michaelqt --------------------
ADDON:ImportObject(OBJECT_TYPE.TEXT_STYLE)
ADDON:ImportObject(OBJECT_TYPE.BUTTON)
ADDON:ImportObject(OBJECT_TYPE.DRAWABLE)
ADDON:ImportObject(OBJECT_TYPE.NINE_PART_DRAWABLE)
ADDON:ImportObject(OBJECT_TYPE.COLOR_DRAWABLE)
ADDON:ImportObject(OBJECT_TYPE.WINDOW)
ADDON:ImportObject(OBJECT_TYPE.ICON_DRAWABLE)
ADDON:ImportObject(OBJECT_TYPE.IMAGE_DRAWABLE)
ADDON:ImportObject(OBJECT_TYPE.MODEL_VIEW)

ADDON:ImportAPI(API_TYPE.CHAT.id)
ADDON:ImportAPI(API_TYPE.UNIT.id)
ADDON:ImportAPI(API_TYPE.ITEM.id)

local dressUpModelViewerX = 600
local dressUpModelViewerY = 800
local dressUpWindow = CreateEmptyWindow("dressUpWindow", "UIParent")
      dressUpWindow:AddAnchor("RIGHT", -920,0)
local turnLeft = false
local turnRight = false
local zoomOutBool = false
local zoomInBool = false
local fov = 30

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
function dressUpWindow:OnUpdate(dt)
    local modelViewer = dressUpWindow.modelViewer
    if turnLeft == true then 
        modelViewer:AddRotation(200 * dt / 1000)
    elseif turnRight == true then 
        modelViewer:AddRotation(-200 * dt / 1000)
      elseif zoomInBool == true then
          modelViewer:SetFov(fov)
          fov = fov - 0.3
      elseif zoomOutBool == true then
          modelViewer:SetFov(fov)
          fov = fov + 0.3
    end 
end 

local controlBarYOffset = 0
local modelViewer = nil
      modelViewer = dressUpWindow:CreateChildWidget("modelview", "modelViewer", 0, true)
local background = modelViewer:CreateColorDrawable(0, 0, 0, 0.1, "background")
      background:AddAnchor("TOPLEFT", modelViewer, 0, 0)
      background:AddAnchor("BOTTOMRIGHT", modelViewer, 0, 0)
local rotateRight = modelViewer:CreateChildWidget("button", "rotateRight", 0, true)
      rotateRight:AddAnchor("LEFT", modelViewer, 5, controlBarYOffset)
      ApplyButtonSkin(rotateRight, buttonskin)
      rotateRight:SetExtent(35,35)
      rotateRight:SetText("L")
      function rotateRight:OnMouseDown(arg)
          turnRight = true
      end
      rotateRight:SetHandler("OnMouseDown", rotateRight.OnMouseDown)
      function rotateRight:OnMouseUp(arg)
          turnRight = false
      end
      rotateRight:SetHandler("OnMouseUp", rotateRight.OnMouseUp)
      function rotateRight:OnLeave(arg)
          turnRight = false
      end
      rotateRight:SetHandler("OnLeave", rotateRight.OnLeave)
local rotateLeft = modelViewer:CreateChildWidget("button", "rotateLeft", 0, true)
      rotateLeft:AddAnchor("RIGHT", modelViewer, -5, controlBarYOffset)
      ApplyButtonSkin(rotateLeft, buttonskin)
      rotateLeft:SetExtent(35,35)
      rotateLeft:SetText("R")
      function rotateLeft:OnMouseDown(arg)
          turnLeft = true
      end
      rotateLeft:SetHandler("OnMouseDown", rotateLeft.OnMouseDown)
      function rotateLeft:OnMouseUp(arg)
          turnLeft = false
      end
      rotateLeft:SetHandler("OnMouseUp", rotateLeft.OnMouseUp)
      function rotateLeft:OnLeave(arg)
          turnLeft = false
      end
      rotateLeft:SetHandler("OnLeave", rotateLeft.OnLeave)
local ZoomInButt = modelViewer:CreateChildWidget("button", "ZoomInButt", 0, true)
      ZoomInButt:AddAnchor("LEFT", modelViewer, 5, controlBarYOffset - 170)
      ApplyButtonSkin(ZoomInButt, buttonskin)
      ZoomInButt:SetExtent(35,35)
      ZoomInButt:SetText("+")
      function ZoomInButt:OnMouseDown(arg)
          zoomInBool = true
      end
      ZoomInButt:SetHandler("OnMouseDown", ZoomInButt.OnMouseDown)
      function ZoomInButt:OnMouseUp(arg)
          zoomInBool = false
      end
      ZoomInButt:SetHandler("OnMouseUp", ZoomInButt.OnMouseUp)
      function ZoomInButt:OnLeave(arg)
          zoomInBool = false
      end
      ZoomInButt:SetHandler("OnLeave", ZoomInButt.OnLeave)
local ZoomOutButt = modelViewer:CreateChildWidget("button", "ZoomOutButt", 0, true)
      ZoomOutButt:AddAnchor("LEFT", modelViewer, 5, controlBarYOffset - 135)
      ApplyButtonSkin(ZoomOutButt, buttonskin)
      ZoomOutButt:SetExtent(35,35)
      ZoomOutButt:SetText("-")
      function ZoomOutButt:OnMouseDown(arg)
          zoomOutBool = true
      end
      ZoomOutButt:SetHandler("OnMouseDown", ZoomOutButt.OnMouseDown)
      function ZoomOutButt:OnMouseUp(arg)
          zoomOutBool = false
      end
      ZoomOutButt:SetHandler("OnMouseUp", ZoomOutButt.OnMouseUp)
      function ZoomOutButt:OnLeave(arg)
          zoomOutBool = false
      end
      ZoomOutButt:SetHandler("OnLeave", ZoomOutButt.OnLeave)
local closeViewer = modelViewer:CreateChildWidget("button", "rotateLeft", 0, true)
      closeViewer:AddAnchor("TOPRIGHT", modelViewer, -5, controlBarYOffset)
      ApplyButtonSkin(closeViewer, buttonskin)
      closeViewer:SetExtent(35,35)
      closeViewer:SetText("X")
      function closeViewer:OnClick(arg)
          dressUpWindow:Show(false)
      end
      closeViewer:SetHandler("OnClick", closeViewer.OnClick)



local RELAX_ANIMATION_NAME = "fist_ba_relaxed_rand_idle"

local function IniitalizeDressup()
    modelViewer:SetExtent(dressUpModelViewerX, dressUpModelViewerY)
    modelViewer:SetTextureSize(512, 512)
    local width = dressUpModelViewerX * 512 / dressUpModelViewerY
    modelViewer:SetModelViewExtent(width, 512)
    modelViewer:SetModelViewCoords((512 - width) / 2, 0, width, 512)
    modelViewer:AddAnchor("LEFT", dressUpWindow, 5, 20)
    modelViewer:AdjustCameraPos(0, 0, 0)
    dressUpWindow:Show(false)
end

IniitalizeDressup()

---------- Chat listener -----------
local chatAggroEventListenerEvents = {
    CHAT_MESSAGE = function(channel, relation, name, message, info)
        if name == X2Unit:UnitName("player") then
            local firstWord = string.match(message, "/%w+")
            local secondWord = string.match(message, "/[%w_]+%s+([^%s]+)")
            if firstWord == "/dressup" then
                dressUpWindow:Show(true)
                modelViewer:Init("player", true)
                modelViewer:PlayAnimation(RELAX_ANIMATION_NAME, true)
            elseif firstWord == "/closedressup" then
                dressUpWindow:Show(false)
            elseif firstWord == "/animate" then
                if secondWord ~= nil then
                    X2Chat:DispatchChatMessage(CMF_SYSTEM, tostring(secondWord))
                    modelViewer:Init("player", true)
                    modelViewer:PlayAnimation(tostring(secondWord), true)
                else
                    X2Chat:DispatchChatMessage(CMF_SYSTEM, "/animate <animationname>")
                end
            elseif firstWord == "/equipbase" then
                if secondWord ~= nil then
                    local equipThisItem = secondWord
                    if secondWord:sub(1,1) == "|" then
                      equipThisItem = secondWord:match("i(%d+),")
                    end
                    dressUpWindow:Show(true)
                    modelViewer:Init("player", true)
                    modelViewer:EquipItem(tonumber(equipThisItem))
                    modelViewer:PlayAnimation(RELAX_ANIMATION_NAME, true)
                else
                    X2Chat:DispatchChatMessage(CMF_SYSTEM, "/equipbase <itemid>")
                end
            elseif firstWord == "/equip" then
                if secondWord ~= nil then
                    local linkText = secondWord:match(".*,([^,;]+);")
                    local itemInfo = X2Item:InfoFromLink(linkText, "auction")
                    local alembicSkin = itemInfo.lookType
                    dressUpWindow:Show(true)
                    modelViewer:Init("player", true)
                    modelViewer:EquipItem(tonumber(alembicSkin))
                    modelViewer:PlayAnimation(RELAX_ANIMATION_NAME, true)
                else
                    X2Chat:DispatchChatMessage(CMF_SYSTEM, "/equip <itemid>")
                end
            end
        end
    end
}

--make chat listener
local chatEventListenerAggro = CreateEmptyWindow("chatEventListenerAggro", "UIParent")
chatEventListenerAggro:Show(false)
chatEventListenerAggro:SetHandler("OnEvent", function(this, event, ...)
  chatAggroEventListenerEvents[event](...)
end)
local RegistUIEvent = function(window, eventTable)
  for key, _ in pairs(eventTable) do
    window:RegisterEvent(key)
  end
end
RegistUIEvent(chatEventListenerAggro, chatAggroEventListenerEvents)

dressUpWindow:SetHandler("OnUpdate", dressUpWindow.OnUpdate)