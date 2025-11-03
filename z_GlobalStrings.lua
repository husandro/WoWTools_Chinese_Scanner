--[[
https://wago.tools/db2/Achievement?locale=zhCN
tab={
    [BaseTag]= TagText_lang,
    ...
}
]]
local tab={
    
}



local function IsCN(text)
    return
        text
        and text:find('[\228-\233]')
        and not text:find('DNT')
        and not text:find('UNUSED')
end
EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)
     
    if tab then
       WoWTools_SC_GlobalStrings={}
       for en, cn in pairs(tab) do
            if _G[en] and IsCN(cn) then
                WoWTools_SC_GlobalStrings[en]= cn
            end
       end
    else
        WoWTools_SC_GlobalStrings=nil
    end
    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)
