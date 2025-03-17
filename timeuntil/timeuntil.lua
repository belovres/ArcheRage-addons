-------------- Original Author: Strawberry --------------
--------------- Thanks to Koala and Zilus ---------------
----------------- Discord: exec.noir --------------------
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
ADDON:ImportAPI(API_TYPE.TIME.id)

--TODO:
-- + and - buttons to extend amount shown
-- add event duration for each event and maintain it at the top in green as "in progress" (done for serverevents, needs testing)
-- add duration for gameevents

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

local timerAnchor = CreateEmptyWindow("timerAnchor", "UIParent")
      timerAnchor:Show(true)
      timerAnchor:AddAnchor("TOPLEFT", "UIParent", 100, 100)
      timerAnchor:SetExtent(150, 50)
      timerAnchor:EnableDrag(true)
local background = timerAnchor:CreateColorDrawable(0, 0, 0, 0.5, "background")
background:AddAnchor("TOPLEFT", timerAnchor, 0, 0)
background:AddAnchor("BOTTOMRIGHT", timerAnchor, 0, 0)

local moreEntries = timerAnchor:CreateChildWidget("button", "moreEntries", 0, true)
      moreEntries:AddAnchor("TOPLEFT", timerAnchor, -5, -25)
      ApplyButtonSkin(moreEntries, buttonskin)
      moreEntries:SetExtent(35,25)
      moreEntries:SetText("+")
      function moreEntries:OnClick(arg)
        X2Chat:DispatchChatMessage(CMF_SYSTEM, "TODO: increase entries")
          --dressUpWindow:Show(false)
      end
      moreEntries:SetHandler("OnClick", moreEntries.OnClick)
local lessEntries = timerAnchor:CreateChildWidget("button", "lessEntries", 0, true)
      lessEntries:AddAnchor("TOPLEFT", timerAnchor, 25, -25)
      ApplyButtonSkin(lessEntries, buttonskin)
      lessEntries:SetExtent(35,25)
      lessEntries:SetText("-")
      function lessEntries:OnClick(arg)
        X2Chat:DispatchChatMessage(CMF_SYSTEM, "TODO: decrease entries")
          --dressUpWindow:Show(false)
      end
      lessEntries:SetHandler("OnClick", lessEntries.OnClick)

----- save draggable window ----------

local filePath = "TimeUntilWindowPos.txt"
local function SaveWindowPosition(x, y)
    local file = io.open(filePath, "w")
    file:write(string.format("%d,%d", x, y))
    file:close()
end
local function LoadSavedPosition()
    local file = io.open(filePath, "r")
    if not file then
        return 0, 0
    end
    local line = file:read("*line") 
    file:close()
    local x,y = line:match("(%d+),(%d+)")
    if x and y then
        return x,y
    else
        return 0,0
    end
end
function timerAnchor:OnDragStart()
    self:StartMoving()
    self.moving = true
end
timerAnchor:SetHandler("OnDragStart", timerAnchor.OnDragStart)
function timerAnchor:OnDragStop()
    self:StopMovingOrSizing()
    self.moving = false
    local offsetX, offsetY = self:GetOffset()
    local uiScale = UIParent:GetUIScale() or 1.0
    local normalizedX = offsetX * uiScale
    local normalizedY = offsetY * uiScale
    SaveWindowPosition(normalizedX, normalizedY)
end
timerAnchor:SetHandler("OnDragStop", timerAnchor.OnDragStop)
local savedWindowX, savedWindowY = LoadSavedPosition()
timerAnchor:AddAnchor("TOPLEFT", "UIParent", tonumber(savedWindowX), tonumber(savedWindowY))
------ end of draggable window --------
local eventLabels = {}
local timerLabels = {}

local amountOfTimers = 10
timerAnchor:SetExtent(150, amountOfTimers * 25)

