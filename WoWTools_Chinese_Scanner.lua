-- wait functions from QTR
--https://github.com/husandro/WoWTranslator/commits?author=qqytqqyt


local WaitFrame = nil
local WaitTabs = {}

local Tooltip = CreateFrame("GameTooltip", nil, UIParent, "GameTooltipTemplate")
Tooltip:SetFrameStrata("TOOLTIP")

local function GetLinesText_helper(...)
    local texts = ''
    for i = 1, select("#", ...) do
        local region = select(i, ...)
        if region and region:GetObjectType() == "FontString" then
            local text = region:GetText() -- string or nil
            if (text ~= nil) then
                if (text ~= " ") then
                    text = "{{" .. text .. "}}"
                    local r, g, b = region:GetTextColor()
                    text = text .. "[[" .. r .. "]]" .. "[[" .. g .. "]]" .. "[[" .. b .. "]]"
                end
                print(i)
                print(text)
                texts = texts .. text
          end
        end
  end
  return texts
end

local function GetLinesText(tooltip) -- good for script handlers that pass the tooltip as the first argument.
  return GetLinesText_helper(tooltip:GetRegions())
end




local function Scanner_Index(index)
    WoWTools_SC_Index = tonumber(index)
    print(index)
end

local function SC_Wait(delay, func, ...)

  if(type(delay)~="number" or type(func)~="function") then
    return false
  end

  if (WaitFrame == nil) then
    WaitFrame = CreateFrame("Frame", nil, UIParent)
    WaitFrame:SetScript("onUpdate",function (self, elapse)
      local count = #WaitTabs
      local i = 1
      while(i<=count) do
        local waitRecord = tremove(WaitTabs,i)
        local d = tremove(waitRecord,1)
        local f = tremove(waitRecord,1)
        local p = tremove(waitRecord,1)
        if(d>elapse) then
          tinsert(WaitTabs,i,{d-elapse,f,p})
          i = i + 1
        else
          count = count - 1
          f(unpack(p))
        end
      end
    end)
  end

  tinsert(WaitTabs,{delay,func,{...}})

  return true
end




















local function S_Spell(startIndex, attempt, counter)

    if (startIndex > 500000) then
        return
    end

    for spellID = startIndex, startIndex + 150 do
        Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        Tooltip:ClearLines()
        Tooltip:SetHyperlink('spell:' .. spellID)
        Tooltip:Show()
        local text =  GetLinesText(Tooltip)
        if (text ~= '' and text ~= nil) then
        if (spellID >=0 and spellID < 100000) then
            if (WoWTools_SC_Spell0[spellID .. ''] == nil or string.len(WoWTools_SC_Spell0[spellID .. '']) < string.len(text)) then
                WoWTools_SC_Spell0[spellID .. ''] = text
            end
        elseif (spellID >=100000 and spellID < 200000) then
            if (WoWTools_SC_Spell100000[spellID .. ''] == nil or string.len(WoWTools_SC_Spell100000[spellID .. '']) < string.len(text)) then
            WoWTools_SC_Spell100000[spellID .. ''] = text
            end
        elseif (spellID >=200000 and spellID < 300000) then
            if (WoWTools_SC_Spell200000[spellID .. ''] == nil or string.len(WoWTools_SC_Spell200000[spellID .. '']) < string.len(text)) then
            WoWTools_SC_Spell200000[spellID .. ''] = text
            end
        elseif (spellID >=300000 and spellID < 400000) then
            if (WoWTools_SC_Spell300000[spellID .. ''] == nil or string.len(WoWTools_SC_Spell300000[spellID .. '']) < string.len(text)) then
            WoWTools_SC_Spell300000[spellID .. ''] = text
            end
        elseif (spellID >=400000 and spellID < 500000) then
            if (WoWTools_SC_Spell400000[spellID .. ''] == nil or string.len(WoWTools_SC_Spell400000[spellID .. '']) < string.len(text)) then
            WoWTools_SC_Spell400000[spellID .. ''] = text
            end
        end
        print(spellID)
        end
    end
  print(attempt)
  print('index ' .. startIndex)
  WoWTools_SC_Index = startIndex
  if (counter >= 5) then
    SC_Wait(0.5, S_Spell, startIndex + 150, attempt + 1, 0)
  else
    SC_Wait(0.5, S_Spell, startIndex, attempt + 1, counter + 1)
  end
end






















