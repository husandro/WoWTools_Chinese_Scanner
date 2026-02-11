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
    WoWTools_SCData.GlobalStrings= {}--WoWTools_SCMixin:InitTable('GlobalStrings')

    do
        for _, en in pairs(tab) do
            local cn= _G[en]
            if WoWTools_SCMixin:IsCN(cn) then
                WoWTools_SCData.GlobalStrings[en]= cn
            end
        end
    end

    --WoWTools_SCMixin:InitTable('GlobalStrings', WoWTools_SCData.GlobalStrings)

    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)
