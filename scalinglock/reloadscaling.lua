-------------- Original Author: Strawberry --------------
----------------- Discord: exec_noir --------------------
API_TYPE_OPTION = 31
ADDON:ImportAPI(API_TYPE_OPTION)

local function EnteredWorld()
	UIParent:SetUIScale(0.8, true)
end
UIParent:SetEventHandler("ENTERED_WORLD", EnteredWorld)