local function S_Unit(startIndex, attempt, counter)


    if (startIndex > 300000) then
        return
    end
    for unit = startIndex, startIndex + 250 do
        Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        Tooltip:ClearLines()
        local guid = "Creature-0-0-0-0-"..unit.."-0000000000"
        Tooltip:SetHyperlink('unit:' .. guid)
        Tooltip:Show()
        local text =  GetLinesText(Tooltip)
        if (text ~= '' and text ~= nil) then
        if (unit >=0 and unit < 100000) then
        if (WoWTools_SC_Unit0[unit .. ''] == nil or string.len(WoWTools_SC_Unit0[unit .. '']) < string.len(text)) then
            WoWTools_SC_Unit0[unit .. ''] = text
        end
        elseif (unit >=100000 and unit < 200000) then
        if (WoWTools_SC_Unit100000[unit .. ''] == nil or string.len(WoWTools_SC_Unit100000[unit .. '']) < string.len(text)) then
            WoWTools_SC_Unit100000[unit .. ''] = text
        end
        elseif (unit >=200000 and unit < 300000) then
        if (WoWTools_SC_Unit200000[unit .. ''] == nil or string.len(WoWTools_SC_Unit200000[unit .. '']) < string.len(text)) then
            WoWTools_SC_Unit200000[unit .. ''] = text
        end
        end
        end
        print(unit)
    end

    print(attempt)
    print('index ' .. startIndex)

    WoWTools_SC_Index = startIndex

    if (counter >= 3) then
        SC_Wait(0.5, S_Unit, startIndex + 250, attempt + 1, 0)
    else
        SC_Wait(0.5, S_Unit, startIndex, attempt + 1, counter + 1)
    end
end
















local function S_Item(startIndex, attempt, counter)
  startIndex= startIndex or 1
  attempt= attempt or 0
  counter= counter or 0

  if (startIndex > 300000) then
    return
  end

  for itemID = startIndex, startIndex + 150 do
    --local itemType, itemSubType, _, _, _, _, classID, subclassID = select(6, C_Item.GetItemInfo(itemID))
    local classID= C_Item.GetItemInfoInstant(itemID)
    if classID then
      Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
      Tooltip:ClearLines()
      Tooltip:SetHyperlink('item:' .. itemID .. ':0:0:0:0:0:0:0')
      Tooltip:Show()
      local text = GetLinesText(Tooltip)
      text = text .. '{{{' .. classID .. '}}}'
      if (text ~= '' and text ~= nil) then
        if (itemID >=0 and itemID < 100000) then
          if (WoWTools_SC_Item0[itemID .. ''] == nil or string.len(WoWTools_SC_Item0[itemID .. '']) < string.len(text)) then
            WoWTools_SC_Item0[itemID .. ''] = text
          end
        elseif (itemID >=100000 and itemID < 200000) then
          if (WoWTools_SC_Item100000[itemID .. ''] == nil or string.len(WoWTools_SC_Item100000[itemID .. '']) < string.len(text)) then
            WoWTools_SC_Item100000[itemID .. ''] = text
          end
        elseif (itemID >=200000 and itemID < 300000) then
          if (WoWTools_SC_Item200000[itemID .. ''] == nil or string.len(WoWTools_SC_Item200000[itemID .. '']) < string.len(text)) then
            WoWTools_SC_Item200000[itemID .. ''] = text
          end
          print(itemID)
        end
      end
    end
  end

  print(attempt)
  print('index ' .. startIndex)
  WoWTools_SC_Index = startIndex

  if (counter >= 5) then
    SC_Wait(0.5, S_Item, startIndex + 150, attempt + 1, 0)
  else
    SC_Wait(0.5, S_Item, startIndex, attempt + 1, counter + 1)
  end
end

















local function S_Achivement(startIndex, attempt, counter)
  if (startIndex > 30000) then
    return
  end
  for achievementID = startIndex, startIndex + 150 do
    Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    Tooltip:ClearLines()
    Tooltip:SetHyperlink('achievement:' .. achievementID .. ':0:0:0:0:0:0:0:0')
    Tooltip:Show()
    local text = GetLinesText(Tooltip)
    if (text ~= '' and text ~= nil) then
      if (WoWTools_SC_Achivements0[achievementID .. ''] == nil or string.len(WoWTools_SC_Achivements0[achievementID .. '']) < string.len(text)) then
        WoWTools_SC_Achivements0[achievementID .. ''] = text
      end
    end
  end
  print(attempt)
  print('index ' .. startIndex)
  WoWTools_SC_Index = startIndex

  if (counter >= 5) then
    SC_Wait(0.5, S_Achivement, startIndex + 150, attempt + 1, 0)
  else
    SC_Wait(0.5, S_Achivement, startIndex, attempt + 1, counter + 1)
  end
