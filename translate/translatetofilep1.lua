-------------- Original Author: Strawberry --------------
----------------- Discord: exec_noir --------------------
ADDON:ImportObject(OBJECT_TYPE.TEXT_STYLE)
ADDON:ImportObject(OBJECT_TYPE.WINDOW)
ADDON:ImportObject(OBJECT_TYPE.LABEL)

ADDON:ImportAPI(API_TYPE.CHAT.id)

local channelColors = {
    [-4] = {color = "FFE96DD9", name = "Whisper"},
    [0] = {color = "FFFFFFFF", name = "Say"},
    [1] = {color = "FFF86C96", name = "Shout"},
    [2] = {color = "FF34E7C3", name = "Trade"},
    [3] = {color = "FFBAE876", name = "Party search"},
    [4] = {color = "FF6BEE80", name = "Party"},
    [5] = {color = "FFF28F2F", name = "Raid"},
    [6] = {color = "FF89AA30", name = "Nation"},
    [7] = {color = "FF649DFC", name = "Guild"},
    [9] = {color = "FF1ED556", name = "Family"},
    [10] = {color = "FFFF7D1D", name = "Commander"},
    [11] = {color = "FFF5AE25", name = "Trial"},
    [18] = {color = "FF35EECA", name = "Global"}
}

local defaultColor = "FFFFFFFF"

function url_encode(str)
    local encoded = ""
    for i = 1, #str do
        local byte = str:byte(i)
        if byte >= 0x80 then  
            local char = str:sub(i, i)
            local byte_sequence = {}
            for j = 1, #char do
                byte_sequence[j] = string.format("%%%02X", char:byte(j))
            end
            encoded = encoded .. table.concat(byte_sequence)
        else
            if string.match(string.char(byte), "[^%w %-%_%.~]") then
                encoded = encoded .. string.format("%%%02X", byte)
            else
                encoded = encoded .. string.char(byte)
            end
        end
    end
    return encoded:gsub(" ", "+")
end

function GetChannelMessage(channelID, relationID)
    local channelInfo = channelColors[channelID]
    local timestamp = os.date("[%H:%M:%S]")
    local hostilecolor = "FFA9362F"
    if channelID ==  0 then
        --X2Chat:DispatchChatMessage(CMF_SYSTEM, tostring(relationID))
        if relationID == 1 then
            return string.format("|c%s%s |c%s->[", channelInfo.color, timestamp, hostilecolor)
        else 
            return string.format("|c%s%s ->[", channelInfo.color, timestamp)
        end
    else 
        if channelInfo then
            return string.format("|c%s%s ->[%s: ", channelInfo.color, timestamp, channelInfo.name)
        else
            return string.format("|c%s%s ->", defaultColor, timestamp)
        end
    end

end

local logFilePath = "../Documents/Addon/translate/ChatTranslationInput_1.log"
local logFile = io.open(logFilePath, "a")

if not logFile then
    X2Chat:DispatchChatMessage(CMF_SYSTEM,"Failed to open log file: " .. logFilePath)
end

local function closeLogFile()
    if logFile then
        logFile:close()
        logFile = nil
    end
end

local function reOpenLogFile()
    logFile = io.open(logFilePath, "a")
end
closeLogFile()

local saySpace = ""
--chat listener
local chatAggroEventListenerEvents = {
    CHAT_MESSAGE = function(channel, relation, name, message, info)
        if channel ==  0 then
            saySpace = " "
        else
            saySpace = ""
        end
        local logMessage = GetChannelMessage(channel, relation) .. name .. "]" .. saySpace .. ": " .. message .. "\n"
        --X2Chat:DispatchChatMessage(CMF_SYSTEM, "printing " .. logMessage .. " to " .. logFilePath)
        reOpenLogFile()
        logFile:write(logMessage)
        closeLogFile()
    end
}

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