for i = 1, amountOfTimers do
    --names
    local lblEventName = timerAnchor:CreateChildWidget("label", "timerLabelEvent" .. i, 0, false)
    lblEventName:SetHeight(20)
    lblEventName.style:SetFontSize(16)
    lblEventName:AddAnchor("TOPLEFT", timerAnchor, 0, (i - 1) * 25)
    lblEventName.style:SetAlign(ALIGN_LEFT)
    lblEventName.style:SetColor(255, 255, 255, 255)
    lblEventName:SetText("")
    eventLabels[i] = lblEventName

    --timers
    local lblTimer = timerAnchor:CreateChildWidget("label", "timerLabelTime" .. i, 0, false)
    lblTimer:SetHeight(20)
    lblTimer.style:SetFontSize(16)
    lblTimer:AddAnchor("TOPRIGHT", timerAnchor, 0, (i - 1) * 25)
    lblTimer.style:SetAlign(ALIGN_RIGHT)
    lblTimer.style:SetColor(255, 255, 255, 255)
    lblTimer:SetText("")
    timerLabels[i] = lblTimer
end


local gameEvents = {
    ["GR"] = { startHour = 11, startMinute = 59, isAM = false, duration = 10 },
    ["CR"] = { startHour = 11, startMinute = 59, isAM = true, duration = 10 },
    ["SG CR"] = { startHour = 5, startMinute = 59, isAM = false, duration = 10 },
    ["JMG"] = { startHour = 5, startMinute = 59, isAM = true, duration = 10 }
}

local serverEvents = {
    ["Lusca"] = { times = {{hour = 12, minute = 20, duration = 30}}, days = {1, 2, 3, 4, 5, 6, 7} },
    ["BD"] = {
        { times = {{hour = 21, minute = 20, duration = 60}}, days = {3, 5} },
        { times = {{hour = 18, minute = 20, duration = 60}}, days = {7} }
    },
    ["Kraken"] = {
        { times = {{hour = 22, minute = 20, duration = 60}}, days = {3, 5} },
        { times = {{hour = 19, minute = 20, duration = 60}}, days = {7} }
    },
    ["Leviathan"] = {
        { times = {{hour = 19, minute = 49, duration = 60}}, days = {3, 5} },
        { times = {{hour = 16, minute = 49, duration = 60}}, days = {7} }
    },
    ["Charybdis"] = {
        { times = {{hour = 21, minute = 20, duration = 60}}, days = {1, 5} }
    },
    ["Anthalon (G)"] = {
        { times = {{hour = 21, minute = 20, duration = 45}}, days = {1, 2, 6} }
    },
    ["Halcy"] = {
        { times = {{hour = 1, minute = 20, duration = 30}, {hour = 10, minute = 49, duration = 10}, {hour = 20, minute = 20, duration = 10}}, days = {1, 2, 3, 4, 5, 6, 7} }
    },
    ["RD"] = {
        { times = {{hour = 1, minute = 49, duration = 20}, {hour = 10, minute = 20, duration = 10}, {hour = 19, minute = 49, duration = 10}}, days = {1, 2, 4, 6} }
    },
    ["Abyssal Atk"] = {
        { times = {{hour = 11, minute = 49, duration = 30}, {hour = 21, minute = 20, duration = 10}}, days = {3, 5, 7} }
    },
    ["Hasla"] = {
        { times = {{hour = 18, minute = 49, duration = 15}, {hour = 20, minute = 49, duration = 10}}, days = {1, 2, 3, 4} }
    },
    ["Akasch"] = {
        { times = {{hour = 14, minute = 49, duration = 20}, {hour = 18, minute = 20, duration = 10}, {hour = 21, minute = 20, duration = 10}, {hour = 21, minute = 49, duration = 10}}, days = {6} }
    },
    ["Prairie"] = {
        { times = {{hour = 8, minute = 49, duration = 20}, {hour = 21, minute = 49, duration = 10}}, days = {6, 7} }
    }
}



local function calculateDayOfWeek(year, month, day)
    if month < 3 then
        month = month + 12
        year = year - 1
    end
    local k = year % 100
    local j = math.floor(year / 100)
    local dayOfWeek = (day + math.floor((13 * (month + 1)) / 5) + k + math.floor(k / 4) + math.floor(j / 4) + 5 * j) % 7
    return (dayOfWeek + 6) % 7 + 1
end

local function minutesSinceMidnight(isAM, cHour, cMinute)
    local retMinutesSinceMidnight = 0
    cMinute = math.floor(cMinute)
    retMinutesSinceMidnight = (cHour * 60) + cMinute
    if not isAM then
        retMinutesSinceMidnight = retMinutesSinceMidnight + 720
    end
    return retMinutesSinceMidnight
