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
            local mapID= data[1] or 1
            local achievementID= data[2] or 1
            if mapID>1 and achievementID>1 then
                WoWTools_MapIDAchievements[mapID]= WoWTools_MapIDAchievements[mapID] or {}
                WoWTools_MapIDAchievements[mapID][achievementID]=1
            end
       end
    else
        WoWTools_MapIDAchievements=nil
    end
    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)
