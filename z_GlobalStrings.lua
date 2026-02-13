--[[
https://wago.tools/db2/GlobalStrings?locale=zhCN
tab={
    "BUG_BUTTON",
}
]]


local tab={

}


if not tab or TableIsEmpty(tab) then
    return
end



EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)
    WoWTools_SCData.GlobalStrings= {}

    do
        for _, en in pairs(tab) do
            local cn= _G[en]
            if WoWTools_SCMixin:IsCN(cn) then
                WoWTools_SCData.GlobalStrings[en]= cn
            end
        end
    end

    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)
