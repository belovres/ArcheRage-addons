-------------- Original Author: Strawberry --------------
----------------- Discord: exec_noir --------------------
ADDON:ImportObject(OBJECT_TYPE.TEXT_STYLE)
ADDON:ImportObject(OBJECT_TYPE.WINDOW)
ADDON:ImportObject(OBJECT_TYPE.LABEL)

ADDON:ImportAPI(API_TYPE.CHAT.id)
ADDON:ImportAPI(API_TYPE.LOCALE.id)

languageSetting = X2Locale:GetLocale()

--X2Chat:DispatchChatMessage(CMF_SYSTEM, "Locale: " .. languageSetting)
local channelColors = {}
if languageSetting == "zh_cn" then
    channelColors = {
        [-4] = {color = "FFE96DD9", name = "你对"},
        [0] = {color = "FFFFFFFF", name = "Say"},
        [1] = {color = "FFF86C96", name = "场景"},
        [2] = {color = "FF34E7C3", name = "交易"},
        [3] = {color = "FFBAE876", name = "组队"},
        [4] = {color = "FF6BEE80", name = "队伍"},
        [5] = {color = "FFF28F2F", name = "团队"},
        [6] = {color = "FF89AA30", name = "势力"},
        [7] = {color = "FF649DFC", name = "远征队"},
        [9] = {color = "FF1ED556", name = "家族"},
        [10] = {color = "FFFF7D1D", name = "指挥"},
        [11] = {color = "FFF5AE25", name = "审判"},
        [17] = {color = "FFD19EE5", name = "战队"},
        [18] = {color = "FF35EECA", name = "跨服"}
    }
elseif languageSetting == "ru" then
    channelColors = {
        [-4] = {color = "FFE96DD9", name = "говорит"},
        [0] = {color = "FFFFFFFF", name = "Say"},
        [1] = {color = "FFF86C96", name = "Крик"},
        [2] = {color = "FF34E7C3", name = "Торговля"},
        [3] = {color = "FFBAE876", name = "Поиск отряда"},
        [4] = {color = "FF6BEE80", name = "Отряд"},
        [5] = {color = "FFF28F2F", name = "Рейд"},
        [6] = {color = "FF89AA30", name = "Союз"},
        [7] = {color = "FF649DFC", name = "Гильдия"},
        [9] = {color = "FF1ED556", name = "Семья"},
        [10] = {color = "FFFF7D1D", name = "Глава отряда"},
        [11] = {color = "FFF5AE25", name = "Суд"},
        [17] = {color = "FFD19EE5", name = "Группа"},
        [18] = {color = "FF35EECA", name = "Общий чат"}
    }
else
    channelColors = {
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
        [17] = {color = "FFD19EE5", name = "Team"},
        [18] = {color = "FF35EECA", name = "Global"}
    }
end

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
    --X2Chat:DispatchChatMessage(CMF_SYSTEM, tostring(channelID))
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
local lastDeleteTime = os.time()
local deleteInterval = 6000

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

local function resetLogFile()
    closeLogFile()
    local file = io.open(logFilePath, "w")
    if file then
        file:write("\239\187\191") -- UTF-8 BOM
        file:close()
    end
end

closeLogFile()

local saySpace = ""
--chat listener
local chatAggroEventListenerEvents = {
    CHAT_MESSAGE = function(channel, relation, name, message, info)
        if os.time() - lastDeleteTime >= deleteInterval then
            os.remove(logFilePath)
            resetLogFile()
            lastDeleteTime = os.time()
        end

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