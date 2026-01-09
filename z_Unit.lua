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




EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)

    if tab then
       WoWTools_SC_Unit={}
       for _, data in pairs(tab) do
            
       end
    else
        WoWTools_SC_Unit= nil
    end
    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)
