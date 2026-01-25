--[[
https://wago.tools/db2/HouseDecor?locale=zhCN

  {ID,ItemID},
]]
-- C_HousingCatalog.GetAllFilterTagGroups() 需要打开一次，
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
    local entryInfo = C_HousingCatalog.GetCatalogEntryInfoByItem(itemID, false)
    if not entryInfo then
        return
    end

    if entryInfo.entryID then
        do 
            C_ContentTracking.StartTracking(entryInfo.entryID.entryType, entryInfo.entryID.recordID)
        end
            local targetType, targetID = C_ContentTracking.GetCurrentTrackingTarget(entryInfo.entryID.entryType, entryInfo.entryID.recordID);
            print(targetType,targetID)

            local objectiveText = C_ContentTracking.GetObjectiveText(entryInfo.entryID.entryType, entryInfo.entryID.recordID)
            if objectiveText then
                print(objectiveText)
            end

            if IsCN(objectiveText) then
                local faction= UnitFactionGroup('player')
                WoWTools_SCData.HouseTrackerObjective[entryInfo.entryID.recordID]= WoWTools_SCData.HouseTrackerObjective[entryInfo.entryID.recordID] or {}

                WoWTools_SCData.HouseTrackerObjective[entryInfo.entryID.recordID].targetType= targetType

                WoWTools_SCData.HouseTrackerObjective[entryInfo.entryID.recordID][faction]= objectiveText
            end
    end

    if IsCN(entryInfo.sourceText) then
        WoWTools_SCData.HouseSource[itemID]= entryInfo.sourceText

        print(index..'/'..#tab..')', select(2, C_Item.GetItemInfo(itemID)), entryInfo.sourceText)
        index= index+1
    end
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

    WoWTools_SCData.HouseName= WoWTools_SCData.HouseName or {}
    WoWTools_SCData.HouseSource=  WoWTools_SCData.HouseSource or {}
    WoWTools_SCData.HouseTrackerObjective= WoWTools_SCData.HouseTrackerObjective or {}

    for _, data in pairs(tab) do
        Load_Item(data[2])

        local decorID= data[1]
        local name= C_HousingDecor.GetDecorName(decorID)

        if IsCN(name) then
            WoWTools_SCData.HouseName[decorID]= name
            Load_Item(data[2])
        end
    end

    WoWTools_SCData.HouseFilter= C_HousingCatalog.GetAllFilterTagGroups()
end





EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)
    if tab then

        if not HousingDashboardFrame then
            C_AddOns.LoadAddOn('Blizzard_HousingDashboard')
        end

        Init()
        HousingDashboardFrame:HookScript('OnShow', Init)

    else
        WoWTools_SCData.HouseName= nil
        WoWTools_SCData.HouseSource= nil
        WoWTools_SCData.HouseFilter= nil
        WoWTools_SCData.HouseTrackerObjective= nil
    end

    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)