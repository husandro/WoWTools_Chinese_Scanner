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
local faction





local function GetObjectiveText(targetType, targetID)
    local objectiveText= C_ContentTracking.GetObjectiveText(targetType, targetID, false)
    if IsCN(objectiveText) then
        WoWTools_SCData.HouseTrackerObjective[targetID]= WoWTools_SCData.HouseTrackerObjective[targetID] or {}
        WoWTools_SCData.HouseTrackerObjective[targetID].targetType= targetType
        WoWTools_SCData.HouseTrackerObjective[targetID][faction]= objectiveText
    end
end




local function Save_Item(itemID)
    local entryInfo = C_HousingCatalog.GetCatalogEntryInfoByItem(itemID, false)
    if not entryInfo then
        return
    end
    if entryInfo.entryID then
        local recordID= entryInfo.entryID.recordID
        if C_ContentTracking.IsTrackable(Enum.ContentTrackingType.Decor, recordID) then
           -- C_ContentTracking.StartTracking(Enum.ContentTrackingType.Decor, recordID)
            local targetType, targetID = C_ContentTracking.GetCurrentTrackingTarget(Enum.ContentTrackingType.Decor, recordID)
            if targetType then
                GetObjectiveText(targetType, targetID)
                C_Timer.After(1, function() GetObjectiveText(targetType, targetID) end)
            end
          --  C_ContentTracking.StopTracking(Enum.ContentTrackingType.Decor, recordID, Enum.ContentTrackingStopType.Manual)
        end
    end

    if IsCN(entryInfo.sourceText) then
        WoWTools_SCData.HouseSource[itemID]= WoWTools_SCData.HouseSource[itemID] or {}
        WoWTools_SCData.HouseSource[itemID][faction]= entryInfo.sourceText
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
        faction= UnitFactionGroup('player')

        EventRegistry:RegisterFrameEventAndCallback("CONTENT_TRACKING_UPDATE", function(_, targetType, targetID)
            GetObjectiveText(targetType, targetID)
        end)

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