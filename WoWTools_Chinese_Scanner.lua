local Ver= GetBuildInfo()
local GameVer= math.modf(select(4, GetBuildInfo())/10000)--11

local MaxEncounterID= 25000
local MaxSectionEncounterID= 50000
local MaxQuestID= GameVer*10000 --11.2.5 版本 93516
local MaxUnitID= 300000
local MaxItemID= 300000
local MaxSpellID= 500000

local Frame
local Buttons={}

local function Save()
    return WoWTools_SC
end



--[[

local MaxAchivementID= (GameVer-4)*10000-- 11.2.5 版本，最高61406 https://wago.tools/db2/Achievement
]]

--[[
( ) . % + - * ? [ ^ $
ID, --Name_lang
https://wago.tools/db2/Difficulty?locale=zhCN
]]


local DifficultyTab={
236, --游学探奇
232, --事件
230, --英雄
220, --剧情
216, --任务
208, --地下堡
205, --追随者
192, --挑战难度1
172, --世界首领
171, --晋升之路：谦逊
170, --晋升之路：智慧
169, --晋升之路：忠诚
168, --晋升之路：勇气
167, --托加斯特
153, --繁盛海岛
152, --恩佐斯的幻象
151, --随机
150, --普通调整（1-5）
149, --英雄
147, --普通
45, --PvP
40, --史诗
39, --英雄
38, --普通
34, --PvP
33, --时空漫游
32, --世界PvP场景战役
30, --事件
29, --PvEvP场景战役
25, --世界PvP场景战役
24, --时空漫游
23, --史诗
20, --事件场景战役
19, --事件
18, --事件
17, --随机
16, --史诗
15, --英雄
14, --普通
12, --场景战役（普通）
11, --场景战役（英雄）
9, --40人
8, --史诗钥石
7, --随机
6, --25人（英雄）
5, --10人（英雄）
4, --25人
3, --10人
2, --英雄
1, --普通
}

local ReceString={
    [ERR_TRAVEL_PASS_NO_INFO] = 1,--正在获取信息……
    [RETRIEVING_ITEM_INFO] = 1,--正在获取物品信息
    [RETRIEVING_TRADESKILL_INFO] = 1,--正在获取信息
    ['要求：']=1,
    ['暂无信息']=1,
}
local function IsCN(text)
    return
        text
        and text:find('[\228-\233]')
        and not text:find('DNT')
        and not text:find('UNUSED')
        and not ReceString[text]
end
local function Is_StopRun(self, startIndex, maxID)
    if self.isStop then
        self.Value:SetFormattedText('|cffff8200暂停, %d条, %.1f%%', startIndex, startIndex/maxID*100)
        self.Name:SetText(self.name)
        return true

    elseif (startIndex > maxID) then
        self.bar:SetValue(100)
        self.Value:SetFormattedText('|cffff00ff结束|r, %d条', self.num)
        self.Name:SetText(self.name)
        Save()[self.name] = nil
        Save()[self.name..'Ver']= Ver
        self:settings()
        self.num= 0
        return true
    end
end
local function Set_ValueText(self, startIndex, maxID)
    Save()[self.name] = startIndex
    local va= startIndex/maxID*100
    self.Value:SetFormattedText('%s   %d条 %.1f%%', SecondsToClock((GetTime()-self.time), false), self.num, va)
    self.bar:SetValue(va)
end


















--[[
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

]]


















































































































local function S_Encounter(self, startIndex, attempt, counter)
    if self.isStop then
        self.Value:SetFormattedText('|cffff8200暂停|r, %d, %.1f%%', startIndex, startIndex/MaxEncounterID*100)
        self.Name:SetText(self.name)
        return

    elseif (startIndex > MaxEncounterID) then
        self.bar:SetValue(100)
        self.Value:SetFormattedText('|cffff00ff结束|r, %d条', self.num)
        self.Name:SetText(self.name)
        Save()[self.name] = nil
        Save()[self.name..'Ver']= Ver
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

    Set_ValueText(self, startIndex, MaxEncounterID)

    if (counter >= 2) then
        C_Timer.After(0.1, function() S_Encounter(self, startIndex + 100, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_Encounter(self, startIndex, attempt + 1, counter + 1) end)
    end
end

























--EncounterSection
local function S_SectionEncounter(self, startIndex, attempt, counter)
    if Is_StopRun(self, startIndex, MaxSectionEncounterID) then
        return
    end

    do
        for _, difficultyID in pairs(DifficultyTab) do
            --if GetDifficultyInfo(index) then
            do
                EJ_SetDifficulty(difficultyID)
            end
            for sectionID = startIndex, startIndex + 100 do
                local sectionInfo =  C_EncounterJournal.GetSectionInfo(sectionID)
                if sectionInfo and not sectionInfo.filteredByDifficulty and IsCN(sectionInfo.title) then
                    local desc
                    if IsCN(sectionInfo.description) then
                        desc= sectionInfo.description
                    end
                    WoWTools_SC_SectionEncounter[sectionID..'x'..difficultyID] = {
                        ['T']= sectionInfo.title,
                        ['D']= desc
                    }
                    self.num= self.num+1
                    self.Name:SetText(sectionInfo.link or sectionInfo.title or '')
                end
            end
        end
    end

    Set_ValueText(self, startIndex, MaxSectionEncounterID)

    Save().SectionEncounter = startIndex

    if (counter >= 2) then
        C_Timer.After(0.1, function() S_SectionEncounter(self, startIndex + 100, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_SectionEncounter(self, startIndex, attempt + 1, counter + 1) end)
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
    if Is_StopRun(self, startIndex, MaxUnitID) then
        return
    end

    for unit = startIndex, startIndex + 250 do
        local tab= Get_Unit_Tab(unit)
        if tab then
            WoWTools_SC_Unit[format('%d', unit)] = tab--字母， 如果数字，输出表格会出现很多nil
            self.num= self.num+1
            self.Name:SetText(tab.T)
        end
    end

    Set_ValueText(self, startIndex, MaxUnitID)

    if (counter >= 3) then
        C_Timer.After(0.1, function() S_Unit(self, startIndex + 250, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_Unit(self, startIndex, attempt + 1, counter + 1) end)
    end
end
























local function Cahce_Item(itemID)
    if C_Item.GetItemInfoInstant(itemID) then
        if not C_Item.IsItemDataCachedByID(itemID) then
            C_Item.RequestLoadItemDataByID(itemID)
        else
            return true
        end
    end
end

local function S_CacheItem(self, startIndex, attempt, counter)
    if not Save()[self.name..'Cache'] then
        self.Name:SetText('|cffff0000停止|r, 获取“'..self.name..'”数据')
        self.bar2:Hide()
        return

    elseif (startIndex > MaxSpellID) then
        self.Name:SetText('获取“'..self.name..'” 数据 |cnGREEN_FONT_COLOR:完成')
        self.bar2:SetValue(0)
        self.bar2:Hide()
        Save()[self.name]=nil
        return

    elseif startIndex==1 then
        self.Name:SetText('正在获取“'..self.name..'”数据')
    end

    do
        for itemID = startIndex, startIndex + 150 do
            Cahce_Item(itemID)
            self.bar2:SetValue(itemID/MaxItemID*100)
            self.bar2:SetShown(true)
        end
    end

    Save().ItemCache= startIndex

    if (counter >= 5) then
        C_Timer.After(0.1, function() S_CacheItem(self, startIndex + 150, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_CacheItem(self, startIndex, attempt + 1, counter + 1) end)
    end
end

--[[
C_TooltipInfo.GetHyperlink('item:207786:0:0:0:0:0:0:0')
C_Item.IsItemDataCachedByID(207786)
C_Item.RequestLoadItemDataByID(207786)
]]
local function Get_Item_Tab(itemID)
    local data= C_TooltipInfo.GetHyperlink('item:'..itemID..':0:0:0:0:0:0:0')
    if not data
        or not data.lines
        or not data.lines[1]
        or not IsCN(data.lines[1].leftText)
    then
        return
    end

    local title= C_Item.GetItemInfo(itemID) or data.lines[1].leftText
    local desc
    for index, line in pairs(data.lines) do
        local text= line.leftText
        if index>1 and IsCN(text) and (
            text:find('%(%d+%) 套装：.+')
            or text:find('^使用：')
            or text:find('^击中时可能：')
            or text:find('^装备：')
            or text:find('^需要：')
            or text:find('^".+"$')
            --or text:find('^用于：')
            or text:find('|cff......')
        )
        then
            desc= (desc and desc..'|n' or '')..(text:match('"(.+)"') or text)
        end
    end

    return {
        ['T']= title,
        ['D']= desc,
    }
end


local function Save_Item(self, id)--字符
    local itemID= format('%d', id)

    if WoWTools_SC_Item[itemID] then
        self.num= self.num+1
        return true
    else
        local tab = Get_Item_Tab(itemID)
        if tab then
            WoWTools_SC_Item[itemID] = tab
            self.num= self.num+1
            return true
        end
    end
end


local function S_Item(self, startIndex, attempt, counter)
    if Is_StopRun(self, startIndex, MaxItemID) then
        return
    end

    for itemID = startIndex, startIndex + 150 do
        if Cahce_Item(itemID) and Save_Item(self, itemID) then
            self.Name:SetText(select(2, C_Item.GetItemInfo(itemID)) or ('itemID '..itemID))
        end
    end

    Set_ValueText(self, startIndex, MaxItemID)

    if (counter >= 5) then
        C_Timer.After(0.1, function() S_Item(self, startIndex + 150, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_Item(self, startIndex, attempt + 1, counter + 1) end)
    end
end

local function Set_Item_Event(self)
    self:RegisterEvent('ITEM_DATA_LOAD_RESULT')
    self:SetScript('OnEvent', function(_, itemID, success)
        if itemID and success then
            Save_Item(self, itemID)
        end
    end)
end
































--任务
local function Cahce_Quest(questID)
        if not HaveQuestData(questID) then
            C_QuestLog.RequestLoadQuestByID(questID)
        else
            return true
        end
end
local function S_CacheQuest(self, startIndex, attempt, counter)
    if not Save()[self.name..'Cache'] then
        self.Name:SetText('|cffff0000停止|r, 获取“'..self.name..'”数据')
        self.bar2:Hide()
        return

    elseif (startIndex > MaxSpellID) then
        self.Name:SetText('获取“'..self.name..'” 数据 |cnGREEN_FONT_COLOR:完成')
        self.bar2:SetValue(0)
        self.bar2:Hide()
        Save()[self.name]=nil
        return

    elseif startIndex==1 then
        self.Name:SetText('正在获取“'..self.name..'”数据')
    end

    do
        for questID = startIndex, startIndex + 150 do
            Cahce_Quest(questID)
            self.bar2:SetValue(questID/MaxQuestID*100)
            self.bar2:SetShown(true)
        end
    end

    Save()[self.name..'Cache']= startIndex
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
            tab[index]= t
            find=true
        end
    end
    if find then
        return tab
    end
end

local function Get_Quest_Tab(questID)
    local data= C_TooltipInfo.GetHyperlink('quest:' .. questID)
    if not data or
        not data.lines
        or not data.lines[1]
        or not IsCN(data.lines[1].leftText)
    then
        return
    end
    local title= C_QuestLog.GetTitleForQuestID(questID) or data.lines[1].leftText
    local obj
    if data.lines[3] and IsCN(data.lines[3].leftText) then
        obj= data.lines[3].leftText
    end
    return {
        ['T']= title,
        ['O']= obj,
        ['S']= Get_Objectives(questID),
    }
end

local function Save_Quest(self, questID)
    if WoWTools_SC_Quest[questID] then
        self.num= self.num+1
        return true
    else
        local tab = Get_Quest_Tab(questID)
        if tab then
            WoWTools_SC_Quest[questID] = tab
            self.num= self.num+1
            return true
        end
    end
end

local function S_Quest(self, startIndex, attempt, counter)
    if Is_StopRun(self, startIndex, MaxQuestID) then
        return
    end

    for questID = startIndex, startIndex + 100 do
        if Cahce_Quest(questID) and Save_Quest(self, questID) then
            self.Name:SetText(C_QuestLog.GetTitleForQuestID(questID) or ('questID '..questID))
        end
    end

    Set_ValueText(self, startIndex, MaxQuestID)

    if (counter >= 5) then
        C_Timer.After(0.1, function() S_Quest(self, startIndex + 100, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_Quest(self, startIndex, attempt + 1, counter + 1) end)
    end
end


local function Set_Quest_Event(self)
    self:RegisterEvent('QUEST_DATA_LOAD_RESULT')
    self:SetScript('OnEvent', function(_, questID, success)
        if questID and success then
            Save_Quest(self, questID)
        end
    end)
end


























local function Cahce_Spell(spellID)
    if not C_Spell.IsSpellDataCached(spellID) then
        C_Spell.RequestLoadSpellData(spellID)
    else
        return true
    end
end

local function S_CacheSpell(self, startIndex, attempt, counter)
    if not Save()[self.name..'Cache'] then
        self.Name:SetText('|cffff0000停止|r, 获取“'..self.name..'”数据')
        self.bar2:Hide()
        return

    elseif (startIndex > MaxSpellID) then
        self.Name:SetText('获取“'..self.name..'” 数据 |cnGREEN_FONT_COLOR:完成')
        self.bar2:SetValue(0)
        self.bar2:Hide()
        Save()[self.name]=nil
        return

    elseif startIndex==1 then
        self.Name:SetText('正在获取“'..self.name..'”数据')
    end

    do
        for spellID = startIndex, startIndex + 150 do
            Cahce_Spell(spellID)
            self.bar2:SetValue(spellID/MaxSpellID*100)
            self.bar2:SetShown(true)
        end
    end

    Save()[self.name..'Cache']= startIndex
    if (counter >= 5) then
        C_Timer.After(0.1, function() S_CacheSpell(self, startIndex + 150, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_CacheSpell(self, startIndex, attempt + 1, counter + 1) end)
    end
end

--[[
--local data= C_TooltipInfo.GetHyperlink('spell:'.. spellID)
]]
local function Get_Spell_Tab(spellID)
    local title= C_Spell.GetSpellName(spellID)
    if IsCN(title) then
        local desc
        local d= C_Spell.GetSpellDescription(spellID)
        if IsCN(d) then
            desc= d
        end
        return {
            ['T']= title,
            ['D']= desc,
        }
    end
end


local function Save_Spell(self, spellID)
    if WoWTools_SC_Spell[spellID] then
        self.num= self.num+1
        return true
    else
        local tab = Get_Spell_Tab(spellID)
        if tab then
            WoWTools_SC_Spell[spellID] = tab
            self.num= self.num+1
            return true
        end
    end
end


local function S_Spell(self, startIndex, attempt, counter)
    if Is_StopRun(self, startIndex, MaxSpellID) then
        return
    end

    for spellID = startIndex, startIndex + 150 do
        if Cahce_Spell(spellID) and Save_Spell(self, spellID) then
            self.Name:SetText(C_Spell.GetSpellLink(spellID) or ('SpellID '..spellID))
        end
    end

    Set_ValueText(self, startIndex, MaxSpellID)

    if (counter >= 5) then
        C_Timer.After(0.1, function() S_Spell(self, startIndex + 150, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_Spell(self, startIndex, attempt + 1, counter + 1) end)
    end
end

local function Set_Spell_Event(self)
    self:RegisterEvent('SPELL_DATA_LOAD_RESULT')
    self:SetScript('OnEvent', function(_, spellID, success)
        if spellID and success then
            Save_Spell(self, spellID)
        end
    end)
end

































local function clear_data(name)
    Save()[name]= nil
    Save()[name..'Cache']= nil
    Save()[name..'Ver']= nil

    _G['WoWTools_SC_'..name]= {}

    local self= _G['WoWToolsSC'..name..'Button']
    if not self.isStop then
        self:settings()
    else
        self.time=nil
        self.Value:SetText('')
    end

    self.bar:SetValue(0)
    self.Value:SetText('')
    self.Ver:SetText('')


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
local function Create_Button(name, func)
    local btn= CreateFrame('Button', 'WoWToolsSC'..name..'Button', Frame)

    btn.name= name
    btn.func= func

    btn:SetNormalAtlas('common-dropdown-icon-next')
    btn:SetPushedAtlas('PetList-ButtonSelect')
    btn:SetHighlightAtlas('PetList-ButtonHighlight')
    btn:SetSize(23, 23)
    btn:SetPoint('TOPRIGHT', -45, y)
    btn:SetScript('OnLeave', function() GameTooltip:Hide() end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:SetText((self.isStop and '运行' or '暂停').. ' '..self.name)
        GameTooltip:Show()
    end)
    btn:SetScript('OnMouseDown', function(self)
        self:settings()
        if not self.isStop then
            self.func(self, Save()[self.name] or 1, 0, 0)
        end
    end)

    btn.bar= CreateFrame('StatusBar', nil, btn)
    btn.bar:SetPoint('RIGHT', btn, 'LEFT', -2, 0)
    btn.bar:SetSize(Frame:GetWidth()-48-23*2, 18)
    btn.bar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOff-Bar-Focus')
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
    btn.Value:SetFormattedText('%d', Save()[name] or 0)

    btn.Name= btn.bar:CreateFontString(nil, "OVERLAY")
    btn.Name:SetFontObject('GameFontWhite')
    btn.Name:SetPoint('LEFT', btn.bar)
    btn.Name:SetText(name)

    btn.Ver=  btn.bar:CreateFontString(nil, "OVERLAY")
    btn.Ver:SetFontObject("GameFontWhite")
    btn.Ver:SetPoint('CENTER', btn.bar)
    btn.Ver:EnableMouse(true)
    btn.Ver:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    btn.Ver:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:SetText(self:GetParent():GetParent().name..': 数据版本 '..self:GetText())
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

    btn.clear= CreateFrame('Button', nil, btn)
    btn.clear:SetNormalAtlas('bags-button-autosort-up')
    btn.clear:SetPushedAtlas('PetList-ButtonSelect')
    btn.clear:SetHighlightAtlas('PetList-ButtonHighlight')
    btn.clear:SetPoint('LEFT', btn, 'RIGHT', 2, 0)
    btn.clear:SetSize(23,23)
    btn.clear:SetScript('OnLeave', function() GameTooltip:Hide() end)
    btn.clear:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:SetText('清除 '..self:GetParent().name)
        GameTooltip:Show()
    end)
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

    function btn:settings()
        self.isStop= not self.isStop and true or nil
        if self.isStop then
            self.num= 0
            self:SetNormalAtlas('common-dropdown-icon-next')
            self.time=nil
        else
            self:SetNormalAtlas('common-dropdown-icon-stop')
            self.num= Save()[self.name] or 0
            self.time= GetTime()
        end
        self.Ver:SetText(Save()[self.name..'Ver'] or '')
    end
    btn:settings()

    y= y- 23- 8

    return btn
end













local function Init()

    Frame= CreateFrame('Frame', 'WoWTools_SC_Frame', UIParent)
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
    note:SetText(
        '当前游戏版本 '
        ..Ver
        ..'|n|cffffffff数据：|rWTF\\Account\\...\\SavedVariables\\WoWTools_Chinese_Scanner.lua'
    )



    local clear= CreateFrame('Button', 'WoWToolsSCClearDataButton', Frame, 'UIPanelButtonTemplate')
    clear:SetSize(180, 23)
    clear:SetPoint('TOP', Frame.Header, 'BOTTOM', 0, -10)
    clear:SetText('清除所有数据')
    clear:SetScript('OnMouseDown', function()
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


    local reload= CreateFrame('Button', 'WoWToolsSCReloadButton', Frame, 'GameMenuButtonTemplate')
    reload:SetText('重新加载UI')
    reload:SetScript('OnClick', C_UI.Reload)
    reload:SetPoint('BOTTOMRIGHT', -12, 32)

    for name, func in pairs({
        ['Encounter']= S_Encounter,
        ['SectionEncounter']= S_SectionEncounter,
        ['Quest']= S_Quest,
        ['Unit']= S_Unit,
        ['Item']= S_Item,
        ['Spell']= S_Spell,
    }) do
        local btn= Create_Button(name, func)
        if name=='Quest' then
            Set_Quest_Event(btn)
            S_CacheQuest(btn, Save()[name..'Cache'], 0, 0)

        elseif name=='Item' then
            Set_Item_Event(btn)
            S_CacheItem(btn, Save()[name..'Cache'], 0, 0)

        elseif name=='Spell' then
            Set_Spell_Event(btn)
            S_CacheSpell(btn, Save()[name..'Cache'], 0, 0)

        --elseif name=='SectionEncounter' then
            --Set_SectionEncounter_Event(btn)
        end


        table.insert(Buttons, name)
    end






    Init=function()
        Save().QuestCache=  Save().QuestCache or 1
        Save().ItemCache=  Save().ItemCache or 1
        Save().SpellCache=  Save().SpellCache or 1
        S_CacheQuest(_G['WoWToolsSCQuestButton'], Save().QuestCache, 0, 0)
        S_CacheItem(_G['WoWToolsSCItemButton'], Save().ItemCache, 0, 0)
        S_CacheQuest(_G['WoWToolsSCSpellButton'], Save().SpellCache, 0, 0)
    end
end






EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner)
    WoWTools_SC= WoWTools_SC or {}

    Save().QuestCache=  Save().QuestCache or 1
    Save().ItemCache=  Save().ItemCache or 1
    Save().SpellCache=  Save().SpellCache or 1

    WoWTools_SC_Spell = WoWTools_SC_Spell or {}
    WoWTools_SC_Item = WoWTools_SC_Item or {}
    WoWTools_SC_Unit = WoWTools_SC_Unit or {}
    WoWTools_SC_Achivement = WoWTools_SC_Achivement or {}
    WoWTools_SC_Quest = WoWTools_SC_Quest or {}
    WoWTools_SC_Encounter= WoWTools_SC_Encounter or {}
    WoWTools_SC_SectionEncounter= WoWTools_SC_SectionEncounter or {}

    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)



EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
    Init()
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

