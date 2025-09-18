-- wait functions from QTR
--https://github.com/husandro/WoWTranslator/commits?author=qqytqqyt


local WaitFrame = nil
local WoWeuCN_Scanner_waitTable = {}

local qcInformationTooltip = CreateFrame("GameTooltip", "qcInformationTooltip", UIParent, "GameTooltipTemplate")
qcInformationTooltip:SetFrameStrata("TOOLTIP")

local function EnumerateTooltipStyledLines_helper(...)
    local texts = ''
    for i = 1, select("#", ...) do
        local region = select(i, ...)
        if region and region:GetObjectType() == "FontString" then
            local text = region:GetText() -- string or nil
			if (text ~= nil) then
                if (text ~= " ") then
                        text = "{{" .. text .. "}}"
                        local r, g, b, a = region:GetTextColor()
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

local function EnumerateTooltipStyledLines(tooltip) -- good for script handlers that pass the tooltip as the first argument.
  return EnumerateTooltipStyledLines_helper(tooltip:GetRegions())
end




local function WoWeuCN_Scanner_ScanIndex(index)
    WoWeuCN_Scanner_Index = tonumber(index)
    print(index)
end

local function WoWeuCN_Scanner_wait(delay, func, ...)

  if(type(delay)~="number" or type(func)~="function") then
    return false
  end

  if (WaitFrame == nil) then
    WaitFrame = CreateFrame("Frame","WoWeuCN_Scanner_waitFrame", UIParent)
    WaitFrame:SetScript("onUpdate",function (self, elapse)
      local count = #WoWeuCN_Scanner_waitTable
      local i = 1
      while(i<=count) do
        local waitRecord = tremove(WoWeuCN_Scanner_waitTable,i)
        local d = tremove(waitRecord,1)
        local f = tremove(waitRecord,1)
        local p = tremove(waitRecord,1)
        if(d>elapse) then
          tinsert(WoWeuCN_Scanner_waitTable,i,{d-elapse,f,p})
          i = i + 1
        else
          count = count - 1
          f(unpack(p))
        end
      end
    end)
  end

  tinsert(WoWeuCN_Scanner_waitTable,{delay,func,{...}})

  return true
end




















local function S_Spell(startIndex, attempt, counter)

    if (startIndex > 500000) then
        return
    end

    for i = startIndex, startIndex + 150 do
        qcInformationTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        qcInformationTooltip:ClearLines()
        qcInformationTooltip:SetHyperlink('spell:' .. i)
        qcInformationTooltip:Show()
        local text =  EnumerateTooltipStyledLines(qcInformationTooltip)
        if (text ~= '' and text ~= nil) then
        if (i >=0 and i < 100000) then
            if (WoWeuCN_Scanner_SpellToolTips0[i .. ''] == nil or string.len(WoWeuCN_Scanner_SpellToolTips0[i .. '']) < string.len(text)) then
            WoWeuCN_Scanner_SpellToolTips0[i .. ''] = text
            end
        elseif (i >=100000 and i < 200000) then
            if (WoWeuCN_Scanner_SpellToolTips100000[i .. ''] == nil or string.len(WoWeuCN_Scanner_SpellToolTips100000[i .. '']) < string.len(text)) then
            WoWeuCN_Scanner_SpellToolTips100000[i .. ''] = text
            end
        elseif (i >=200000 and i < 300000) then
            if (WoWeuCN_Scanner_SpellToolTips200000[i .. ''] == nil or string.len(WoWeuCN_Scanner_SpellToolTips200000[i .. '']) < string.len(text)) then
            WoWeuCN_Scanner_SpellToolTips200000[i .. ''] = text
            end
        elseif (i >=300000 and i < 400000) then
            if (WoWeuCN_Scanner_SpellToolTips300000[i .. ''] == nil or string.len(WoWeuCN_Scanner_SpellToolTips300000[i .. '']) < string.len(text)) then
            WoWeuCN_Scanner_SpellToolTips300000[i .. ''] = text
            end
        elseif (i >=400000 and i < 500000) then
            if (WoWeuCN_Scanner_SpellToolTips400000[i .. ''] == nil or string.len(WoWeuCN_Scanner_SpellToolTips400000[i .. '']) < string.len(text)) then
            WoWeuCN_Scanner_SpellToolTips400000[i .. ''] = text
            end
        end
        print(i)
        end
    end
  print(attempt)
  print('index ' .. startIndex)
  WoWeuCN_Scanner_Index = startIndex
  if (counter >= 5) then
    WoWeuCN_Scanner_wait(0.5, S_Spell, startIndex + 150, attempt + 1, 0)
  else
    WoWeuCN_Scanner_wait(0.5, S_Spell, startIndex, attempt + 1, counter + 1)
  end
