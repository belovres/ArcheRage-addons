-------------- Original Author: Strawberry --------------
----------------- Discord: exec_noir --------------------
ADDON:ImportObject(OBJECT_TYPE.TEXT_STYLE)
ADDON:ImportObject(OBJECT_TYPE.WINDOW)
ADDON:ImportObject(OBJECT_TYPE.LABEL)

ADDON:ImportAPI(API_TYPE.CHAT.id)

-- create an empty window that forces continuous updates
local refreshForcer = CreateEmptyWindow("refreshForcer", "UIParent")
refreshForcer:Show(true)
------------------------ Function called perpetually ------------------------
local path = "../Documents/Addon/translate/ChatTranslationOutput_1.log"
local lastPrintedLine = nil

--basically just constantly refresh and act like tail functionality on linux
function refreshForcer:OnUpdate(dt)
    local file = io.open(path, "r")
    local lastLine
    for line in file:lines() do
        lastLine = line
    end
    file:close()

    if lastLine and lastLine ~= lastPrintedLine then
        --don't print bugged lines
        if lastLine:match("00000") then
            lastPrintedLine = lastLine
            return
        end
        local outputLine = lastLine:gsub(" ", "", 1)
        X2Chat:DispatchChatMessage(CMF_SYSTEM, outputLine)
        lastPrintedLine = lastLine
    end
end

--force continuous updates
refreshForcer:SetHandler("OnUpdate", refreshForcer.OnUpdate)
--X2Chat:DispatchChatMessage(CMF_SYSTEM, string.format("lua logging"))
