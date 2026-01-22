if not LOCALE_zhCN then
    return
end
--[[
https://wago.tools/db2/Achievement?locale=zhCN
这个数据为 WoWTools 插件 WoWTools_MapIDAchievementData 用 
local tab={
    {ID, Instance_ID},
    ...
}
]]
local tab



for _, data in pairs(tab or {}) do
    GetAchievementInfo(data[1])
end


EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)

    if tab then
       WoWTools_SC_MapIDAchievements= WoWTools_SC_MapIDAchievements or {}
       for _, data in pairs(tab) do
            local mapID= data[2] or 0
            local achievementID= data[1] or 0
            if mapID>10 and achievementID>0 then

                if not select(10, GetAchievementInfo(achievementID))~= 136243 then
                    WoWTools_SC_MapIDAchievements[mapID]= WoWTools_SC_MapIDAchievements[mapID] or {}
                    table.insert(WoWTools_SC_MapIDAchievements[mapID], achievementID)

                else
                    local link= GetAchievementLink(achievementID)
                    if link then
                        print(link)
                    end
                end

            end
       end
    else
        WoWTools_SC_MapIDAchievements= nil
    end
    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)
