if not LOCALE_zhCN then
    return
end
--[[
https://wago.tools/db2/Achievement?locale=zhCN

local tab={
    {Instance_ID,ID},
    ...
}
]]
local tab

EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
     if arg1~='WoWTools_Chinese_Scanner' then
        return
    end

    if tab then
       WoWTools_SC_MapIDAchievements={}
       for _, data in pairs(tab) do
            local mapID= data[1] or 0
            local achievementID= data[2] or 0
            if mapID>10 and achievementID>0 then

                if not select(10, GetAchievementInfo(achievementID))~= 136243 then
                    WoWTools_SC_MapIDAchievements[mapID]= WoWTools_SC_MapIDAchievements[mapID] or {}
                    table.insert(WoWTools_SC_MapIDAchievements[mapID], achievementID)
                end

            end
       end
    else
        WoWTools_SC_MapIDAchievements=nil
    end
    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)