end






















local function S_Unit(startIndex, attempt, counter)


    if (startIndex > 300000) then
        return
    end
    for i = startIndex, startIndex + 250 do
        qcInformationTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        qcInformationTooltip:ClearLines()
        local guid = "Creature-0-0-0-0-"..i.."-0000000000"
        qcInformationTooltip:SetHyperlink('unit:' .. guid)
        qcInformationTooltip:Show()
        local text =  EnumerateTooltipStyledLines(qcInformationTooltip)
        if (text ~= '' and text ~= nil) then
        if (i >=0 and i < 100000) then
        if (WoWeuCN_Scanner_UnitToolTips0[i .. ''] == nil or string.len(WoWeuCN_Scanner_UnitToolTips0[i .. '']) < string.len(text)) then
            WoWeuCN_Scanner_UnitToolTips0[i .. ''] = text
        end
        elseif (i >=100000 and i < 200000) then
        if (WoWeuCN_Scanner_UnitToolTips100000[i .. ''] == nil or string.len(WoWeuCN_Scanner_UnitToolTips100000[i .. '']) < string.len(text)) then
            WoWeuCN_Scanner_UnitToolTips100000[i .. ''] = text
        end
        elseif (i >=200000 and i < 300000) then
        if (WoWeuCN_Scanner_UnitToolTips200000[i .. ''] == nil or string.len(WoWeuCN_Scanner_UnitToolTips200000[i .. '']) < string.len(text)) then
            WoWeuCN_Scanner_UnitToolTips200000[i .. ''] = text
        end
        end
        end
        print(i)
    end

    print(attempt)
    print('index ' .. startIndex)

    WoWeuCN_Scanner_Index = startIndex

    if (counter >= 3) then
        WoWeuCN_Scanner_wait(0.5, S_Unit, startIndex + 250, attempt + 1, 0)
    else
        WoWeuCN_Scanner_wait(0.5, S_Unit, startIndex, attempt + 1, counter + 1)
    end
end
















