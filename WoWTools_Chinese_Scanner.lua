local GameVer= math.modf(select(4, GetBuildInfo())/10000)--11
local MaxQuestID= GameVer*10000 --11.2.5 版本 93516
local MaxUnitID= 300000
local MaxItemID= 300000

local Frame
local Buttons={}




--[[
( ) . % + - * ? [ ^ $
local MaxAchivementID= (GameVer-4)*10000-- 11.2.5 版本，最高61406 https://wago.tools/db2/Achievement
]]
local function IsCN(text)
    return
        text
        and text:find('[\228-\233]')
        and not text:find('DNT')
        and not text:find('UNUSED')
end
local function GetLineText(region, isColor)
    if region and region:GetObjectType() == "FontString" then
        local text = region:GetText()
        if IsCN(text) then--text~=' ' then-- 
            if isColor then
                local r,g,b= region:GetTextColor()
                if r and g and b then
                    text= format("|cff%02x%02x%02x%s|r", r*255, g*255, b*255, text)
                end
            end
            return text
        end
    end
end



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



































--[[
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

]]


















































































local function S_Encounter(self, startIndex, attempt, counter)
    if self.isStop then
        self.Value:SetFormattedText('|cffff8200暂停|r, %d, %.1f%%', startIndex, startIndex/25000*100)
        self.Name:SetText(self.name)
        return

    elseif (startIndex > 25000) then
        self.bar:SetValue(100)
        self.Value:SetFormattedText('|cffff00ff结束|r, %d条', self.num)
        self.Name:SetText(self.name)
        WoWTools_SC_EncounterIndex = nil
        self:settings()
        self.num= 0
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
            self.num= self.num+1
            self.Name:SetText(link or name or '')
        end
    end
    local va= startIndex/25000*100
    self.Value:SetFormattedText('%s   %d条 %.1f%%', SecondsToClock((GetTime()-self.time), false), self.num, va)
    self.bar:SetValue(va)
    WoWTools_SC_EncounterIndex = startIndex
    if (counter >= 2) then
        C_Timer.After(0.1, function() S_Encounter(self, startIndex + 100, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_Encounter(self, startIndex, attempt + 1, counter + 1) end)
    end
end

EJ_GetEncounterInfo(3139)























--EncounterSection
local function S_SectionEncounter(self, startIndex, attempt, counter)
    if self.isStop then
        self.Value:SetFormattedText('|cffff8200暂停, %d条, %.1f%%', startIndex, startIndex/50000*100)
        self.Name:SetText(self.name)
        return

    elseif (startIndex > 50000) then
        self.bar:SetValue(100)
        self.Value:SetFormattedText('|cffff00ff结束|r, %d条', self.num)
        self.Name:SetText(self.name)
        WoWTools_SC_SectionEncounterIndex = nil
        self:settings()
        self.num= 0
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

                        self.num= self.num+1
                        self.Name:SetText(sectionInfo.link or title or '')
                    end
                end
            end
        end
    end

    local va= startIndex/50000*100
    self.Value:SetFormattedText('%s   %d条 %.1f%%', SecondsToClock((GetTime()-self.time), false), self.num, va)
    self.bar:SetValue(va)

    WoWTools_SC_SectionEncounterIndex = startIndex

    if (counter >= 2) then
        C_Timer.After(0.1, function() S_SectionEncounter(self, startIndex + 100, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_SectionEncounter(self, startIndex, attempt + 1, counter + 1) end)
    end
end

























--任务
local function S_CacheQuest(self, startIndex, attempt, counter)
    if not WoWTools_SC_QuestCacheIndex then
        self.Name:SetText('|cffff0000停止|r, 获取“任务”数据')
        return

    elseif (startIndex > MaxQuestID) then
        self.Name:SetText('获取“任务”数据|cnGREEN_FONT_COLOR:完成')
        self.bar2:SetValue(0)
        self.bar2:Hide()
        return

    elseif startIndex==1 then
        self.Name:SetText('正在获取“任务”数据')
        self.bar2:Show()
    end

    for questID = startIndex, startIndex + 150 do
        --if not HaveQuestData(questID) then
            C_QuestLog.RequestLoadQuestByID(questID)
        --end
        local va= questID/MaxQuestID*100
        self.bar2:SetValue(va)
    end

    WoWTools_SC_QuestCacheIndex= startIndex

    if (counter >= 5) then
        C_Timer.After(0.1, function() S_CacheQuest(self, startIndex + 150, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_CacheQuest(self, startIndex, attempt + 1, counter + 1) end)
    end
end


local function Get_Objectives(questID)
    local obj= C_QuestLog.GetQuestObjectives(questID)
    if not obj then
        return
    end
    local tab= {}
    local find
    for index, info in pairs(obj) do
        if info.text then
            local t= info.text:match('%d+/%d+ (.+)') or info.text
            t= t:match('(.+) %(%d+%%%)') or t
            --t= t:gsub(' %(%d+%%%)', '')
            tab[index]= t
            find=true
        end
    end
    if find then
        return tab
    end
end

local QuestString={
    ['暂无信息']=1,
    ['要求：']=1,
}
local function Get_Quest_Tab(questID)

    local data= C_TooltipInfo.GetHyperlink('quest:' .. questID)
    if not data or not data.lines or not data.lines[1] then
        return
    end

    local title= C_QuestLog.GetTitleForQuestID(questID) or data.lines[1].leftText

    if not IsCN(title) and QuestString[title] then
        return
    end

    local obj
    if data.lines[3] and IsCN(data.lines[3].leftText) and not QuestString[data.lines[3].leftText] then
        obj= data.lines[3].leftText
    end

    return {
        ['T']= title,
        ['O']= obj,
        ['S']= Get_Objectives(questID),
    }

end



local function S_Quest(self, startIndex, attempt, counter)
    if self.isStop then
        self.Value:SetFormattedText('|cffff8200暂停|r, %d条, %.1f%%', startIndex, startIndex/MaxQuestID*100)
        self.Name:SetText(self.name)
        return

    elseif (startIndex > MaxQuestID) then
        self.bar:SetValue(100)
        self.Value:SetFormattedText('|cffff00ff结束|r, %d条', self.num)
        self.Name:SetText(self.name)
        WoWTools_SC_QuestIndex = nil
        self:settings()
        self.num= 0
        return

    end

    do
        for questID = startIndex, startIndex + 100 do
            local tab = Get_Quest_Tab(questID)
            if tab then
                WoWTools_SC_Quest[questID] = tab
                self.num= self.num+1
                self.Name:SetText(GetQuestLink(questID) or tab.T or ('questID '..questID))
            end
        end
    end

    WoWTools_SC_QuestIndex = startIndex
    local va= startIndex/MaxQuestID*100
    self.Value:SetFormattedText('%s   %d条 %.1f%%', SecondsToClock((GetTime()-self.time), false), self.num, va)
    self.bar:SetValue(va)

    if (counter >= 5) then
        C_Timer.After(0.1, function() S_Quest(self, startIndex + 100, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_Quest(self, startIndex, attempt + 1, counter + 1) end)
    end
end



























--Unit 单位
--C_TooltipInfo.GetHyperlink('unit:Creature-0-0-0-0-2748-0000000000')
local function Get_Unit_Tab(unit)
    local data= C_TooltipInfo.GetHyperlink('unit:Creature-0-0-0-0-'..unit..'-0000000000')
    if not data
        or not data.lines
        or not data.lines[1]
        or not IsCN(data.lines[1].leftText)
    then
        return
    end

    local desc
    local title
    for index, line in pairs(data.lines) do
        if index==1 then
            title= line.leftText

        elseif IsCN(line.leftText) and not line.leftText:find('等级 ') then
            desc= (desc and desc..'|n' or '')..line.leftText
        end
    end
    if title then
        return {
            ['T']= title,
            ['D']= desc,
        }
    end
end





local function S_Unit(self, startIndex, attempt, counter)
     if self.isStop then
        self.Value:SetFormattedText('|cffff8200暂停|r, %d条, %.1f%%', startIndex, startIndex/MaxUnitID*100)
        self.Name:SetText(self.name)
        return

    elseif (startIndex > MaxUnitID) then
        self.bar:SetValue(100)
        self.Value:SetFormattedText('|cffff00ff结束|r, %d条', self.num)
        self.Name:SetText(self.name)
        WoWTools_SC_UnitIndex = nil
        self:settings()
        self.num= 0
        return

    end

    do
        for unit = startIndex, startIndex + 250 do
            local tab= Get_Unit_Tab(unit)
            if tab then
                WoWTools_SC_Unit[format('%d', unit)] = tab--字母， 如果数字，输出表格会出现很多nil
                self.num= self.num+1
                self.Name:SetText(tab.T)
            end
        end
    end

    WoWTools_SC_UnitIndex = startIndex
    local va= startIndex/MaxUnitID*100
    self.Value:SetFormattedText('%s   %d条 %.1f%%', SecondsToClock((GetTime()-self.time), false), self.num, va)
    self.bar:SetValue(va)

    if (counter >= 3) then
        C_Timer.After(0.1, function() S_Unit(self, startIndex + 250, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_Unit(self, startIndex, attempt + 1, counter + 1) end)
    end
end


























local function S_CacheItem(self, startIndex, attempt, counter)
    if not WoWTools_SC_ItemCacheIndex then
        self.Name:SetText('|cffff0000停止|r, 获取“物品”数据')
        return

    elseif (startIndex > MaxItemID) then
        self.Name:SetText('获取“物品” 数据 |cnGREEN_FONT_COLOR:完成')
        self.bar2:SetValue(0)
        self.bar2:Hide()
        return

    elseif startIndex==1 then
        self.Name:SetText('正在获取“物品”数据')
        self.bar2:Show()
    end

    for itemID = startIndex, startIndex + 150 do
        if not C_Item.IsItemDataCachedByID(itemID) then
            C_Item.RequestLoadItemDataByID(itemID)
        end
        local va= itemID/MaxItemID*100
        self.bar2:SetValue(va)
    end

    WoWTools_SC_ItemCacheIndex= startIndex

    if (counter >= 5) then
        C_Timer.After(0.1, function() S_CacheItem(self, startIndex + 150, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_CacheItem(self, startIndex, attempt + 1, counter + 1) end)
    end
end

local ItemString={
    ['你尚未收藏过此外观']=1,
    ['正在获取物品信息']=1,
    ['拾取后绑定']=1,
    ['你拥有此外观，但不是来自此物品']=1,
}

local function Get_Item_Tab(itemID)
      local data= C_TooltipInfo.GetHyperlink('item:'..itemID..':0:0:0:0:0:0:0')
    if not data
        or not data.lines
        or not data.lines[1]
        or not IsCN(data.lines[1].leftText)
        or ItemString[data.lines[1].leftText]
    then
        return
    end

    local title
    local desc

    for index, line in pairs(data.lines) do
        if index==1 then
            title= C_Item.GetItemInfo(itemID) or line.leftText

        elseif
            IsCN(line.leftText)
            and not ItemString[line.leftText]
            and not line.leftText:find('需要等级 %d+')
            and not line.leftText:find('^%+%d+ ')
            and not line.leftText:find('^%d+点')

        then-- and not line.leftText:find('等级 ') then
            local right= IsCN(line.rightText) and line.rightText
            desc= (desc and desc..'|n' or '')..line.leftText..(right and '  '..right or '')
        end
    end
    if title then
        return {
            ['T']= title,
            ['D']= desc,
        }
    end

end

local function S_Item(self, startIndex, attempt, counter)
    if self.isStop then
        self.Value:SetFormattedText('|cffff8200暂停|r, %d条, %.1f%%', startIndex, startIndex/MaxQuestID*100)
        self.Name:SetText(self.name)
        return

    elseif (startIndex > MaxQuestID) then
        self.bar:SetValue(100)
        self.Value:SetFormattedText('|cffff00ff结束|r, %d条', self.num)
        self.Name:SetText(self.name)
        WoWTools_SC_QuestIndex = nil
        self:settings()
        self.num= 0
        return

    end

    do
        for itemID = startIndex, startIndex + 150 do
            local tab = Get_Item_Tab(itemID)
            if tab then
                --WoWTools_SC_Item[format('%d', itemID)] = tab
                WoWTools_SC_Item[itemID] = tab
                self.num= self.num+1
                self.Name:SetText( select(2, C_Item.GetItemInfo(itemID)) or tab.T)
            end
        end
    end

    WoWTools_SC_ItemIndex = startIndex
    local va= startIndex/MaxItemID*100
    self.Value:SetFormattedText('%s   %d条 %.1f%%', SecondsToClock((GetTime()-self.time), false), self.num, va)
    self.bar:SetValue(va)

    if (counter >= 5) then
        C_Timer.After(0.1, function() S_Item(self, startIndex + 150, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_Item(self, startIndex, attempt + 1, counter + 1) end)
    end
end

local function Set_Item_Event(btn)
    btn:RegisterEvent('ITEM_DATA_LOAD_RESULT')
    btn:SetScript('OnEvent', function(_, itemID, success)
        if not itemID and not success then
            return
        end

    end)
end




















local function clear_data(name)
    _G['WoWTools_SC_'..name..'Index']= nil
    _G['WoWTools_SC_'..name..'CacheIndex']= nil
    _G['WoWTools_SC_'..name]= {}

    local btn= _G['WoWToolsSC'..name..'Button']
    if not btn.isStop then
        btn:settings()
    else
        btn.time=nil
    end

    btn.bar:SetValue(0)
    btn.Value:SetText("")


    print('清除数据', name or '全部', '|cnGREEN_FONT_COLOR:完成')
end

StaticPopupDialogs['WoWTools_SC']={
    text = '你确定要|n清除 |cnGREEN_FONT_COLOR:%s|r 数据 吗',
    button1 = '确定', button2 = '取消',
    whileDead=true, hideOnEscape=true, exclusive=true, showAlert=true, acceptDelay=1,
    OnAccept=function(_, data)
        if data then
            clear_data(data)
        else
            for _, name in pairs(Buttons) do
                clear_data(name)
            end
        end
    end
}













local y= -70
local function Create_Button(name)
    local btn= CreateFrame('Button', 'WoWToolsSC'..name..'Button', Frame)
    btn:SetNormalAtlas('common-dropdown-icon-next')
    btn:SetPushedAtlas('PetList-ButtonSelect')
    btn:SetHighlightAtlas('PetList-ButtonHighlight')
    btn:SetScript('OnLeave', function() GameTooltip:Hide() end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:SetText(self.isStop and '运行' or '暂停')
        GameTooltip:Show()
    end)
    function btn:settings()
        self.isStop= not self.isStop and true or nil
        if self.isStop then
            self.num= 0
            self:SetNormalAtlas('common-dropdown-icon-next')
            self.time=nil
        else
            self:SetNormalAtlas('common-dropdown-icon-stop')
            self.num= _G['WoWTools_SC_'..self.name..'Index'] or 0
            self.time= GetTime()
        end
    end
    btn:settings()

    btn:SetSize(23, 23)
    btn:SetPoint('TOPRIGHT', -45, y)
    btn.name= name

    btn.bar= CreateFrame('StatusBar', nil, btn)
    btn.bar:SetPoint('RIGHT', btn, 'LEFT', -2, 0)
    btn.bar:SetSize(Frame:GetWidth()-48-23*2, 18)
    btn.bar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health')
    btn.bar:SetMinMaxValues(0, 100)
    btn.bar:SetValue(0)
    btn.bar.texture= btn.bar:CreateTexture(nil, "BACKGROUND")
    btn.bar.texture:SetAllPoints(btn.bar)
    btn.bar.texture:SetAtlas('UI-HUD-UnitFrame-Player-PortraitOff-Bar-TempHPLoss-2x')

    btn.bar2= CreateFrame('StatusBar', nil, btn)
    btn.bar2:SetPoint('TOPLEFT', btn.bar, 'BOTTOMLEFT')
    btn.bar2:SetPoint('TOPRIGHT', btn.bar, 'BOTTOMRIGHT')
    btn.bar2:SetHeight(4)
    btn.bar2:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health')
    btn.bar2:SetMinMaxValues(0, 100)
    btn.bar2:SetValue(0)
    btn.bar2:Hide()

    btn.Value= btn.bar:CreateFontString(nil, "OVERLAY")
    btn.Value:SetFontObject("GameFontWhite")
    btn.Value:SetPoint('RIGHT', btn.bar)
    btn.Value:SetFormattedText('%d', _G['WoWTools_SC_'..name..'Index'] or 0)

    btn.Name= btn.bar:CreateFontString(nil, "OVERLAY")
    btn.Name:SetFontObject('GameFontWhite')
    btn.Name:SetPoint('LEFT', btn.bar)
    btn.Name:SetText(name)

    btn.clear= CreateFrame('Button', nil, btn)
    btn.clear:SetNormalAtlas('bags-button-autosort-up')
    btn.clear:SetPushedAtlas('PetList-ButtonSelect')
    btn.clear:SetHighlightAtlas('PetList-ButtonHighlight')
    btn.clear:SetPoint('LEFT', btn, 'RIGHT', 2, 0)
    btn.clear:SetSize(23,23)
    btn.clear:SetScript('OnMouseDown', function(self)
        local p= self:GetParent()
        local n= p.name
        if not p.isStop then
            p:settings()
        else
            p.time=nil
        end
        StaticPopup_Show('WoWTools_SC', n, nil, n)
    end)
    y= y- 23- 8

    return btn
end













local function Init()

    Frame= CreateFrame('Frame', 'WoWTools_SCFrame', UIParent)
    Frame:SetFrameStrata('HIGH')
    Frame:SetFrameLevel(501)
    Frame:SetSize(520, 500)
    Frame:SetPoint('CENTER')
    Frame.Border= CreateFrame('Frame', nil, Frame, 'DialogBorderTemplate')
    Frame.Header= CreateFrame('Frame', nil, Frame, 'DialogHeaderTemplate')--DialogHeaderMixin
    Frame.Header:Setup('WoWTools_Chinese_Scanner 取得数据')
    Frame:RegisterEvent('PLAYER_REGEN_ENABLED')
    Frame:SetScript('OnShow', function(self)
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
    end)
    Frame:SetScript('OnHide', function(self)
        self:UnregisterEvent('PLAYER_REGEN_ENABLED')
    end)
    Frame:SetScript('OnEvent', function()
        for _, name in pairs(Buttons) do
            local btn= _G['WoWToolsSC'..name..'Button']
            if not btn.isStop then
                btn:settings()
            end
        end
    end)

    Frame:SetMovable(true)
    Frame:RegisterForDrag("LeftButton", "RightButton")
    Frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    Frame:SetScript("OnDragStop", function(self) ResetCursor() self:StopMovingOrSizing() end)
    Frame:SetScript("OnMouseDown", function() SetCursor('UI_MOVE_CURSOR') end)
    Frame:SetScript("OnMouseUp", function() ResetCursor() end)
    Frame:SetScript("OnLeave", function() ResetCursor() end)

    local note= Frame:CreateFontString(nil, "OVERLAY")
    note:SetFontObject('GameFontNormal')
    note:SetPoint('BOTTOM', 0, 12)
    note:SetText('|cffffffff数据：|rWTF\\Account\\...\\SavedVariables\\WoWTools_Chinese_Scanner.lua')

    local ClearButton= CreateFrame('Button', nil, Frame, 'UIPanelButtonTemplate')
    ClearButton:SetSize(180, 23)
    ClearButton:SetPoint('TOP', Frame.Header, 'BOTTOM', 0, -10)
    ClearButton:SetText('清除所有数据')
    ClearButton:SetScript('OnMouseDown', function()
        for _, name in pairs(Buttons) do
            local btn= _G['WoWToolsSC'..name..'Button']
            if not btn.isStop then
                btn:settings()
            else
                btn.time=nil
            end
        end
        StaticPopup_Show('WoWTools_SC', '全部', nil, nil)
    end)


    for name, func in pairs({
        ['Encounter']= S_Encounter,
        ['SectionEncounter']= S_SectionEncounter,
        ['Quest']= S_Quest,
        ['Unit']= S_Unit,
        ['Item']= S_Item,
    }) do
        local btn= Create_Button(name)
        btn.func= func
        btn:SetScript('OnMouseDown', function(self)
            self:settings()
            if not self.isStop then
                self.func(self, _G['WoWTools_SC_'..self.name..'Index'] or 1, 0, 0)
            end
        end)

        if name=='Quest' then
            S_CacheQuest(btn, WoWTools_SC_QuestCacheIndex or 1, 0, 0)
        elseif name=='Item' then
            Set_Item_Event(btn)
            S_CacheItem(btn, WoWTools_SC_ItemCacheIndex or 1, 0, 0)
        end


        table.insert(Buttons, name)
    end






    Init=function()end
end






EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
    if arg1~='WoWTools_Chinese_Scanner' then
        return
    end

    WoWTools_SC_Spell = WoWTools_SC_Spell or {}

    WoWTools_SC_ItemCacheIndex= WoWTools_SC_ItemCacheIndex or 1
    WoWTools_SC_Item = WoWTools_SC_Item or {}

    WoWTools_SC_Unit = WoWTools_SC_Unit or {}

    WoWTools_SC_Achivement = WoWTools_SC_Achivement or {}

    WoWTools_SC_QuestCacheIndex= WoWTools_SC_QuestCacheIndex or 1
    WoWTools_SC_Quest = WoWTools_SC_Quest or {}

    WoWTools_SC_Encounter= WoWTools_SC_Encounter or {}

    WoWTools_SC_SectionEncounter= WoWTools_SC_SectionEncounter or {}

    Init()

    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)









--[[


local AchivementTooltip = CreateFrame("GameTooltip", nil, UIParent, "GameTooltipTemplate")
AchivementTooltip:SetFrameStrata("TOOLTIP")
function AchivementTooltip:Get_Lines(...)
    local t
    for i = 1, select("#", ...) do
        local text= GetLineText(select(i, ...))
        if text then
            print(text)
            t= (t and t..'|n' or '')..text
        end
    end
    return t
end

local function S_Achivement(self, startIndex, attempt, counter)
    if self.isStop then
        local va= startIndex/25000*100
        self.Value:SetFormattedText('暂停, %d, %.1f%%', startIndex, va)
        self.bar:SetValue(va)
        self.Name:SetText(self.name)
        return

    elseif (startIndex > 30000) then
        self.bar:SetValue(100)
        self.Value:SetFormattedText('|cffff00ff结束, %d条', self.num)
        self.bar:SetValue(0)
        self.Name:SetText(self.name)
        WoWTools_SC_AchivementIndex = nil
        self:settings()
        self.num= 0
        return
    end
    for achievementID = startIndex, startIndex + 150 do
        AchivementTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        AchivementTooltip:ClearLines()
        AchivementTooltip:SetHyperlink('achievement:' .. achievementID .. ':0:0:0:0:0:0:0:0')
        AchivementTooltip:Show()
        local text = AchivementTooltip:Get_Lines(AchivementTooltip:GetRegions())
        if text and (WoWTools_SC_Achivement0[achievementID .. ''] == nil or string.len(WoWTools_SC_Achivement0[achievementID .. '']) < string.len(text)) then
            WoWTools_SC_Achivement0[achievementID .. ''] = text
            self.num= self.num+1
            self.Name:SetText(GetAchievementLink(achievementID) or ('achievementID'..achievementID))
            print(text)
        end
    end

    WoWTools_SC_AchivementIndex = startIndex

    if (counter >= 5) then
        --SC_Wait(0.3, S_Achivement, startIndex + 150, attempt + 1, 0)
        C_Timer.After(0.3, function() S_Achivement(self, startIndex + 150, attempt + 1, 0) end)
    else
        --SC_Wait(0.5, S_Achivement, startIndex, attempt + 1, counter + 1)
        C_Timer.After(0.3, function() S_Achivement(self, startIndex, attempt + 1, counter + 1) end)
    end
end
]]

