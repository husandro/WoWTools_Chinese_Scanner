--[[
https://wago.tools/db2/HouseDecor?locale=zhCN

itemID,
]]
-- C_HousingCatalog.GetAllFilterTagGroups()
local tab




local function IsCN(text)
    return
        text
        and text:find('[\228-\233]')
        and not text:find('DNT')
        and not text:find('UNUSED')
        and not text:find('TEST')
end

local index
local function Save_Item(itemID)
    local entryInfo = C_HousingCatalog.GetCatalogEntryInfoByItem(itemID, true)
    if not entryInfo or not IsCN(entryInfo.sourceText) then
        return
    end

    WoWTools_SC_HouseItemSource[itemID]= entryInfo.sourceText
    print(index..'/'..#tab..')',select(2, C_Item.GetItemInfo(itemID)), entryInfo.sourceText)
    index= index+1
end


local function Load_Item(itemID)
    if not C_Item.IsItemDataCachedByID(itemID) then
        ItemEventListener:AddCancelableCallback(itemID, function()
            Save_Item(itemID)
        end)
    else
        Save_Item(itemID)
    end
end


local function Init()
    index=1
    WoWTools_SC_HouseItemSource= WoWTools_SC_HouseItemSource or {}

    for _, itemID in pairs(tab) do
        if C_Item.IsDecorItem(itemID) then
            Load_Item(itemID)
        end
    end

    WoWTools_SC_HouseFilterTag= C_HousingCatalog.GetAllFilterTagGroups()
end





EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)
    if tab then
        if not HousingDashboardFrame then
            C_AddOns.LoadAddOn('Blizzard_HousingDashboard')
        end
        Init()
        HousingDashboardFrame:HookScript('OnShow', Init)

    else
        WoWTools_SC_HouseItemSource=nil
        WoWTools_SC_HouseFilterTag=nil
    end
    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)