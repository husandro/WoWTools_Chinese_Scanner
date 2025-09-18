-- wait functions from QTR
--https://github.com/husandro/WoWTranslator/commits?author=qqytqqyt
local IsStopRun= true
local numEncounter= 0








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








































local function S_Encounter(self, startIndex, attempt, counter)
   
    if IsStopRun then
        local va= startIndex/25000*100
        self.Value:SetFormattedText('停止, %d条, %.1f%%', numEncounter, va)
        self.bar:SetValue(va)
        return

    elseif (startIndex > 25000) then
        self.bar:SetValue(100)
        self.Value:SetFormattedText('结束, %d条', numEncounter)
        self.bar:SetValue(0)
        WoWTools_SC_EncounterIndex = nil
        numEncounter= 0
        return
    end


    for journalEncounterID = startIndex, startIndex + 100 do
        local name, desc, _, _, link = EJ_GetEncounterInfo(journalEncounterID)

        name= name~='' and name or nil
        desc= desc~='' and desc or nil

        if name or desc then
            WoWTools_SC_Encounter[journalEncounterID] = {}

            if name then
                WoWTools_SC_Encounter[journalEncounterID].T = name
            end
            if desc then
                WoWTools_SC_Encounter[journalEncounterID].D = desc
            end

            numEncounter= numEncounter+1

            print('Encounter', journalEncounterID, link)
        end
    end


    local va= startIndex/25000*100
    self.Value:SetFormattedText('%d条 %.1f%%', numEncounter, va)
    self.bar:SetValue(va)
    

    WoWTools_SC_EncounterIndex = startIndex

    if (counter >= 2) then
        C_Timer.After(0.1, function() S_Encounter(self, startIndex + 100, attempt + 1, 0) end)
        --SC_Wait(0.1, S_Encounter, startIndex + 100, attempt + 1, 0)
    else
        C_Timer.After(0.1, function() S_Encounter(self, startIndex, attempt + 1, counter + 1) end)
        --SC_Wait(0.1, S_Encounter, startIndex, attempt + 1, counter + 1)
    end
end










--EncounterSection
local numEncounterSection= 0
local function S_EncounterSection(startIndex, attempt, counter)
    if (startIndex > 50000) then
        print('EncounterSection', '|cnRED_FONT_COLOR:结束|r', numEncounterSection)
        WoWTools_SC_Index = 0
        numEncounterSection= 0
        return
    end


    for index = 1, 45 do
        local name= GetDifficultyInfo(index)
        if name then
            do
                EJ_SetDifficulty(index)
            end

            for sectionID = startIndex, startIndex + 100 do
                local sectionInfo =  C_EncounterJournal.GetSectionInfo(sectionID)
                if sectionInfo and not sectionInfo.filteredByDifficulty then

                    local difficultyID= EJ_GetDifficulty() or index
                    local title= sectionInfo.title
                    local desc= sectionInfo.description

                    title= title~='' and title or nil
                    desc= desc~='' and desc or nil

                    if title or desc then
                        local t= sectionID..'x'..difficultyID

                        WoWTools_SC_SectionEncounter[t] = {}

                        if title then
                            WoWTools_SC_SectionEncounter[t].T = title
                        end
                        if desc then
                            WoWTools_SC_SectionEncounter[t].D = desc
                        end

                        numEncounterSection= numEncounterSection+1
                        print(
                            sectionID..'|cnGREEN_FONT_COLOR:x|r'..index,
                            sectionInfo.link
                        )
                    end
                end
            end
        end
    end

    print(
        'EncounterSection',
        startIndex,
        format('|cnGREEN_FONT_COLOR:%.1f%%|r', startIndex/50000*100),
        attempt,
        '|cnGREEN_FONT_COLOR:'..numEncounterSection..'条'
    )

    WoWTools_SC_Index = startIndex

    if (counter >= 2) then
        SC_Wait(0.1, S_EncounterSection, startIndex + 100, attempt + 1, 0)
    else
        SC_Wait(0.1, S_EncounterSection, startIndex, attempt + 1, counter + 1)
    end
