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
local function IsCN(text)
    return
        text
        and text:find('[\228-\233]')
        and not text:find('DNT')
        and not text:find('UNUSED')
        and not text:find('TEST')
end



EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)

    if tab then
       WoWTools_SC_Unit={}
       for _, data in pairs(tab) do

            local id= data[1] and tonumber(data[1])
            if id  then
                if IsCN(data[2]) then
                    local d= IsCN(data[3]) and data[3]
                    WoWTools_SC_Unit[id]= {T=data[2]}
                    if d then
                        WoWTools_SC_Unit[id]= {D=d}
                    end

                end
            end
       end
    else
        WoWTools_SC_Unit= nil
    end
    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)