end

local function serverMinutesSinceMidnight(serverTimeTable)
    if not serverTimeTable then return nil end
    return (serverTimeTable.hour * 60) + serverTimeTable.minute
end

local function getServerEventMinutes(eventTimes, eventDays, currentServerMinutes, currentDayOfWeek)
    local eventMinutesList = {}

    for _, time in ipairs(eventTimes) do
        local eventMinutes = (time.hour * 60) + time.minute
        local dayOffset = nil

        for _, eventDay in ipairs(eventDays) do
            local daysAway = eventDay - currentDayOfWeek
            if daysAway < 0 then
                daysAway = daysAway + 7
            end
            if dayOffset == nil or daysAway < dayOffset then
                dayOffset = daysAway
            end
        end

        local minutesAway = eventMinutes - currentServerMinutes + (dayOffset * 1440)
        if minutesAway < 0 then
            minutesAway = minutesAway + 1440
        end

        table.insert(eventMinutesList, minutesAway)
    end

    return eventMinutesList 
end



local timer = 0
function timerAnchor:OnUpdate(dt)
    timer = timer + dt
    if timer > 1000 then
        timer = 0

        local isAM, currentHour, currentMinute = X2Time:GetGameTime()
        local currentGameMinutes = minutesSinceMidnight(isAM, currentHour, currentMinute)

        local serverTimeTable = UIParent:GetServerTimeTable()
        local currentServerMinutes = serverMinutesSinceMidnight(serverTimeTable)
        local dayOfWeek = calculateDayOfWeek(serverTimeTable.year, serverTimeTable.month, serverTimeTable.day)


        local sortedEvents = {}

        for name, data in pairs(gameEvents) do
            local minutes = minutesSinceMidnight(data.isAM, data.startHour, data.startMinute)
            minutes = (minutes - currentGameMinutes) / 6
            if minutes < 0 then
                minutes = minutes + 240 
            end
            table.insert(sortedEvents, { name = name, minutes = minutes, isServerEvent = false })
        end
        for name, eventList in pairs(serverEvents) do
            for _, eventData in ipairs(eventList) do
                local minutesList = getServerEventMinutes(eventData.times, eventData.days, currentServerMinutes, dayOfWeek)
                for _, minutesAway in ipairs(minutesList) do
                    if minutesAway then
                        table.insert(sortedEvents, { name = name, minutes = minutesAway, isServerEvent = true })
                    end
                end
            end
        end
        table.sort(sortedEvents, function(a, b)
            local aDuration = a.isServerEvent and serverEvents[a.name][1].times[1].duration or gameEvents[a.name].duration
            local bDuration = b.isServerEvent and serverEvents[b.name][1].times[1].duration or gameEvents[b.name].duration

            local aIsActive = a.minutes < aDuration
            local bIsActive = b.minutes < bDuration

            if aIsActive and not bIsActive then
                return true
            elseif not aIsActive and bIsActive then
                return false
            end

            return a.minutes < b.minutes
        end)

        for i, event in ipairs(sortedEvents) do
            if eventLabels[i] then
                eventLabels[i]:SetText(event.name)
                if gameEvents[event.name] ~= nil then
                    eventLabels[i].style:SetColor(0.1, 0.5, 0.1, 255)
                    timerLabels[i].style:SetColor(0.1, 0.5, 0.1, 255)
                else
                    eventLabels[i].style:SetColor(255, 255, 255, 255)
                    timerLabels[i].style:SetColor(255, 255, 255, 255)
                end
                local eventDuration = event.isServerEvent and serverEvents[event.name][1].times[1].duration or gameEvents[event.name].duration
                if event.minutes < eventDuration then
                    timerLabels[i]:SetText("00:00")
                    eventLabels[i].style:SetColor(255, 0, 0, 255)
                    timerLabels[i].style:SetColor(255, 0, 0, 255)
                else
                    local hours = math.floor(event.minutes / 60)
                    local minutes = event.minutes % 60
                    timerLabels[i]:SetText(string.format("%02d:%02d", hours, minutes))
                end

            end
        end
    end
end

timerAnchor:SetHandler("OnUpdate", timerAnchor.OnUpdate)