local function S_Item(startIndex, attempt, counter)
  startIndex= startIndex or 1
  attempt= attempt or 0
  counter= counter or 0

  if (startIndex > 300000) then
    return
  end

  for i = startIndex, startIndex + 150 do
    --local itemType, itemSubType, _, _, _, _, classID, subclassID = select(6, C_Item.GetItemInfo(i))
    local classID= C_Item.GetItemInfoInstant(i)
    if classID then
      qcInformationTooltip:SetOwner(UIParent, "ANCHOR_NONE")
      qcInformationTooltip:ClearLines()
      qcInformationTooltip:SetHyperlink('item:' .. i .. ':0:0:0:0:0:0:0')
      qcInformationTooltip:Show()
      local text = EnumerateTooltipStyledLines(qcInformationTooltip)
      text = text .. '{{{' .. classID .. '}}}'
      if (text ~= '' and text ~= nil) then
        if (i >=0 and i < 100000) then
          if (WoWeuCN_Scanner_ItemToolTips0[i .. ''] == nil or string.len(WoWeuCN_Scanner_ItemToolTips0[i .. '']) < string.len(text)) then
            WoWeuCN_Scanner_ItemToolTips0[i .. ''] = text
          end
        elseif (i >=100000 and i < 200000) then
          if (WoWeuCN_Scanner_ItemToolTips100000[i .. ''] == nil or string.len(WoWeuCN_Scanner_ItemToolTips100000[i .. '']) < string.len(text)) then
            WoWeuCN_Scanner_ItemToolTips100000[i .. ''] = text
          end
        elseif (i >=200000 and i < 300000) then
          if (WoWeuCN_Scanner_ItemToolTips200000[i .. ''] == nil or string.len(WoWeuCN_Scanner_ItemToolTips200000[i .. '']) < string.len(text)) then
            WoWeuCN_Scanner_ItemToolTips200000[i .. ''] = text
          end
          print(i)
        end
      end
    end
  end

  print(attempt)
  print('index ' .. startIndex)
  WoWeuCN_Scanner_Index = startIndex

  if (counter >= 5) then
    WoWeuCN_Scanner_wait(0.5, S_Item, startIndex + 150, attempt + 1, 0)
  else
    WoWeuCN_Scanner_wait(0.5, S_Item, startIndex, attempt + 1, counter + 1)
  end
end

















local function S_Achivement(startIndex, attempt, counter)
  if (startIndex > 30000) then
    return
  end
  for i = startIndex, startIndex + 150 do
    qcInformationTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    qcInformationTooltip:ClearLines()
    qcInformationTooltip:SetHyperlink('achievement:' .. i .. ':0:0:0:0:0:0:0:0')
    qcInformationTooltip:Show()
    local text = EnumerateTooltipStyledLines(qcInformationTooltip)
    if (text ~= '' and text ~= nil) then
      if (WoWeuCN_Scanner_Achivements0[i .. ''] == nil or string.len(WoWeuCN_Scanner_Achivements0[i .. '']) < string.len(text)) then
        WoWeuCN_Scanner_Achivements0[i .. ''] = text
      end
    end
  end
  print(attempt)
  print('index ' .. startIndex)
  WoWeuCN_Scanner_Index = startIndex

  if (counter >= 5) then
    WoWeuCN_Scanner_wait(0.5, S_Achivement, startIndex + 150, attempt + 1, 0)
  else
    WoWeuCN_Scanner_wait(0.5, S_Achivement, startIndex, attempt + 1, counter + 1)
  end
end
















local function S_Quest(startIndex, attempt, counter)
  if (startIndex > 90000) then
    return
  end
  for i = startIndex, startIndex + 100 do
    qcInformationTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    qcInformationTooltip:ClearLines()
    qcInformationTooltip:SetHyperlink('quest:' .. i)
    qcInformationTooltip:Show()
    local text =  EnumerateTooltipStyledLines(qcInformationTooltip)
    if (text ~= '' and text ~= nil) then
      WoWeuCN_Scanner_QuestToolTips[i .. ''] = text
      print(i)
    end
  end
  print(attempt)
  print('index ' .. startIndex)
  WoWeuCN_Scanner_Index = startIndex
  if (counter >= 5) then
     WoWeuCN_Scanner_wait(0.5, S_Quest, startIndex + 100, attempt + 1, 0)
  else
     WoWeuCN_Scanner_wait(0.5, S_Quest, startIndex, attempt + 1, counter + 1)
  end
end








local function S_Encounter(startIndex, attempt, counter)
  if (startIndex > 25000) then
    WoWeuCN_Scanner_Index = 0
    return
  end
  for i = startIndex, startIndex + 100 do
    local sectionInfo = EJ_GetEncounterInfo(i)
    if (sectionInfo) then
	    local ename, description, _, rootSectionID = EJ_GetEncounterInfo(i)
      WoWeuCN_Scanner_EncounterData[i] = {}
      WoWeuCN_Scanner_EncounterData[i]["Title"] = ename
      WoWeuCN_Scanner_EncounterData[i]["Description"] = description
    end
  end
  print(attempt)
  print('index ' .. startIndex)
  WoWeuCN_Scanner_Index = startIndex
  if (counter >= 2) then
     WoWeuCN_Scanner_wait(0.1, S_Encounter, startIndex + 100, attempt + 1, 0)
  else
     WoWeuCN_Scanner_wait(0.1, S_Encounter, startIndex, attempt + 1, counter + 1)
  end