end

























StaticPopupDialogs['WoWTools_SC']={text = '你确定要|n清除 |cnGREEN_FONT_COLOR:%s|r 数据 吗', button1 = '确定', button2 = '取消', OnAccept=function(_, func) func() end, whileDead=true, hideOnEscape=true, exclusive=true, showAlert=true, acceptDelay=1}



local function Init()

    local Frame= CreateFrame('Frame', 'WoWTools_Chinese_ScannerFrame', UIParent)
    Frame:SetFrameStrata('HIGH')
    Frame:SetFrameLevel(501)
    Frame:SetSize(500,500)
    Frame:SetPoint('CENTER')
    Frame.Border= CreateFrame('Frame', nil, Frame, 'DialogBorderTemplate')
    Frame.Header= CreateFrame('Frame', nil, Frame, 'DialogHeaderTemplate')--DialogHeaderMixin
    Frame.Header:Setup('WoWTools_Chinese_Scanner 取得数据')

    Frame:SetMovable(true)
    Frame:RegisterForDrag("LeftButton", "RightButton")
    Frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    Frame:SetScript("OnDragStop", function(self) ResetCursor() self:StopMovingOrSizing() end)
    Frame:SetScript("OnMouseDown", function() SetCursor('UI_MOVE_CURSOR') end)
    Frame:SetScript("OnMouseUp", function() ResetCursor() end)
    Frame:SetScript("OnLeave", function() ResetCursor() end)

    local ClearButton= CreateFrame('Button', nil, Frame, 'UIPanelButtonTemplate')
    ClearButton:SetSize(180, 23)
    ClearButton:SetPoint('TOP', Frame.Header, 'BOTTOM', 0, -8)
    ClearButton:SetText('清除所有数据')

    local StopButton= CreateFrame('Button', nil, Frame)
    StopButton:SetNormalAtlas('common-dropdown-icon-stop')
    StopButton:SetSize(23, 23)
    StopButton:SetPoint('LEFT', ClearButton, 'RIGHT', 8, 0)
    StopButton:SetScript('OnMouseDown', function()
        IsStopRun= true
    end)


    ClearButton:SetScript('OnMouseDown', function()
        StaticPopup_Show('WoWTools_SC', '全部', nil, function()
            WoWTools_SC_SpellIndex = nil
            WoWTools_SC_Spell0 = {}
            WoWTools_SC_Spell100000 = {}
            WoWTools_SC_Spell200000 = {}
            WoWTools_SC_Spell300000 = {}
            WoWTools_SC_Spell400000 = {}

            WoWTools_SC_ItemIndex = nil
            WoWTools_SC_Item0 = {}
            WoWTools_SC_Item100000 = {}
            WoWTools_SC_Item200000 = {}

            WoWTools_SC_UnitIndex= nil
            WoWTools_SC_Unit0 = {}
            WoWTools_SC_Unit100000 = {}
            WoWTools_SC_Unit200000 = {}

            WoWTools_SC_AchivementsIndex = nil
            WoWTools_SC_Achivements0 = {}

            WoWTools_SC_QuestIndex = nil
            WoWTools_SC_Quest = {}

            WoWTools_SC_EncounterIndex= nil
            WoWTools_SC_Encounter={}

            WoWTools_SC_SectionEncounter = nil
            WoWTools_SC_SectionEncounter={}

            print('清除数据', '|cnGREEN_FONT_COLOR:完成')
        end)
    end)

    local y= -52- 8

    local function Create_Button(name)
        local btn= CreateFrame('Button', nil, Frame)--, 'UIPanelButtonTemplate')
        btn:SetNormalAtlas('common-dropdown-icon-next')
        btn:SetPushedAtlas('PetList-ButtonSelect')
        btn:SetHighlightAtlas('PetList-ButtonHighlight')

        btn:SetSize(23, 23)
        btn:SetPoint('TOPRIGHT', -12, y)
        btn.name= name

        btn.bar= CreateFrame('StatusBar', nil, Frame)
        btn.bar:SetPoint('RIGHT', btn, 'LEFT', -2, 0)
        btn.bar:SetSize(Frame:GetWidth()-24-23-2, 18)

        btn.bar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health')
        btn.bar:SetMinMaxValues(0, 100)
        btn.bar:SetValue(80)

        btn.bar.texture= btn.bar:CreateTexture(nil, "BACKGROUND")
        btn.bar.texture:SetAllPoints(btn.bar)
        btn.bar.texture:SetAtlas('UI-HUD-UnitFrame-Player-PortraitOff-Bar-TempHPLoss-2x')

        btn.Value= btn.bar:CreateFontString(nil, "ARTWORK")
        btn.Value:SetFontObject("GameFontWhite")
        btn.Value:SetPoint('RIGHT', btn.bar)
        btn.Value:SetText('0%')

        btn.Name= btn.bar:CreateFontString(nil, "ARTWORK")
        btn.Name:SetFontObject('GameFontWhite')
        btn.Name:SetPoint('LEFT', btn.bar)
        btn.Name:SetText(name)

        y= y- 23- 8

        return btn
    end



    local Encounter= Create_Button('Encounter')
    Encounter:SetScript('OnMouseDown', function(self)
        IsStopRun= false
        S_Encounter(self, WoWTools_SC_EncounterIndex or 1, 1, 0)
    end)






    Init=function()end
