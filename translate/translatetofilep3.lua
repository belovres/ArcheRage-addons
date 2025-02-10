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
local lastDeleteTime = os.time()
local deleteInterval = 6000

local function resetLogFile()
    local file = io.open(path, "w")
    if file then
        file:write("\239\187\191") -- UTF-8 BOM
        file:close()
    end
end

--basically just constantly refresh and act like tail functionality on linux
function refreshForcer:OnUpdate(dt)
    if os.time() - lastDeleteTime >= deleteInterval then
        os.remove(path)
        resetLogFile()
        lastDeleteTime = os.time()
    end

    local file = io.open(path, "r")
    if not file then return end
    local lastLine
    for line in file:lines() do
        lastLine = line
    end
    file:close()

    if lastLine and lastLine ~= lastPrintedLine then
        --don't print bugged lines
        if lastLine:match("00000") or lastLine:match("DAILY_MSG") or lastLine:match("\239\187\191") then
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
