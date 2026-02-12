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
local tab={

}


if not tab or TableIsEmpty(tab) then
    return
end

for _, data in pairs(tab or {}) do
    GetAchievementInfo(data[1])
end


EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)

    WoWTools_SCData.MapIDAchievementData=  WoWTools_SCData.MapIDAchievementData or {}

    for _, data in pairs(tab) do
        local mapID= data[2] or 0 --Instance_ID
        local achievementID= data[1] or 0--ID

        if mapID>10 and achievementID>0 then

            if not select(10, GetAchievementInfo(achievementID))~= 136243 then
                if not WoWTools_SCData.MapIDAchievementData[mapID] then
                    WoWTools_SCData.MapIDAchievementData[mapID]= {}
                end

                table.insert( WoWTools_SCData.MapIDAchievementData[mapID], achievementID)
            end

        end
    end

    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)