end






EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
  if arg1~='WoWTools_Chinese_Scanner' then
    return
  end




    --WoWTools_SC_Index = WoWTools_SC_Index or 1

    WoWTools_SC_SpellIndex = WoWTools_SC_SpellIndex or 1
    WoWTools_SC_Spell0 = WoWTools_SC_Spell0 or {}
    WoWTools_SC_Spell100000 = WoWTools_SC_Spell100000 or {}
    WoWTools_SC_Spell200000 = WoWTools_SC_Spell200000 or {}
    WoWTools_SC_Spell300000 = WoWTools_SC_Spell300000 or {}
    WoWTools_SC_Spell400000 = WoWTools_SC_Spell400000 or {}

    WoWTools_SC_ItemIndex = WoWTools_SC_ItemIndex or 1
    WoWTools_SC_Item0 = WoWTools_SC_Item0 or {}
    WoWTools_SC_Item100000 = WoWTools_SC_Item100000 or {}
    WoWTools_SC_Item200000 = WoWTools_SC_Item200000 or {}

    WoWTools_SC_UnitIndex = WoWTools_SC_UnitIndex or 1
    WoWTools_SC_Unit0 = WoWTools_SC_Unit0 or {}
    WoWTools_SC_Unit100000 = WoWTools_SC_Unit100000 or {}
    WoWTools_SC_Unit200000 = WoWTools_SC_Unit200000 or {}

    WoWTools_SC_AchivementsIndex = WoWTools_SC_AchivementsIndex or 1
    WoWTools_SC_Achivements0 = WoWTools_SC_Achivements0 or {}

    WoWTools_SC_QuestIndex = WoWTools_SC_QuestIndex or 1
    WoWTools_SC_Quest = WoWTools_SC_Quest or {}

    WoWTools_SC_EncounterIndex= WoWTools_SC_EncounterIndex or 1
    WoWTools_SC_Encounter= WoWTools_SC_Encounter or {}

    WoWTools_SC_SectionEncounter= WoWTools_SC_SectionEncounter or 1
    WoWTools_SC_SectionEncounter= WoWTools_SC_SectionEncounter or {}


    Init()

    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)
--[[
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




/SC spellscanauto
]]