end
















local function S_Quest(startIndex, attempt, counter)
  if (startIndex > 90000) then
    return
  end
  for questID = startIndex, startIndex + 100 do
    Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    Tooltip:ClearLines()
    Tooltip:SetHyperlink('quest:' .. questID)
    Tooltip:Show()
    local text =  GetLinesText(Tooltip)
    if (text ~= '' and text ~= nil) then
      WoWTools_SC_Quest[questID .. ''] = text
      print(questID)
    end
  end
  print(attempt)
  print('index ' .. startIndex)
  WoWTools_SC_Index = startIndex
  if (counter >= 5) then
     SC_Wait(0.5, S_Quest, startIndex + 100, attempt + 1, 0)
  else
     SC_Wait(0.5, S_Quest, startIndex, attempt + 1, counter + 1)
  end
end








local function S_Encounter(startIndex, attempt, counter)
  if (startIndex > 25000) then
    WoWTools_SC_Index = 0
    return
  end
  for i = startIndex, startIndex + 100 do
    local sectionInfo = EJ_GetEncounterInfo(i)
    if (sectionInfo) then
      local ename, description, _, rootSectionID = EJ_GetEncounterInfo(i)
      WoWTools_SC_Encounter[i] = {}
      WoWTools_SC_Encounter[i]["Title"] = ename
      WoWTools_SC_Encounter[i]["Description"] = description
    end
  end
  print(attempt)
  print('index ' .. startIndex)
  WoWTools_SC_Index = startIndex
  if (counter >= 2) then
     SC_Wait(0.1, S_Encounter, startIndex + 100, attempt + 1, 0)
  else
     SC_Wait(0.1, S_Encounter, startIndex, attempt + 1, counter + 1)
  end
end










--EncounterSection
local function S_EncounterSection(startIndex, attempt, counter)
    if (startIndex > 50000) then
        WoWTools_SC_Index = 0
        return
    end

    for difficultyID = 1, 45 do
        EJ_SetDifficulty(difficultyID)

        for i = startIndex, startIndex + 100 do
            local sectionInfo =  C_EncounterJournal.GetSectionInfo(i)
            if (sectionInfo and not sectionInfo.filteredByDifficulty) then
                local difficulty= EJ_GetDifficulty()
                WoWTools_SC_SectionEncounter[difficulty .. 'x' .. i] = {}
                WoWTools_SC_SectionEncounter[difficulty .. 'x' .. i]["Title"] = sectionInfo.title


                WoWTools_SC_SectionEncounter[difficulty .. 'x' .. i]["Description"] = sectionInfo.description
                print(sectionInfo.title)
            end
        end
    end

    print(attempt)
    print('index ' .. startIndex)
    WoWTools_SC_Index = startIndex

    if (counter >= 2) then
        SC_Wait(0.1, S_EncounterSection, startIndex + 100, attempt + 1, 0)
    else
        SC_Wait(0.1, S_EncounterSection, startIndex, attempt + 1, counter + 1)
    end
end











--任务
local function S_CacheQuest(startIndex, attempt, counter)
    if (startIndex > 90000) then
        return
    end

    if (counter == 0) then
        print(startIndex)
    end

    for i = startIndex, startIndex + 150 do
        local title= C_QuestLog.GetTitleForQuestID(i)
        if title then
            print(title)
        end
    end

    WoWTools_SC_Index = startIndex

    if (counter >= 5) then
      SC_Wait(0.2, S_CacheQuest, startIndex + 150, attempt + 1, 0)
    else
      SC_Wait(0.2, S_CacheQuest, startIndex, attempt + 1, counter + 1)
    end
end




























EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
  if arg1~='WoWTools_Chinese_Scanner' then
    return
  end



    WoWTools_SC_Index = 1--WoWTools_SC_Index or 1

    --[[WoWTools_SC_Spell0 = WoWTools_SC_Spell0 or {}
    WoWTools_SC_Spell100000 = WoWTools_SC_Spell100000 or {}
    WoWTools_SC_Spell200000 = WoWTools_SC_Spell200000 or {}
    WoWTools_SC_Spell300000 = WoWTools_SC_Spell300000 or {}
    WoWTools_SC_Spell400000 = WoWTools_SC_Spell400000 or {}

    WoWTools_SC_Unit0 = WoWTools_SC_Unit0 or {}
    WoWTools_SC_Unit100000 = WoWTools_SC_Unit100000 or {}
    WoWTools_SC_Unit200000 = WoWTools_SC_Unit200000 or {}

    WoWTools_SC_Item0 = WoWTools_SC_Item0 or {}
    WoWTools_SC_Item100000 = WoWTools_SC_Item100000 or {}
    WoWTools_SC_Item200000 = WoWTools_SC_Item200000 or {}

    WoWTools_SC_Achivements0 = WoWTools_SC_Achivements0 or {}

    WoWTools_SC_Quest = WoWTools_SC_Quest or {}

    WoWTools_SC_SectionEncounter = WoWTools_SC_SectionEncounter or {}
    WoWTools_SC_Encounter = WoWTools_SC_Encounter or {}]]



            WoWTools_SC_SpellIndex = 1
            WoWTools_SC_Spell0 = {}
            WoWTools_SC_Spell100000 = {}
            WoWTools_SC_Spell200000 = {}
            WoWTools_SC_Spell300000 = {}
            WoWTools_SC_Spell400000 = {}

            WoWTools_SC_ItemIndex = 1
            WoWTools_SC_Item0 = {}
            WoWTools_SC_Item100000 = {}
            WoWTools_SC_Item200000 = {}


            WoWTools_SC_Unit0 = {}
            WoWTools_SC_Unit100000 = {}
            WoWTools_SC_Unit200000 = {}
            WoWTools_SC_UnitIndex = 1

            WoWTools_SC_Achivements0 = {}
            WoWTools_SC_AchivementsIndex = 1

            WoWTools_SC_Quest = {}
            WoWTools_SC_QuestIndex = 1

            WoWTools_SC_Encounter={}
            WoWTools_SC_SectionEncounter={}

            print("清除")

     SC_Wait(0.1, S_Spell, WoWTools_SC_Index, 1, 0)

    SlashCmdList["WoWToolsSC"] = function(msg)

        if string.sub(msg, 1 , string.len("index")) ~= "index" then

            local index = string.sub(msg,string.len("index")+2)
            Scanner_Index(index)

            --clear
        elseif (msg=="clear" or msg=="CLEAR") then



            -- spell auto scan
        elseif (msg=="spellscanauto" or msg=="SPELLSCANAUTO") then
            SC_Wait(0.1, S_Spell, WoWTools_SC_Index, 1, 0)

            -- unit auto scan
        elseif (msg=="unitscanauto" or msg=="UNITSCANAUTO") then
            SC_Wait(0.1, S_Unit, WoWTools_SC_Index, 1, 0)

            -- item auto scan
        elseif (msg=="itemscanauto" or msg=="ITEMSCANAUTO") then
            SC_Wait(0.1, S_Item, WoWTools_SC_Index, 1, 0)

            -- achivement auto scan
        elseif (msg=="achievescanauto" or msg=="ACHIVESCANAUTO") then
            SC_Wait(0.1, S_Achivement, WoWTools_SC_Index, 1, 0)

            -- quest scan
        elseif (msg=="questscanauto" or msg=="QUESTSCANAUTO") then
            SC_Wait(0.1, S_Quest, WoWTools_SC_Index, 1, 0)

            -- encounter scan
        elseif (msg=="encounterscanauto" or msg=="ENCOUNTERSCANAUTO") then
            SC_Wait(0.1, S_Encounter, WoWTools_SC_Index, 1, 0)

            -- encounter scan
        elseif (msg=="encountersectionscanauto" or msg=="ENCOUNTERSECTIONSCANAUTO") then
            SC_Wait(0.1, S_EncounterSection, WoWTools_SC_Index, 1, 0)

            -- quest cache scan
        elseif (msg=="cachescanauto" or msg=="CACHESCANAUTO") then
            SC_Wait(0.1, S_CacheQuest, WoWTools_SC_Index, 1, 0)

        end
    end

    SLASH_WoWToolsSC1= '/WoWSC'

    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)

--[[
/SC spellscanauto
]]