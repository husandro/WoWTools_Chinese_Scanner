--[[
{Instance_ID,ID}
https://wago.tools/db2/Achievement?locale=zhCN
]]
local tab

EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
     if arg1~='WoWTools_Chinese_Scanner' then
        return
    end

    if tab then
       WoWTools_MapIDAchievements={}
       for _, data in pairs(tab) do
            local mapID= data[1] or 0
            local achievementID= data[2] or 0
            if mapID>0 and achievementID>0 then
                WoWTools_MapIDAchievements[mapID]= WoWTools_MapIDAchievements[mapID] or {}

                table.insert(WoWTools_MapIDAchievements[mapID], achievementID)
            end
       end
    elseif not C_AddOns.IsAddOnLoaded('WoWTools') then
        WoWTools_MapIDAchievements=nil
    end
    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)
