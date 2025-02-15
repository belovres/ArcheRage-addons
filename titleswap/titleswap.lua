-------------- Original Author: Strawberry --------------
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

ADDON:ImportAPI(API_TYPE.OPTION.id)
ADDON:ImportAPI(API_TYPE.CHAT.id)
ADDON:ImportAPI(API_TYPE.ACHIEVEMENT.id)
ADDON:ImportAPI(API_TYPE.UNIT.id)
ADDON:ImportAPI(API_TYPE.LOCALE.id)
ADDON:ImportAPI(API_TYPE.PLAYER.id)

local function dump(o)
 if type(o) == 'table' then
  local s = '{ '
  for k,v in pairs(o) do
    if type(k) ~= 'number' then k = '"'..k..'"' end
    s = s .. '['..k..'] = ' .. dump(v) .. ','
  end
  return s .. '} '
 else
  return tostring(o)
 end
end

--button skin settings
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

local color_selected = {}
color_selected.normal    = UIParent:GetFontColor("green")
color_selected.highlight = UIParent:GetFontColor("green")
color_selected.pushed    = UIParent:GetFontColor("green")
color_selected.disabled  = UIParent:GetFontColor("btn_dis")

local buttonskin_selected = {
    drawableType = "ninePart",
    path = "ui/common/default.dds",
    coordsKey = "btn",
    autoResize = true,
    fontColor = color_selected,
    fontInset = {
        left = 11,
        right = 11,
        top = 0,
        bottom = 0,
    },
}

-- actual title box
local titleWindow = CreateEmptyWindow("titleWindow", "UIParent")
titleWindow:Show(true)

local titles = {}  -- Stores loaded titles in memory
local titlesFile = "titles.lua"

-- Create the title list window
local titleListWindow = CreateEmptyWindow("titleListWindow", "UIParent")
titleListWindow:SetExtent(0, 0) -- Set size (width, height)
titleListWindow:AddAnchor("RIGHT", "UIParent", -100, -200) -- Center the window
titleListWindow:EnableDrag(true)
titleListWindow:Show(true)

--thanks pinkl
local background = titleListWindow:CreateColorDrawable(0, 0, 0, 0.5, "background")
background:AddAnchor("TOPLEFT", titleListWindow, 0, 0)
background:AddAnchor("BOTTOMRIGHT", titleListWindow, 0, 0)

local titleWidgets = {} -- Store buttons for updating later

-- Reads titles from the file
local function initializeTitles()
    local file = io.open(titlesFile, "r")
    if file then
        titles = {}  -- Reset the table to avoid duplicates
        for line in file:lines() do
            local id, name, path = line:match('%["(%d+)"%]%s*=%s*{name%s*=%s*"(.-)",%s*icon%s*=%s*"(.-)"}')
            if id and name and path then
                titles[id] = {name = name, icon = path}
            end
        end
        file:close()
    else
        X2Chat:DispatchChatMessage(CMF_SYSTEM, "Title file not found, initializing empty list.")
    end

    -- Generate UI buttons here using titles[id].name and titles[id].icon
end

--these handle title setting from buttons:
local function setTitle(titleId) 
    X2Player:ChangeAppellation(0, tonumber(titleId))
    --local currentTitle = X2Player:GetEffectAppellation()
    --local currentTitleId = tostring(currentTitle[1])
    --X2Chat:DispatchChatMessage(CMF_SYSTEM, "Changing to title failed:" .. titleId .. currentTitleId)
    --if titleId ~= currentTitleId then
    --    X2Chat:DispatchChatMessage(CMF_SYSTEM, "Changing to title failed.")
    --    return false
    --end
    return true
