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

-- create an empty window that forces continuous updates
local refreshForcer = CreateEmptyWindow("refreshForcer", "UIParent")
refreshForcer:Show(true)
------------------------ Function called perpetually ------------------------
local path = "../Documents/ArcheRage.log"
local lastPrintedLine = nil
local lastDeleteTime = os.time() -- Store the initial time
local deleteInterval = 600 -- 10 minutes in seconds

--read it the first time to get all errors printed
local file1 = io.open(path, "r")
for line in file1:lines() do
    if line:lower():find("lua") then
        X2Chat:DispatchChatMessage(CMF_SYSTEM, line)
    end
end
file1:close()

--basically just constantly refresh and act like tail functionality on linux
function refreshForcer:OnUpdate(dt)
    local currentTime = os.time()
    if currentTime - lastDeleteTime >= deleteInterval then
        os.remove(path) -- Delete the file
        lastDeleteTime = currentTime -- Reset the delete timer
        --X2Chat:DispatchChatMessage(CMF_SYSTEM, "Log file reset.")
    end

    -- Read the last line of the file
    local file = io.open(path, "r")
    if not file then return end
    local lastLine
    for line in file:lines() do
        lastLine = line
    end
    file:close()

    -- Check if last line is lua and not duplicate
    if lastLine and lastLine:lower():find("lua") and lastLine ~= lastPrintedLine then
        X2Chat:DispatchChatMessage(CMF_SYSTEM, lastLine)
        lastPrintedLine = lastLine  -- Update the last printed line
    end
end
--force continuous updates
refreshForcer:SetHandler("OnUpdate", refreshForcer.OnUpdate)
X2Chat:DispatchChatMessage(CMF_SYSTEM, string.format("lua logging"))
