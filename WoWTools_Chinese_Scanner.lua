local Ver= GetBuildInfo()
local GameVer= math.modf(select(4, GetBuildInfo())/10000)--11

local MaxAchievementID= (GameVer-4)*10000-- 11.2.5 版本，最高61406 https://wago.tools/db2/Achievement
local MaxQuestID= GameVer*10000 --11.2.5 版本 93516
local MaxEncounterID= 25000
local MaxSectionEncounterID= 50000

local MaxUnitID= (GameVer-8)*100000--300000 11.25 最高 254359 https://wago.tools/db2/Creature
local MaxItemID= (GameVer-8)*100000--3000000 11.2.5 最高 258483  https://wago.tools/db2/Item
local MaxSpellID=(GameVer-6)*100000-- 500000

local Frame
local Buttons={}

local function Save()
    return WoWTools_SC
end



--[[


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
        self.Value:SetFormattedText(
            '|cffff8200暂停, %d条, %.1f%%',
            startIndex,
            startIndex/maxID*100
        )
        self.Name:SetText(self.name)
        return true

    elseif (startIndex > maxID) then
        self.bar:SetValue(100)
        local clock= SecondsToClock(GetTime()-self.time)
        self.Value:SetFormattedText(
            '|cffff00ff完成|r, %d条, %s',
            self.num,
            clock
        )
        self.Name:SetText(self.name)
        Save()[self.name] = nil
        Save()[self.name..'Ver']= Ver
        Save()[self.name..'Time']= clock
        self:settings()
        self.num= 0
        return true
    end
end
local function Set_ValueText(self, startIndex, maxID)
    Save()[self.name] = startIndex
    local va= startIndex/maxID*100
    self.Value:SetFormattedText(
        '%s, %d条, %.1f%%',
        SecondsToClock(GetTime()-self.time),
        self.num,
        va
    )
    self.bar:SetValue(va)
end

local function Is_StopCahceRun(self, startIndex, maxID)
    if self.isCahceStop then
        self.Name:SetText('|cffff0000停止|r, 获取“'..self.name..'”数据')
        self.bar2:Hide()
        self.bar2:SetValue(0)
        return true

    elseif (startIndex > maxID) then
        self.Name:SetText('获取“'..self.name..'” 数据 |cnGREEN_FONT_COLOR:完成')
        self.bar2:SetValue(0)
        self.bar2:Hide()
        Save()[self.name..'Cache']= nil
        Save()[self.name..'CacheTime']= SecondsToClock(GetTime()-self.cahceTime)
        self.isCahceStop= true
        self.cahce:settings()
        return true
    end
end


























--Encounter [字符journalEncounterID]= {T=, D=}
local function Save_Encounter(self, journalEncounterID)
    local name, desc
    local n, d, _, _, link = EJ_GetEncounterInfo(journalEncounterID)
    if IsCN(n) then
        name= n
    end
    if IsCN(d) then
        desc= d
    end
    if name or desc then
        WoWTools_SC_Encounter[tostring(journalEncounterID)] = {
            ['T']=name,
            ['D']=desc
        }
        self.num= self.num+1
        return link or name
    end
end

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

do
    for journalEncounterID = startIndex, startIndex + 100 do
        local link= Save_Encounter(self, journalEncounterID)
        if link then
            self.Name:SetText(link)
        end
    end
end

    Set_ValueText(self, startIndex, MaxEncounterID)
    Save()[self.name] = startIndex

    if (counter >= 2) then
        C_Timer.After(0.1, function() S_Encounter(self, startIndex + 100, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_Encounter(self, startIndex, attempt + 1, counter + 1) end)
    end
end

























--EncounterSection [字符sectionIDxdifficultyID]= {T=, D=}
local function Save_SectionEncounter(self, sectionID, difficultyID)
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
        return sectionID.link or sectionInfo.title
    end
end

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
            local link= Save_SectionEncounter(self, sectionID, difficultyID)
            if link then
                self.Name:SetText(link)
            end
        end
    end
end

    Set_ValueText(self, startIndex, MaxSectionEncounterID)
    Save()[self.name] = startIndex

    if (counter >= 2) then
        C_Timer.After(0.1, function() S_SectionEncounter(self, startIndex + 100, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_SectionEncounter(self, startIndex, attempt + 1, counter + 1) end)
    end
end











































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

--Unit 单位 [字符unitID]={T=, D=}
--C_TooltipInfo.GetHyperlink('unit:Creature-0-0-0-0-2748-0000000000')
local function Save_Unit(self, unit)--字符
    local va= math.modf(unit/100000)
    va= math.min(2, va)

    local id= tostring(unit)
    if _G['WoWTools_SC_Unit'..va][id] then
        self.num= self.num+1
        return _G['WoWTools_SC_Unit'..va][id].T

    else
        local tab = Get_Unit_Tab(unit)
        if tab then
            _G['WoWTools_SC_Unit'..va][id] = tab
            self.num= self.num+1
            return tab.T

        end
    end
end
local function S_Unit(self, startIndex, attempt, counter)
    if Is_StopRun(self, startIndex, MaxUnitID) then
        return
    end

do
    for unit = startIndex, startIndex + 250 do
        local title= Save_Unit(self, unit)
        if title then
            self.Name:SetText(title)
        end
    end
end

    Set_ValueText(self, startIndex, MaxUnitID)
    Save()[self.name] = startIndex

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
    if Is_StopCahceRun(self, startIndex, MaxItemID) then
        return
    end

    do
        for itemID = startIndex, startIndex + 150 do
            Cahce_Item(itemID)
            self.bar2:SetValue(itemID/MaxItemID*100)
            self.bar2:SetShown(true)
        end
    end

    Save()[self.name..'Cache']= startIndex

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

--Item 物品[字符itemID]={T=, D=}
local function Save_Item(self, itemID)--字符

    local va= math.modf(itemID/100000)
    va= math.min(2, va)

    local id= tostring(itemID)
    if _G['WoWTools_SC_Item'..va][id] then
        self.num= self.num+1
        return true
    else
        local tab = Get_Item_Tab(itemID)
        if tab then
            _G['WoWTools_SC_Item'..va][id] = tab
            self.num= self.num+1
            return true
        end
    end
end


local function S_Item(self, startIndex, attempt, counter)
    if Is_StopRun(self, startIndex, MaxItemID) then
        return
    end
do
    for itemID = startIndex, startIndex + 150 do
        if Cahce_Item(itemID) and Save_Item(self, itemID) then
            self.Name:SetText(select(2, C_Item.GetItemInfo(itemID)) or ('itemID '..itemID))
        end
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
    self:SetScript('OnEvent', function(_, _, itemID, success)
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
    if Is_StopCahceRun(self, startIndex, MaxQuestID) then
        return
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
            if IsCN(t) then
                tab[index]= t
                find=true
            end
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
--任务 [字符questID]={T=, O= S={}}
local function Save_Quest(self, questID)
    local id= tostring(questID)

    if WoWTools_SC_Quest[id] then
        self.num= self.num+1
        return true
    else
        local tab = Get_Quest_Tab(questID)
        if tab then
            WoWTools_SC_Quest[id] = tab
            self.num= self.num+1
            return true
        end
    end
end

local function S_Quest(self, startIndex, attempt, counter)
    if Is_StopRun(self, startIndex, MaxQuestID) then
        return
    end

do
    for questID = startIndex, startIndex + 100 do
        if Cahce_Quest(questID) and Save_Quest(self, questID) then
            self.Name:SetText(C_QuestLog.GetTitleForQuestID(questID) or ('questID '..questID))
        end
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
    self:SetScript('OnEvent', function(_, _, questID, success)
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
    if Is_StopCahceRun(self, startIndex, MaxSpellID) then
        return
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

--法术 [字符spellID]={T=, D=}
local function Save_Spell(self, spellID)
    local va= math.modf(spellID/100000)
    va= math.min(4, va)

    local id= tostring(spellID)

    if _G['WoWTools_SC_Spell'..va][id] then
        self.num= self.num+1
        return true
    else
        local tab = Get_Spell_Tab(spellID)
        if tab then
            _G['WoWTools_SC_Spell'..va][id] = tab
            self.num= self.num+1
            return true
        end
    end
end


local function S_Spell(self, startIndex, attempt, counter)
    if Is_StopRun(self, startIndex, MaxSpellID) then
        return
    end

do
    for spellID = startIndex, startIndex + 150 do
        if Cahce_Spell(spellID) and Save_Spell(self, spellID) then
            self.Name:SetText(C_Spell.GetSpellLink(spellID) or ('SpellID '..spellID))
        end
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
    self:SetScript('OnEvent', function(_, _, spellID, success)
        if spellID and success then
            Save_Spell(self, spellID)
        end
    end)
end























local function Cahce_Achievement(achievementID)
    GetAchievementInfo(achievementID)
end

local function S_CacheAchievement(self, startIndex, attempt, counter)
    if Is_StopCahceRun(self, startIndex, MaxAchievementID) then
        return
    end

    do
        for AchievementID = startIndex, startIndex + 150 do
            Cahce_Achievement(AchievementID)
            self.bar2:SetValue(AchievementID/MaxAchievementID*100)
            self.bar2:SetShown(true)
        end
    end

    Save()[self.name..'Cache']= startIndex

    if (counter >= 5) then
        C_Timer.After(0.1, function() S_CacheAchievement(self, startIndex + 150, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_CacheAchievement(self, startIndex, attempt + 1, counter + 1) end)
    end
end

local function Get_Achievement_Tab(achievementID)
    local _, title, _, _, _, _, _, desc, _, _, reward = GetAchievementInfo(achievementID)
    if IsCN(title) then
        local d,r
        if IsCN(desc) then
            d= desc--概述
        end
        if IsCN(reward) then
            r= reward--奖励
        end
        local s, find
        local numCriteria= GetAchievementNumCriteria(achievementID) or 0--条件
        if numCriteria>0 then
            local t={}
            for index = 1, numCriteria do
                local criteriaString = GetAchievementCriteriaInfo(achievementID, index)
                if IsCN(criteriaString) then
                    t[index]= criteriaString
                    find= true
                end
            end
            if find then
                s= t
            end
        end
        return {
            ['T']= title,
            ['D']= d,
            ['R']= r,
            ['S']= s,
        }
    end
end


local function Save_Achievement(self, achievementID)
    local id= tostring(achievementID)

    if WoWTools_SC_Achievement[id] then
        self.num= self.num+1
        return true
    else
        local tab = Get_Achievement_Tab(achievementID)
        if tab then
            WoWTools_SC_Achievement[id] = tab
            self.num= self.num+1
            return true
        end
    end
end


local function S_Achievement(self, startIndex, attempt, counter)
    if Is_StopRun(self, startIndex, MaxAchievementID) then
        return
    end

do
    for achievementID = startIndex, startIndex + 150 do
        Cahce_Achievement(achievementID)
        if Save_Achievement(self, achievementID) then
            self.Name:SetText(
                C_Spell.GetSpellLink(achievementID)
                or select(2, GetAchievementInfo(achievementID))
                or ('AchievementID '..achievementID)
            )
        end
    end
end

    Set_ValueText(self, startIndex, MaxAchievementID)

    if (counter >= 5) then
        C_Timer.After(0.1, function() S_Achievement(self, startIndex + 150, attempt + 1, 0) end)
    else
        C_Timer.After(0.1, function() S_Achievement(self, startIndex, attempt + 1, counter + 1) end)
    end
end






























local function clear_data(name)
    Save()[name]= nil
    Save()[name..'Cache']= nil
    Save()[name..'Ver']= nil

    if name=='Item' or name=='Unit' then
        for va =0, 2 do
            _G['WoWTools_SC_'..name..va] = {}
        end
    elseif name=='Spell' then
        for va =0, 4 do
            _G['WoWTools_SC_Spell'..va] = {}
        end
    else
        _G['WoWTools_SC_'..name]= {}
    end

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
    text = '你确定要|n清除 |cnGREEN_FONT_COLOR:%s|r 数据 吗？%s',
    button1 = '确定', button2 = '取消',
    whileDead=true, hideOnEscape=true, exclusive=true, showAlert=true, acceptDelay=1,
    OnAccept=function(_, data)
        if data then
            clear_data(data)
        else
            do
                for _, name in pairs(Buttons) do
                    clear_data(name)
                end
            end
            C_UI.Reload()
        end
    end
}













local y= -70
local function Create_Button(name, tab)
    local btn= CreateFrame('Button', 'WoWToolsSC'..name..'Button', Frame)

    btn.name= name
    btn.func= tab.func
    btn.cahceFunc= tab.cahce

    btn:SetNormalAtlas('common-dropdown-icon-next')
    btn:SetPushedAtlas('PetList-ButtonSelect')
    btn:SetHighlightAtlas('PetList-ButtonHighlight')
    btn:SetSize(23, 23)
    btn:SetPoint('TOPRIGHT', -70, y)
    btn:SetScript('OnLeave', function() GameTooltip:Hide() end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:SetText((self.isStop and '运行' or '暂停').. ' '..self.name)
        local clock= Save()[self.name..'Time']
        if clock then
            GameTooltip:AddLine('需要时间：'..clock)
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine('运行前，请关闭所有插件')
        if not LOCALE_zhCN then
            GameTooltip:AddLine('|cnGREEN_FONT_COLOR:需求 简体中文')
        end
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
    btn.bar:SetSize(Frame:GetWidth()-48-23*3, 18)
    btn.bar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOff-Bar-Focus')
    btn.bar:SetAlpha(0.8)
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
    btn.clear:SetPoint('LEFT', btn, 'RIGHT', 26, 0)
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
        StaticPopup_Show('WoWTools_SC', n, '', n)
    end)

    if btn.cahceFunc then
        btn.cahce= CreateFrame('Button', nil, btn)
        btn.cahce:SetPushedAtlas('PetList-ButtonSelect')
        btn.cahce:SetHighlightAtlas('PetList-ButtonHighlight')
        btn.cahce:SetPoint('LEFT', btn, 'RIGHT', -2, 0)
        btn.cahce:SetSize(23,23)
        btn.cahce.name= name
        function btn.cahce:set_tooltip()
            local p= self:GetParent()
            GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
            GameTooltip:SetText((p.isCahceStop and '|cff626262' or '|cnGREEN_FONT_COLOR:')..'加载数据 '..self.name)
            local clock= Save()[self.name..'CacheTime']
            if clock then
                GameTooltip:AddLine('需要时间：'..clock)
            end
            if p.cahceTime then
                GameTooltip:AddLine('已运行：'..SecondsToClock(GetTime()-p.cahceTime))
            end

            GameTooltip:Show()
        end
        btn.cahce:SetScript('OnLeave', function() GameTooltip:Hide() end)
        btn.cahce:SetScript('OnEnter', function(self)
           self:set_tooltip()
        end)
        function btn.cahce:settings()
---@diagnostic disable-next-line: undefined-field
            if not self:GetParent().isCahceStop then
                self:SetNormalAtlas('Perks-PreviewOn')
            else
                self:SetNormalAtlas('Perks-PreviewOff-Hover')
            end
        end
        btn.isCahceStop= true
        btn.cahce:settings()
        btn.cahce:SetScript('OnMouseDown', function(b)
            local self= b:GetParent()
            self.isCahceStop= not self.isCahceStop and true or false
            self:cahceFunc()
            self.cahceTime= not self.isCahceStop and GetTime() or nil
            b:settings()
            b:set_tooltip()
        end)
    end

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
    Frame:SetSize(520, 450)
    Frame:SetPoint('CENTER')
    Frame:RegisterEvent('PLAYER_REGEN_DISABLED')
    Frame:RegisterUnitEvent('PLAYER_FLAGS_CHANGED', 'player')
    Frame:SetScript('OnEvent', function(_, event)
        if event=='PLAYER_REGEN_DISABLED' then
            for _, name in pairs(Buttons) do
                local btn= _G['WoWToolsSC'..name..'Button']
                if not btn.isStop then
                    btn:settings()
                end
            end

        elseif UnitIsAFK('player') then
            C_MountJournal.SummonByID(0)
        end
    end)

    Frame:SetMovable(true)
    Frame:RegisterForDrag("LeftButton", "RightButton")
    Frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    Frame:SetScript("OnDragStop", function(self) ResetCursor() self:StopMovingOrSizing() end)
    Frame:SetScript("OnMouseDown", function() SetCursor('UI_MOVE_CURSOR') end)
    Frame:SetScript("OnMouseUp", function() ResetCursor() end)
    Frame:SetScript("OnLeave", function() ResetCursor() end)

    Frame.Border= CreateFrame('Frame', nil, Frame, 'DialogBorderTemplate')
    Frame.CloseButton=CreateFrame('Button', 'WoWTools_SC_FrameCloseButton', Frame, 'UIPanelCloseButton')--SharedUIPanelTemplates.xml
    Frame.CloseButton:SetPoint('TOPRIGHT')
    Frame.Header= CreateFrame('Frame', nil, Frame, 'DialogHeaderTemplate')--DialogHeaderMixin
    Frame.Header:Setup(
        '|TInterface\\AddOns\\WoWTools_Chinese_Scanner\\Source\\WoWtools.tga:0:0|t'
        ..'|cffff00ffWoW|r|cff00ff00Tools|r_|cff28a3ffChinese|r_数据扫描'
    )
    
    local note= Frame:CreateFontString(nil, "OVERLAY")
    note:SetFontObject('GameFontNormal')
    note:SetPoint('BOTTOM', 0, 12)
    note:SetText(
        '当前游戏版本 '
        ..Ver
        ..(LOCALE_zhCN and '' or '|n|cnRED_FONT_COLOR:需求 简体中文')
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
        StaticPopup_Show('WoWTools_SC', '全部', '|n|n|cnGREEN_FONT_COLOR:重新加载UI', nil)
    end)


    local reload= CreateFrame('Button', 'WoWToolsSCReloadButton', Frame, 'GameMenuButtonTemplate')
    reload:SetText('重新加载UI')
    reload:SetScript('OnClick', C_UI.Reload)
    reload:SetPoint('BOTTOMRIGHT', -12, 32)

    for name, tab in pairs({
        ['Encounter']= {func=S_Encounter},
        ['SectionEncounter']= {func=S_SectionEncounter},
        ['Unit']= {func=S_Unit},
        ['Quest']= {func=S_Quest, cahce=function(self)
            Set_Quest_Event(self)
            S_CacheQuest(self, Save()[self.name..'Cache'], 0, 0)
        end},
        ['Item']= {func=S_Item, cahce=function(self)
            Set_Item_Event(self)
            S_CacheItem(self, Save()[self.name..'Cache'], 0, 0)
        end},
        ['Spell']= {func=S_Spell, cahce=function(self)
            Set_Spell_Event(self)
            S_CacheSpell(self, Save()[self.name..'Cache'], 0, 0)
        end},
        ['Achievement']= {func=S_Achievement, cahce=function(self)
            S_CacheAchievement(self, Save()[self.name..'Cache'], 0, 0)
        end},
    }) do
        Create_Button(name, tab)

        table.insert(Buttons, name)
    end


    if not InCombatLockdown() then
        if not CollectionsJournal then
            CollectionsJournal_LoadUI()
        end

        if not PlayerSpellsFrame then
            PlayerSpellsFrame_LoadUI();
        end

        if not AchievementFrame then
            AchievementFrame_LoadUI()
        end

        if not EncounterJournal then
            EncounterJournal_LoadUI()
        end
    end


    Init=function()end
end













EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
    if arg1~='WoWTools_Chinese_Scanner' then
        return
    end

    WoWTools_SC= WoWTools_SC or {}

    Save().QuestCache=  Save().QuestCache or 1
    Save().ItemCache=  Save().ItemCache or 1
    Save().SpellCache=  Save().SpellCache or 1
    Save().AchievementCache=  Save().AchievementCache or 1

    WoWTools_SC_Spell = WoWTools_SC_Spell or {}
    WoWTools_SC_Achievement = WoWTools_SC_Achievement or {}
    WoWTools_SC_Quest = WoWTools_SC_Quest or {}
    WoWTools_SC_Encounter= WoWTools_SC_Encounter or {}
    WoWTools_SC_SectionEncounter= WoWTools_SC_SectionEncounter or {}

    for va=0, 2 do
        _G['WoWTools_SC_Item'..va] = _G['WoWTools_SC_Item'..va] or {}
        _G['WoWTools_SC_Unit'..va] = _G['WoWTools_SC_Unit'..va] or {}
    end
    for va=0, 4 do
         _G['WoWTools_SC_Spell'..va] = _G['WoWTools_SC_Spell'..va] or {}
    end

    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)



EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)
    Init()
    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)