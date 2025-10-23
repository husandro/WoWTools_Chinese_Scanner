--[[
Instance_ID,ID
https://wago.tools/db2/Achievement?locale=zhCN
]]
local tab={
    
}


EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
     if arg1~='WoWTools_Chinese_Scanner' then
        return
    end
    
if tab then
    
end
    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)