end










--EncounterSection
local function S_EncounterSection(startIndex, attempt, counter)
  if (startIndex > 50000) then
    WoWeuCN_Scanner_Index = 0
    return
  end

  for difficultyId = 1, 45 do
    EJ_SetDifficulty(difficultyId)
    for i = startIndex, startIndex + 100 do
      local sectionInfo =  C_EncounterJournal.GetSectionInfo(i)
      if (sectionInfo and not sectionInfo.filteredByDifficulty) then
        WoWeuCN_Scanner_EncounterSectionData[EJ_GetDifficulty() .. 'x' .. i] = {}
        WoWeuCN_Scanner_EncounterSectionData[EJ_GetDifficulty() .. 'x' .. i]["Title"] = sectionInfo.title

        print(sectionInfo.title)
        WoWeuCN_Scanner_EncounterSectionData[EJ_GetDifficulty() .. 'x' .. i]["Description"] = sectionInfo.description
      end
    end
  end

  print(attempt)
  print('index ' .. startIndex)
  WoWeuCN_Scanner_Index = startIndex

  if (counter >= 2) then
     WoWeuCN_Scanner_wait(0.1, S_EncounterSection, startIndex + 100, attempt + 1, 0)
  else
     WoWeuCN_Scanner_wait(0.1, S_EncounterSection, startIndex, attempt + 1, counter + 1)
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

    WoWeuCN_Scanner_Index = startIndex

    if (counter >= 5) then
      WoWeuCN_Scanner_wait(0.2, S_CacheQuest, startIndex + 150, attempt + 1, 0)
    else
      WoWeuCN_Scanner_wait(0.2, S_CacheQuest, startIndex, attempt + 1, counter + 1)
    end
end




























EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
  if arg1~='WoWeuCN_Scanner' then
    return
  end

    WoWeuCN_Scanner_Index = WoWeuCN_Scanner_Index or 1

    WoWeuCN_Scanner_SpellToolTips0 = WoWeuCN_Scanner_SpellToolTips0 or {}
    WoWeuCN_Scanner_SpellToolTips100000 = WoWeuCN_Scanner_SpellToolTips100000 or {}
    WoWeuCN_Scanner_SpellToolTips200000 = WoWeuCN_Scanner_SpellToolTips200000 or {}
    WoWeuCN_Scanner_SpellToolTips300000 = WoWeuCN_Scanner_SpellToolTips300000 or {}
    WoWeuCN_Scanner_SpellToolTips400000 = WoWeuCN_Scanner_SpellToolTips400000 or {}

    WoWeuCN_Scanner_UnitToolTips0 = WoWeuCN_Scanner_UnitToolTips0 or {}
    WoWeuCN_Scanner_UnitToolTips100000 = WoWeuCN_Scanner_UnitToolTips100000 or {}
    WoWeuCN_Scanner_UnitToolTips200000 = WoWeuCN_Scanner_UnitToolTips200000 or {}

    WoWeuCN_Scanner_ItemToolTips0 = WoWeuCN_Scanner_ItemToolTips0 or {}
    WoWeuCN_Scanner_ItemToolTips100000 = WoWeuCN_Scanner_ItemToolTips100000 or {}
    WoWeuCN_Scanner_ItemToolTips200000 = WoWeuCN_Scanner_ItemToolTips200000 or {}

    WoWeuCN_Scanner_Achivements0 = WoWeuCN_Scanner_Achivements0 or {}

    WoWeuCN_Scanner_QuestToolTips = WoWeuCN_Scanner_QuestToolTips or {}

    WoWeuCN_Scanner_EncounterSectionData = WoWeuCN_Scanner_EncounterSectionData or {}
    WoWeuCN_Scanner_EncounterData = WoWeuCN_Scanner_EncounterData or {}

    SlashCmdList["S"] = function(msg)

        if (string.sub(msg,1,string.len("index"))~="index") then

            local index = string.sub(msg,string.len("index")+2)
            WoWeuCN_Scanner_ScanIndex(index)

            --clear
        elseif (msg=="clear" or msg=="CLEAR") then
            WoWeuCN_Scanner_SpellToolIndex = 1
            WoWeuCN_Scanner_SpellToolTips0 = {}
            WoWeuCN_Scanner_SpellToolTips100000 = {}
            WoWeuCN_Scanner_SpellToolTips200000 = {}
            WoWeuCN_Scanner_SpellToolTips300000 = {}
            WoWeuCN_Scanner_SpellToolTips400000 = {}
            WoWeuCN_Scanner_ItemToolTips0 = {}
            WoWeuCN_Scanner_ItemToolTips100000 = {}
            WoWeuCN_Scanner_ItemToolTips200000 = {}
            WoWeuCN_Scanner_ItemIndex = 1
            WoWeuCN_Scanner_UnitToolTips0 = {}
            WoWeuCN_Scanner_UnitToolTips100000 = {}
            WoWeuCN_Scanner_UnitToolTips200000 = {}
            WoWeuCN_Scanner_UnitIndex = 1
            WoWeuCN_Scanner_Achivements0 = {}
            WoWeuCN_Scanner_AchivementsIndex = 1
            WoWeuCN_Scanner_QuestToolTips = {}
            WoWeuCN_Scanner_QuestIndex = 1
            print("清除")

            -- spell auto scan
        elseif (msg=="spellscanauto" or msg=="SPELLSCANAUTO") then
            WoWeuCN_Scanner_wait(0.1, S_Spell, WoWeuCN_Scanner_Index, 1, 0)

            -- unit auto scan
        elseif (msg=="unitscanauto" or msg=="UNITSCANAUTO") then
            WoWeuCN_Scanner_wait(0.1, S_Unit, WoWeuCN_Scanner_Index, 1, 0)

            -- item auto scan
        elseif (msg=="itemscanauto" or msg=="ITEMSCANAUTO") then
            WoWeuCN_Scanner_wait(0.1, S_Item, WoWeuCN_Scanner_Index, 1, 0)

            -- achivement auto scan
        elseif (msg=="achievescanauto" or msg=="ACHIVESCANAUTO") then
            WoWeuCN_Scanner_wait(0.1, S_Achivement, WoWeuCN_Scanner_Index, 1, 0)

            -- quest scan  
        elseif (msg=="questscanauto" or msg=="QUESTSCANAUTO") then
            WoWeuCN_Scanner_wait(0.1, S_Quest, WoWeuCN_Scanner_Index, 1, 0)

            -- encounter scan  
        elseif (msg=="encounterscanauto" or msg=="ENCOUNTERSCANAUTO") then
            WoWeuCN_Scanner_wait(0.1, S_Encounter, WoWeuCN_Scanner_Index, 1, 0)

            -- encounter scan  
        elseif (msg=="encountersectionscanauto" or msg=="ENCOUNTERSECTIONSCANAUTO") then
            WoWeuCN_Scanner_wait(0.1, S_EncounterSection, WoWeuCN_Scanner_Index, 1, 0)

            -- quest cache scan
        elseif (msg=="cachescanauto" or msg=="CACHESCANAUTO") then
            WoWeuCN_Scanner_wait(0.1, S_CacheQuest, WoWeuCN_Scanner_Index, 1, 0)

        end
    end
    SLASH_WoWeuCN_Scanner1 = "/WoWeuCN-Scanner"

    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)

--[[
/S spellscanauto
]]