end
local function createTitleList()
    -- Clear existing buttons
    for _, widget in ipairs(titleWidgets) do
        widget:SetText("")
        widget:AddAnchor("TOPLEFT", titleListWindow, 9999, 9999) -- Move out of view temporarily
    end
    titleWidgets = {}  -- Reset the table of title widgets

    local yOffset = 10
    local buttonSpacing = 25
    -- button size settings
    local xSize = 80
    local ySize = 30
    local currentTitle = X2Player:GetEffectAppellation()
    local currentTitleId = tostring(currentTitle[1])

    local totalTitles = 0  -- Keep track of how many titles we've processed
    -- Loop through titles and create buttons
    for id, data in pairs(titles) do
        totalTitles = totalTitles + 1  -- Increment the number of titles

        local titleButton = titleListWindow:CreateChildWidget("button", "titleButton_" .. id, tonumber(id), true)
        titleButton:AddAnchor("TOPLEFT", titleListWindow, 10, yOffset)
        titleButton:SetText(data.name)

        -- Apply the appropriate skin based on the current title
        if id == currentTitleId then
            ApplyButtonSkin(titleButton, buttonskin_selected)
        else
            ApplyButtonSkin(titleButton, buttonskin)
        end

        titleButton:SetExtent(xSize, ySize)
        titleButton:SetHandler("OnClick", function()
            local titleCheck = setTitle(id)
            if titleCheck == true then
                -- set to green and others to normal
                ApplyButtonSkin(titleButton, buttonskin_selected)
                titleButton:SetExtent(xSize, ySize)
                for _, otherButton in ipairs(titleWidgets) do
                    if otherButton ~= titleButton then
                        ApplyButtonSkin(otherButton, buttonskin)
                        otherButton:SetExtent(xSize, ySize)
                    end
                end
            end
        end)

        table.insert(titleWidgets, titleButton)
        yOffset = yOffset + buttonSpacing  -- Move down for the next button
    end

    -- Set the extent (size) of the window based on the number of titles
    local windowWidth = 100  -- Adjusted width for the window (slightly bigger than button width)
    local windowHeight = totalTitles * buttonSpacing + 25  -- Height of the window, taking spacing into account
    titleListWindow:SetExtent(windowWidth, windowHeight)  -- Set the size of the window
end



local function saveTitles()
    local file = io.open(titlesFile, "w")
    if not file then
        X2Chat:DispatchChatMessage(CMF_SYSTEM, "Failed to open title file for writing.")
        return
    end
    file:write("titles = {\n")
    for id, data in pairs(titles) do
        file:write(string.format('    ["%s"] = {name = "%s", icon = "%s"},\n', id, data.name, data.icon))
    end
    file:write("}\n")
    file:close()
    createTitleList()
end

local function saveTitle(titleId, titleName, titleIconPath)
    titles[titleId] = {name = titleName, icon = titleIconPath}
    saveTitles()
    X2Chat:DispatchChatMessage(CMF_SYSTEM, "Saved title: " .. titleName)
end

local function deleteTitle(titleId, name)
    --X2Chat:DispatchChatMessage(CMF_SYSTEM, "Current titles: " .. dump(titles))
    --X2Chat:DispatchChatMessage(CMF_SYSTEM, "Checking for : " .. titleId)
    --X2Chat:DispatchChatMessage(CMF_SYSTEM, "Which should be: " .. dump(titles[titleId]))
    if titles[titleId] then--and titles[titleId].name == name then
        titles[titleId] = nil
        saveTitles()
        X2Chat:DispatchChatMessage(CMF_SYSTEM, "Deleted title: " .. name)
    else
        X2Chat:DispatchChatMessage(CMF_SYSTEM, "Title not found: " .. name)
    end
end

-- Handle chat events
local chatAggroEventListenerEvents = {
    CHAT_MESSAGE = function(channel, relation, name, message, info)
        --X2Chat:DispatchChatMessage(CMF_SYSTEM, "x2name: " .. X2Unit:UnitName("player") .. " name: ".. name) --.. " fchar: "..string.sub(message, 1, 1) )
        if name == X2Unit:UnitName("player") then--and string.sub(message, 1, 1) == "/" then
            local firstWord = string.match(message, "/%w+")
            local secondWord = string.match(message, "/%w+%s+(%w+)") 
            if firstWord == "/addtitle" then
                local currentTitle = X2Player:GetEffectAppellation()
                local titleId = tostring(currentTitle[1])
                local titleName = currentTitle[2]
                if secondWord ~= nil then
                    titleName = secondWord
                end
                local titleIconPath = currentTitle[6]["path"]
                --X2Chat:DispatchChatMessage(CMF_SYSTEM, "Adding title." .. titleId .. titleName .. titleIconPath)
                saveTitle(titleId, titleName, titleIconPath)
            elseif firstWord == "/removetitle" then
                local currentTitle = X2Player:GetEffectAppellation()
                local titleId = tostring(currentTitle[1])
                local titleName = currentTitle[2]
                if secondWord ~= nil then
                    titleName = secondWord
                end
                --X2Chat:DispatchChatMessage(CMF_SYSTEM, "Removing title." .. titleId .. titleName)
                deleteTitle(titleId, titleName)
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

--make draggable (needs save function)
function titleListWindow:OnDragStart()
    self:StartMoving()
    self.moving = true
end
titleListWindow:SetHandler("OnDragStart", titleListWindow.OnDragStart)

function titleListWindow:OnDragStop()
    self:StopMovingOrSizing()
    self.moving = false
end
titleListWindow:SetHandler("OnDragStop", titleListWindow.OnDragStop)


X2Chat:DispatchChatMessage(CMF_SYSTEM, "Initializing Titleswap.")
initializeTitles()
createTitleList()
X2Chat:DispatchChatMessage(CMF_SYSTEM, "Titleswap loaded successfully.")
