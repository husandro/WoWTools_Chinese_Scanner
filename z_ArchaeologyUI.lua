--[[
https://wago.tools/db2/Achievement?locale=zhCN
tab={
    [BaseTag]= TagText_lang,
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
end
EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)
    if tab then
       WoWTools_SC_ArchaeologyUI={}

       for i= 1, GetNumArchaeologyRaces() do
                local name, _, _,  cur, need, max =  GetArchaeologyRaceInfo(i)
                
        end
    end
    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)
