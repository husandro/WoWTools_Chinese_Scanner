--[[
( ) . % + - * ? [ ^ $
C_TooltipInfo.GetHyperlink('spell:'.. spellID)
C_TooltipInfo.GetHyperlink('unit:Creature-0-0-0-0-'..unit..'-0000000000')
C_TooltipInfo.GetHyperlink('item:207786:0:0:0:0:0:0:0')
C_TooltipInfo.GetHyperlink('quest:' .. questID)
]]





local addName= '|TInterface\\AddOns\\WoWTools_Chinese_Scanner\\Source\\WoWtools.tga:0:0|t'..'|cffff00ffWoW|r|cff00ff00Tools|r|cff28a3ffChinese|r数据扫描'
local Ver= GetBuildInfo()
local GameVer= math.modf(select(4, GetBuildInfo())/10000)--11

local MaxAchievementID= (GameVer-4)*1e4--11.2.5 版本，最高61406 https://wago.tools/db2/Achievement
local MaxQuestID= GameVer*1e4--11.2.5 版本 93516
local MaxEncounterID= (GameVer-8)*1e4--25000


local MaxUnitID= (GameVer-8)*1e5--30w0000 11.25 最高 25w4359 https://wago.tools/db2/Creature
local MaxItemID= (GameVer-8)*1e5--30w0000 11.2.5 最高 25w8483  https://wago.tools/db2/Item
local MaxSpellID=(GameVer-6)*1e5-- 50w0000 229270

local MaxSpell2ID= (GameVer+2)*1e5--120w- 150w
local MinSpell2ID= 12*1e5

local MaxSectionEncounterID= (GameVer-7)*1e4--11.2.5版本，最高33986 https://wago.tools/db2/JournalEncounterSection

local Frame, MaxButtonLabel
local Buttons={}

local function Save()
    return WoWTools_SC
end



local function Save_Value(self, ID, count, tab)
    if tab and ID then
        _G['WoWTools_SC_'..self.name][tonumber(ID)] = tab
        if count==3 or not count then
            self.num= self.num+1
            self.Name:SetText(ID..' '..tab.T)
        end
    end
end



local ReceString={
    [ERR_TRAVEL_PASS_NO_INFO] = 1,--正在获取信息……
    [RETRIEVING_ITEM_INFO] = 1,--正在获取物品信息
    [RETRIEVING_TRADESKILL_INFO] = 1,--正在获取信息
    ['要求：']=1,
    ['暂无信息']=1,
    ['传承套装：套装奖励未激活']=1
}
local function IsCN(text)
    return
        text
        and text:find('[\228-\233]')
        and not text:find('DNT')
        and not text:find('UNUSED')
        and not ReceString[text]
end
local function MK(number)
    if number then
        local b=3
        local t=''
        if number>=1e8 then
            number= (number/1e8)-- 1 0000 0000
            t='|cffff4800m|r'
            b=8
        elseif number>= 1e4 then
            number= (number/1e4)
            t='|cffff00ffw|r'
            b=4
        elseif number>=1e3 then
            number= (number/1e3)
            t='|cff00ff00k|r'
        else
            return number..''
        end

        local num, point= math.modf(number)
        if point==0 then
            return num..t
        else--0.5/10^bit
            return format('%0.'..b..'f', number):gsub('%.', t)
        end
    end
end









local function Is_StopRun(self, startIndex)
    if self.isStop then
        self.Value:SetFormattedText(
            '|cffff8200暂停, %s条, %.1f%%',
            MK(self.num),
            (startIndex-self.min)/(self.max-self.min)*100
        )
        self.Name:SetText(self.text)
        return true

    elseif (startIndex > self.max) then
        self.bar:SetValue(100)
        local clock= SecondsToClock(GetTime()-self.time)
        clock= clock:gsub('：', ':')
        local num= MK(self.num)
        self.Value:SetFormattedText(
            '|cffff00ff完成|r, %s条, %s',
            num,
            clock
        )
        self.Name:SetText(self.text)
        Save()[self.name..'Ver']= Ver

        Save()[self.name..'Data']= Save()[self.name..'Data'] or {}
        if #Save()[self.name..'Data']>=4 then
           table.remove(Save()[self.name..'Data'], #Save()[self.name..'Data'])
        end

        local t= date('%D')..' '.. date('%T')
            ..' 版本'..Ver..'|r'
            ..' |cffffffff'..num..'条|r'
            ..' 运行'..clock
        table.insert(Save()[self.name..'Data'], 1, t)

        self:settings()
        self.num= 0

        MaxButtonLabel:SetText('|cnGREEN_FONT_COLOR:完成')
        print(
            self.text..'|TInterface\\AddOns\\WoWTools_Chinese_Scanner\\Source\\WoWtools.tga:0:0|t',
            '|cnGREEN_FONT_COLOR:完成|r'..num..'条|cnWARNING_FONT_COLOR:',
            clock
        )
        return true
    end
end

local function Set_ValueText(self, startIndex)
    local va= (startIndex-self.min)/(self.max-self.min)*100
    local clock= SecondsToClock(GetTime()-self.time)
    clock= clock:gsub('：', ':')
    self.Value:SetFormattedText(
        '%s, %s条, %.1f%%',
        clock,
        MK(self.num),
        va
    )
    MaxButtonLabel:SetFormattedText('%.1f', va)
    self.bar:SetValue(va)
end

local function Is_StopCahceRun(self, startIndex)
    if self.isCahceStop then
        print(addName, '|cffff0000停止|r, 获取“'..self.name..'”数据')
        self.bar2:Hide()
        self.bar2:SetValue(0)
        return true

    elseif (startIndex > self.max) then
        print(addName, '获取“'..self.name..'” 数据 |cnGREEN_FONT_COLOR:完成')
        self.bar2:SetValue(0)
        self.bar2:Hide()
        local clock= SecondsToClock(GetTime()-self.cahceTime)
        clock= clock:gsub('：', ':')
        self.isCahceStop= true
        self.cahce:settings()
        return true
    end
end









































--Encounter [字符journalEncounterID]= {T=, D=}
local function Get_Encounter_Tab(self, ID, count)
    local name, desc
    local n, d = EJ_GetEncounterInfo(ID)
    if IsCN(n) then
        name= n
    end
    if IsCN(d) then
        desc= d
    end
    if name or desc then
        Save_Value(self, count, ID, {
            T=name,
            D=desc
        })
    end
end

local function S_Encounter(self, startIndex, count)
    if Is_StopRun(self, startIndex) then
        return
    end
    for ID = startIndex, startIndex + 100 do
        Get_Encounter_Tab(self, ID, count)
    end
    Set_ValueText(self, startIndex)
    if count==3 then
        C_Timer.After(0.1, function() S_Encounter(self, startIndex + 101, 0) end)
    else
        C_Timer.After(0.1, function() S_Encounter(self, startIndex, count+1) end)
    end
end

























--EncounterSection [字符sectionIDxdifficultyID]= {T=, D=}
local function S_SectionEncounter(self, startIndex, count)
    if Is_StopRun(self, startIndex) then
        return
    end



    for difficultyID= 1, 45 do--in pairs({16, 15, 14, 17}) do-- 16史诗 15英雄 14普通 17随机
        EJ_SetDifficulty(difficultyID)

        for sectionID= startIndex, startIndex + 100 do

            local sectionInfo = C_EncounterJournal.GetSectionInfo(sectionID)
            local id= EJ_GetDifficulty() or difficultyID
            if sectionInfo and not sectionInfo.filteredByDifficulty then
                local title, desc
                if IsCN(sectionInfo.title) then
                    title= sectionInfo.title
                end
                if IsCN(sectionInfo.description) then
                    desc= sectionInfo.description
                end
                if title or desc then
                     _G['WoWTools_SC_'..self.name][sectionID]= _G['WoWTools_SC_'..self.name][sectionID] or {}
                    if title then
                        _G['WoWTools_SC_'..self.name][sectionID].T=title
                        self.Name:SetText(sectionID..' '..title)
                    end
                    if desc then
                        desc= desc:gsub('|cffffffff', '[')
                        desc= desc:gsub('|r', ']')
                        _G['WoWTools_SC_'..self.name][sectionID][id]= desc
                    end
                    if count==2 then
                        self.num= self.num + 1
                    end
                end
            end
        end
    end

    Set_ValueText(self, startIndex)
 
    if count>=2 then
        C_Timer.After(0.1, function() S_SectionEncounter(self, startIndex + 101, 0) end)
    else
        C_Timer.After(0.1, function() S_SectionEncounter(self, startIndex, count+1) end)
    end
end






























local function Save_Unit(self, ID, count)
    local data= C_TooltipInfo.GetHyperlink('unit:Creature-0-0-0-0-'..ID..'-0000000000')
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
            desc= (desc and desc..'●' or '')..line.leftText--ActionButton.lua 中文中的●跟英文不一样
        end
    end
    if title then
        Save_Value(self, ID, count, {
            T= title,
            D= desc,
        })
    end
end
local function S_Unit(self, startIndex, count)
    if Is_StopRun(self, startIndex) then
        return
    end
    for ID = startIndex, startIndex + 100 do
        Save_Unit(self, ID, count)
    end
    Set_ValueText(self, startIndex)

    if count==3 then
        C_Timer.After(0.1, function() S_Unit(self, startIndex + 101, 0) end)
    else
        C_Timer.After(0.1, function() S_Unit(self, startIndex, count+1) end)
    end
end






















--[[
C_TooltipInfo.GetItemByID(237590)
C_TooltipInfo.GetHyperlink('item:212021:0:0:0:0:0:0:0')
C_Item.IsItemDataCachedByID(212021)
C_Item.RequestLoadItemDataByID(212021)
]]

local function Get_Item_Lines(lines)
    if not lines then
        return
    end
    local desc
    for index, line in pairs(lines) do
        local text= line.leftText
        if index>1 and IsCN(text) and (
            text:find('套装：(.+)')
            or text:find('使用：(.+)')
            or text:find('击中时可能：(.+)')
            or text:find('装备：(.+)')
            or text:find('需要：(.+)')
            or text:find('用于：(.+)')
            --or text:find('职业：(.+)')
            or text:find('^".+"$')
            or text:find('|c........')
        )
        then
            desc= (desc and desc..'|n' or '')..(text:match('"(.+)"') or text)
        end
    end
    return desc
end

local function Set_ItemSets(itemID)
    local  _, itemLink, _, _, _, _, _, _, _, _, _, _, _, _, _, setID= C_Item.GetItemInfo(itemID)
    if not setID then
        return
    end
    local specs= C_Item.GetItemSpecInfo(itemID)
    if not specs then
        return
    end
    for _, specID in pairs(specs) do
        local classID= C_SpecializationInfo.GetClassIDFromSpecID(specID)
        local data= C_TooltipInfo.GetHyperlink(itemLink, classID, specID)
        if data then
            local desc= Get_Item_Lines(data.lines)
            if desc then
                WoWTools_SC_SetsItem[setID]= WoWTools_SC_SetsItem[setID] or {}
                WoWTools_SC_SetsItem[setID][specID]= desc
            end
        end
    end
end


local function Save_Item(self, ID, count)
    local data= C_TooltipInfo.GetItemByID(ID)
    if data
        and data.lines
        and data.lines[1]
        and IsCN(data.lines[1].leftText)
    then

        Set_ItemSets(ID)

        Save_Value(self, ID, count, {
            T= C_Item.GetItemInfo(ID) or data.lines[1].leftText,
            D= Get_Item_Lines(data.lines),
        })
    end
end





local function Cahce_Item(self, ID, count)
    if not C_Item.IsItemDataCachedByID(ID) then
        ItemEventListener:AddCancelableCallback(ID, function()
            Save_Item(self, ID, count)
        end)
    else
        Save_Item(self, ID, count)
    end
end


local function Load_Item(self)
    for classID= 1, GetNumClasses() do
		classID = select(3, GetClassInfo(classID)) or classID
        for specIndex = 1, C_SpecializationInfo.GetNumSpecializationsForClassID(classID) or 0 do
            local specID= GetSpecializationInfoForClassID(classID, specIndex)
            if specID then
                for _, data in pairs(C_LootJournal.GetItemSets(classID, specID) or {}) do
                    for _, sets in pairs(C_LootJournal.GetItemSetItems(data.setID) or {}) do
                        local itemID= sets.itemID
                        if itemID then
                            Cahce_Item(self, itemID)
                        end
                    end
                end
            end
        end
    end
end


local function S_Item(self, startIndex, count)
    if Is_StopRun(self, startIndex) then
        return
    end
    for itemID = startIndex, startIndex + 100 do
        Cahce_Item(self, itemID, count)
    end
    Set_ValueText(self, startIndex)
    if count==2 then
        C_Timer.After(0.1, function() S_Item(self, startIndex + 101, 0) end)
    else
        C_Timer.After(0.1, function() S_Item(self, startIndex, count+1) end)
    end
end





























--[[
任务
local quest = QuestCache:Get(questID);
if quest.isAutoComplete and quest:IsComplete() then
C_QuestLog.RequestLoadQuestByID(77794)
]]

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
local function Save_Quest(self, ID, count)
    local data= C_TooltipInfo.GetHyperlink('quest:' .. ID)
    if not data or
        not data.lines
        or not data.lines[1]
        or not IsCN(data.lines[1].leftText)
    then
        return
    end
    local title= C_QuestLog.GetTitleForQuestID(ID) or data.lines[1].leftText
    local obj
    if data.lines[3] and IsCN(data.lines[3].leftText) then
        obj= data.lines[3].leftText
    end
    local obs= Get_Objectives(ID)
    Save_Value(self, ID, count, {
        T= title,
        O= obj,
        S= obs,
    })
end
local function Cahce_Quest(self, ID, count)
    if not HaveQuestData(ID) then
        QuestEventListener:AddCancelableCallback(ID, function()
            Save_Quest(self, ID, count)
        end)
    else
        Save_Quest(self, ID, count)
    end
end
local function S_Quest(self, startIndex, count)
    if Is_StopRun(self, startIndex) then
        return
    end
    for questID = startIndex, startIndex + 100 do
        Cahce_Quest(self, questID, count)
    end
    Set_ValueText(self, startIndex)
    if count==2 then
        C_Timer.After(0.1, function() S_Quest(self, startIndex + 101, 0) end)
    else
        C_Timer.After(0.1, function() S_Quest(self, startIndex, count+1) end)
    end
end

























--[[
local data= C_TooltipInfo.GetHyperlink('spell:'.. spellID)
local spell = Spell:CreateFromSpellID(spellID)
print(spell:GetSpellSubtext(), '|cnGREEN_FONT_COLOR:'..spellID..'|r', spell:GetSpellDescription())
]]
local function Save_Spell(self, ID, count)
    local title= C_Spell.GetSpellName(ID)
    if IsCN(title) then
        local desc, sub
        local d= C_Spell.GetSpellDescription(ID)
        local s= C_Spell.GetSpellSubtext(ID)
        if IsCN(d) then
            desc= d
        end
        if IsCN(s) then
            sub= s
        end
        Save_Value(self, ID, count, {
            T= title,
            D= desc,
            S= sub,
        })
    end
end

local function Cahce_Spell(self, ID, count)
    if not C_Spell.IsSpellDataCached(ID) then
        SpellEventListener:AddCancelableCallback(ID, function()
            Save_Spell(self, ID, count)
        end)
    else
        Save_Spell(self, ID, count)
    end
end

local function S_Spell(self, startIndex, count)
    if Is_StopRun(self, startIndex) then
        return
    end
    for spellID = startIndex, startIndex + 100 do
        Cahce_Spell(self, spellID, count)
    end
    Set_ValueText(self, startIndex)
    if count==2 then
        C_Timer.After(0.1, function() S_Spell(self, startIndex + 101, 0) end)
    else
        C_Timer.After(0.1, function() S_Spell(self, startIndex, count+1) end)
    end
end




















local function Cahce_Achievement(achievementID)
    GetAchievementInfo(achievementID)
end

local function S_CacheAchievement(self, startIndex)
    if Is_StopCahceRun(self, startIndex) then
        return
    end
    for achievementID = startIndex, startIndex + 100 do
        Cahce_Achievement(achievementID)
        self.bar2:SetValue(achievementID/self.max*100)
        self.bar2:SetShown(true)
    end
    C_Timer.After(0.1, function() S_CacheAchievement(self, startIndex + 101) end)
end

local function Save_Achievement(self, ID, count)
    local _, title, _, _, _, _, _, desc, _, _, reward = GetAchievementInfo(ID)
    if IsCN(title) then
        local d,r
        if IsCN(desc) then
            d= desc--概述
        end
        if IsCN(reward) then
            r= reward--奖励
        end
        local s, find
        local numCriteria= GetAchievementNumCriteria(ID) or 0--条件
        if numCriteria>0 then
            local t={}
            for index = 1, numCriteria do
                local criteriaString = GetAchievementCriteriaInfo(ID, index)
                if IsCN(criteriaString) then
                    t[index]= criteriaString
                    find= true
                end
            end
            if find then
                s= t
            end
        end
        Save_Value(self, ID, count, {
            T= title,
            D= d,
            R= r,
            S= s,
        })
    end
end

local function S_Achievement(self, startIndex, count)
    if Is_StopRun(self, startIndex) then
        return
    end
    for ID = startIndex, startIndex + 100 do
        Save_Achievement(self, ID, count)
    end
    Set_ValueText(self, startIndex)
    if count==5 then
        C_Timer.After(0.1, function() S_Achievement(self, startIndex + 101, 0) end)
    else
        C_Timer.After(0.1, function() S_Achievement(self, startIndex, count+1) end)
    end
end



















local function Save_Holyday(self, day, index, count)
    local data= C_Calendar.GetDayEvent(0, day, index)
    if data and data.eventID and data.calendarType~='PLAYER' then
        local holiday= C_Calendar.GetHolidayInfo(0, day, index)
        local desc, title
        if IsCN(data.title) then
            title= data.title
        end
        if holiday and IsCN(holiday.description) then
            desc= holiday.description
        end
        if title or desc then
            Save_Value(self, data.eventID, count, {
                T=title,
                D=desc
            })
        end
    end
end

local function S_Holyday(self, startIndex, count)
   if Is_StopRun(self, startIndex) then
        return
    end
    if startIndex==1 then
        C_Calendar.SetAbsMonth(tonumber(date('%M')), tonumber(date('%Y')))
        C_Calendar.SetMonth(-13)
    end
    do
        C_Calendar.SetMonth(1)
    end
    for day=1, 31 do
        for index= 1, C_Calendar.GetNumDayEvents(0, day), 1 do
            Save_Holyday(self, day, index, count)
        end
    end
    Set_ValueText(self, startIndex)

    if count==5 then
        C_Timer.After(0.1, function() S_Holyday(self, startIndex + 101, 0) end)
    else
        C_Timer.After(0.1, function() S_Holyday(self, startIndex, count+1) end)
    end
end





































local function clear_data(name)
    Save()[name..'Ver']= nil

    _G['WoWTools_SC_'..name]= {}

    local self= _G['WoWToolsSC'..name..'Button']
    if not self.isStop then
        self:settings()
    else
        self.time=nil
    end

    self.bar:SetValue(0)
    self.Value:SetText('')
    self.Ver:SetText('')

    print('清除数据|cnWARNING_FONT_COLOR:', self.text, '|r|cnGREEN_FONT_COLOR:完成')
end

StaticPopupDialogs['WoWTools_SC']={
    text = '你确定要|n|n清除 |cnGREEN_FONT_COLOR:%s|r 数据 吗？|n|n',
    button1 = '确定', button2 = '取消',
    whileDead=true, hideOnEscape=true, exclusive=true, showAlert=true,--, acceptDelay=1,
    OnAccept=function(_, data)
        if data then
            clear_data(data)
        else
            do
                for _, name in pairs(Buttons) do
                    clear_data(name)
                end
            end
            --C_UI.Reload()
        end
    end
}













local y= -40
local function Create_Button(tab)
    local name= tab.name
    local min= tab.min or 1
    local max= tab.max
    local text= (tab.atlas and '|A:'..tab.atlas..':0:0|a' or '')..(tab.text or tab.name)..' '..MK(min)..'-'..MK(max)

    local btn= CreateFrame('Button', 'WoWToolsSC'..name..'Button', Frame)

    btn.name= name
    btn.text= text
    btn.min= min
    btn.max= max
    btn.func= tab.func
    btn.atlas= tab.atlas

    btn:SetPushedAtlas('PetList-ButtonSelect')
    btn:SetHighlightAtlas('PetList-ButtonHighlight')
    btn:SetSize(23, 23)
    btn:SetPoint('TOPRIGHT', -50, y)
    btn:SetScript('OnLeave', function() GameTooltip:Hide() end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:SetText(self.text)
        GameTooltip:AddLine(self.isStop and '|cnGREEN_FONT_COLOR:运行' or '|cffffffff暂停')
        if not LOCALE_zhCN then
            GameTooltip:AddLine('|cnGREEN_FONT_COLOR:需求 简体中文')
        end
        if Save()[self.name..'Data']  then
            for _, t in pairs (Save()[self.name..'Data']) do
                GameTooltip:AddLine(t)
            end
        end
        if tab.tooltip then
            GameTooltip:AddLine('|cff626262'..tab.tooltip)
        end
        GameTooltip:Show()
    end)
    btn:SetScript('OnMouseDown', function(self)
        self:settings()
        if not self.isStop then
            if self.name=='Spell' then
                C_Spell.RequestLoadSpellData(258483)
            end
            _G['WoWTools_SC_'..name]= {}
            self.func(self, self.min, 1)
        end
    end)

    btn.bar= CreateFrame('StatusBar', nil, btn)
    btn.bar:SetPoint('RIGHT', btn, 'LEFT', -2, 0)
    btn.bar:SetSize(Frame:GetWidth()-55-23*3, 18)
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

    btn.Name= btn.bar:CreateFontString(nil, "OVERLAY")
    btn.Name:SetFontObject('GameFontWhite')
    btn.Name:SetPoint('LEFT', btn.bar)
    btn.Name:SetText(text)

    btn.Ver=  btn.bar:CreateFontString(nil, "OVERLAY")
    btn.Ver:SetFontObject("GameFontWhite")
    btn.Ver:SetPoint('CENTER', btn.bar)
    btn.Ver:EnableMouse(true)
    btn.Ver:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    btn.Ver:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:SetText(self:GetParent():GetParent().text)
        GameTooltip:AddLine('数据版本 '..self:GetText())
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

    btn.clear= CreateFrame('Button', nil, btn)
    btn.clear:SetNormalAtlas(tab.atlas or 'bags-button-autosort-up')
    btn.clear:SetPushedAtlas('PetList-ButtonSelect')
    btn.clear:SetHighlightAtlas('PetList-ButtonHighlight')
    btn.clear:SetPoint('RIGHT', btn.bar, 'LEFT', -2, 0)
    btn.clear:SetSize(23,23)
    btn.clear:SetScript('OnLeave', function() GameTooltip:Hide() end)
    btn.clear:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:SetText(self:GetParent().text)
        GameTooltip:AddLine('清除')
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

    if tab.cahce then
        btn.cahce= CreateFrame('Button', nil, btn)
        btn.cahce:SetPushedAtlas('PetList-ButtonSelect')
        btn.cahce:SetHighlightAtlas('PetList-ButtonHighlight')
        btn.cahce:SetPoint('LEFT', btn, 'RIGHT', 8, 0)
        btn.cahce:SetSize(23,23)
        btn.cahce.func= tab.cahce
        btn.cahce.name= name
        btn.cahce.text= text
        btn.cahce.min= min
        btn.cahce.max= max
        function btn.cahce:set_tooltip()
            local p= self:GetParent()
            GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
            GameTooltip:SetText(self.text)
            GameTooltip:AddLine((p.isCahceStop and '|cff626262' or '|cnGREEN_FONT_COLOR:')..'加载数据')
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
            if not self:GetParent().isCahceStop then
                self:SetNormalAtlas('Perks-PreviewOn')
            else
                self:SetNormalAtlas('Perks-PreviewOff-Hover')
            end
        end
        btn.isCahceStop= true
        btn.cahce:settings()
        function btn.cahce:run()
            local p= self:GetParent()
            p.isCahceStop= not p.isCahceStop and true or false
            self.func(p, self.min or 1, self.max)
            p.cahceTime= not p.isCahceStop and GetTime() or nil
            self:settings()
            self:set_tooltip()
        end
        btn.cahce:SetScript('OnMouseDown', function(self)
            self:run()
        end)
    end

    function btn:settings()
        self.isStop= not self.isStop and true or nil
        if self.isStop then
            self:SetNormalAtlas(self.atlas or 'common-dropdown-icon-next')
            self.time=nil
        else
            self:SetNormalAtlas('common-dropdown-icon-stop')
            self.time= GetTime()
        end
        self.num= 0
        self.Ver:SetText(Save()[self.name..'Ver'] or '')
    end
    btn:settings()

    if name=='Item' then
        Load_Item(btn)
    end

    y= y- 23- 8
end
















local function Set_Point(self)
    self:ClearAllPoints()
     local point= Save().point
    if point and point[1] then
        self:SetPoint(point[1], UIParent, point[3], point[4], point[5])
    else
        self:SetPoint('CENTER')
    end
end

local function Save_Point(self)
    ResetCursor()
    self:StopMovingOrSizing()
--确认框架中心点，在屏幕内
    local isInSchermo= true
    local centerX, centerY = self:GetCenter()
    local screenWidth, screenHeight = UIParent:GetWidth(), UIParent:GetHeight()
    if not centerX or not centerY then
        isInSchermo= false
    end
    if centerX < 0 or centerX > screenWidth or centerY < 0 or centerY > screenHeight then
        isInSchermo = false
    end
    if isInSchermo then
        Save().point= {self:GetPoint(1)}
        Save().point[2]= nil
    end
end




local function Init()
    Frame= CreateFrame('Frame', 'WoWTools_SC_Frame', UIParent)
    Frame:Hide()
    Frame:SetFrameStrata('HIGH')
    Frame:SetFrameLevel(501)
    Frame:SetSize(520, 400)

    function Frame:set_event()
        if Save().MaxButtonIsShow then
            self:UnregisterAllEvents()
        else
            self:RegisterUnitEvent('PLAYER_FLAGS_CHANGED', 'player')
        end
    end

    Frame:SetScript('OnEvent', function()
        if UnitIsAFK('player') then
            C_MountJournal.SummonByID(0)
        end
    end)
    Frame:SetMovable(true)
    Frame:RegisterForDrag("LeftButton", "RightButton")
    Frame:SetScript("OnMouseDown", function() SetCursor('UI_MOVE_CURSOR') end)
    Frame:SetScript("OnMouseUp", function() ResetCursor() end)
    Frame:SetScript("OnLeave", function() ResetCursor() end)
    Frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    Frame:SetScript("OnDragStop", function(self)
       Save_Point(self)
    end)
    Frame:SetScript('OnShow', function(self)
        Set_Point(self)
    end)

    local maxButton= CreateFrame('Button', 'WoWTools_SC_FrameMaximizeButton', UIParent)
    maxButton:Hide()
    maxButton:SetFrameStrata('HIGH')
    maxButton:SetFrameLevel(502)
    maxButton:SetSize(23, 23)
    maxButton:SetNormalTexture('Interface\\AddOns\\WoWTools_Chinese_Scanner\\Source\\WoWtools.tga')
    maxButton:SetPushedAtlas('RedButton-Expand-Pressed')
    maxButton:SetHighlightAtlas('RedButton-Highlight')
    maxButton:SetMovable(true)
    maxButton:SetClampedToScreen(true)
    maxButton:RegisterForDrag("RightButton")
    maxButton:SetScript("OnLeave", function() GameTooltip:Hide() ResetCursor() end)
    maxButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(addName)
        GameTooltip:AddDoubleLine('|A:plunderstorm-pickup-mouseclick-left:0:0|a显示', '移动|A:plunderstorm-pickup-mouseclick-right:0:0|a')
        GameTooltip:Show()
    end)
    maxButton:SetScript("OnMouseUp", function() ResetCursor() end)
    maxButton:SetScript("OnMouseDown", function(self, d)
        if d=='LeftButton' then
            Frame:Show()
            self:Hide()
        end
        SetCursor('UI_MOVE_CURSOR')
    end)
    maxButton:SetScript("OnDragStart", function(self) self:StartMoving() end)
    maxButton:SetScript("OnDragStop", function(self)
       Save_Point(self)
    end)
    maxButton:SetScript('OnHide', function()
        Save().MaxButtonIsShow= nil
    end)
    maxButton:SetScript('OnShow', function(self)
        Set_Point(self)
        self:SetButtonState('NORMAL')
        self:SetScale(2)
        C_Timer.After(0.2, function() self:SetScale(1) end)
        C_Timer.After(0.4, function() self:SetScale(2) end)
        C_Timer.After(0.6, function() self:SetScale(1) end)
        MaxButtonLabel:SetText('')
        Save().MaxButtonIsShow= true
        Frame:set_event()
    end)

    MaxButtonLabel= maxButton:CreateFontString('WoWToolsSCMaxButtonLabel', "OVERLAY")
    MaxButtonLabel:SetFontObject('GameFontNormal')
    MaxButtonLabel:SetPoint('BOTTOM', maxButton, 'TOP')

    local minButton= CreateFrame('Button', 'WoWTools_SC_FrameMinimizeButton', Frame)
    minButton:SetSize(23,23)
    minButton:SetNormalAtlas('RedButton-Condense')
    minButton:SetPushedAtlas('RedButton-Condense-Pressed')
    minButton:SetHighlightAtlas('RedButton-Highlight')
    minButton:SetPoint('TOPRIGHT')
    minButton:SetScript('OnShow', function(self)
        self:SetButtonState('NORMAL')
    end)
    minButton:SetScript('OnMouseDown', function(self)
        self:GetParent():Hide()
        maxButton:Show()
    end)


    Frame.Border= CreateFrame('Frame', nil, Frame, 'DialogBorderTemplate')
    --[[Frame.CloseButton=CreateFrame('Button', 'WoWTools_SC_FrameCloseButton', Frame, 'UIPanelCloseButton')--SharedUIPanelTemplates.xml
    Frame.CloseButton:SetPoint('TOPRIGHT')]]
    Frame.Header= CreateFrame('Frame', nil, Frame, 'DialogHeaderTemplate')--DialogHeaderMixin
    Frame.Header:Setup(addName)


    local note= Frame:CreateFontString(nil, "OVERLAY")
    note:SetFontObject('GameFontNormal')
    note:SetPoint('BOTTOM', 0, 12)
    note:SetText(
        '当前游戏版本 '..Ver
        ..(LOCALE_zhCN and '' or '|n|cnWARNING_FONT_COLOR:需求 简体中文|r')
        ..'|n不要一起扫描，数据会出错'
        ..'|n|cffffffff数据：|rWTF\\Account\\...\\SavedVariables\\WoWTools_Chinese_Scanner.lua'
    )



    local clear= CreateFrame('Button', 'WoWToolsSCClearDataButton', Frame, 'UIPanelButtonTemplate')
    clear:SetSize(150, 23)
    --clear:SetPoint('TOP', Frame.Header, 'BOTTOM', 0, -10)
    clear:SetPoint('BOTTOMLEFT', 12, 25)
    clear:SetText('|A:bags-button-autosort-up:0:0|a清除所有数据')
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


    local reload= CreateFrame('Button', 'WoWToolsSCReloadButton', Frame, 'UIPanelButtonTemplate')
    reload:SetSize(150, 24)
    reload:SetText('重新加载UI')
    reload:SetScript('OnClick', C_UI.Reload)
    reload:SetPoint('BOTTOMRIGHT', -12, 24)









do
    for _, tab in pairs({
        {name='Spell', func=S_Spell, tooltip='30w0234 09:55', max=MaxSpellID, text='法术', atlas='UI-HUD-MicroMenu-SpellbookAbilities-Mouseover'},
        {name='Item', func=S_Item, tooltip='16w3018 05:50', max=MaxItemID, text='物品', atlas='bag-main'},

        {name='Unit', func=S_Unit, tooltip='17w7693 5:00', max=MaxUnitID,text='怪物名称', atlas='BuildanAbomination-32x32'},
        '-',

        {name='SectionEncounter', func=S_SectionEncounter, max=MaxSectionEncounterID, text='Boss 技能', tooltip='6w3134 3:00', atlas='KyrianAssaults-64x64'},
        {name='Quest', func=S_Quest, tooltip='2w0659', max=MaxQuestID,text='任务', atlas='CampaignAvailableQuestIcon'},
        {name='Spell2', func=S_Spell, tooltip='1w0454', min=MinSpell2ID, max=MaxSpell2ID, text='法术II', atlas='UI-HUD-MicroMenu-SpellbookAbilities-Mouseover'},
        {name='Achievement', func=S_Achievement, cahce=S_CacheAchievement, max=MaxAchievementID,text='成就', tooltip='1w2058 01:10', atlas='UI-Achievement-Shield-NoPoints'},
        {name='Encounter', func=S_Encounter, tooltip='1k103', max=MaxEncounterID, text='Boss 综述', atlas='adventureguide-icon-whatsnew'},
        '-',
        
        {name='Holyday', func=S_Holyday, max=24, text='节日', tooltip='119条'},
    }) do
        if tab=='-' then
            y=y-12
        else
            Create_Button(tab)
        end

        table.insert(Buttons, tab.name)
    end
end


    Frame:SetHeight(-y+75)

    if not InCombatLockdown() then
        if not CollectionsJournal then
            CollectionsJournal_LoadUI()
        end

        if not PlayerSpellsFrame then
            PlayerSpellsFrame_LoadUI()
        end

        if not AchievementFrame then
            AchievementFrame_LoadUI()
        end

        if not EncounterJournal then
            EncounterJournal_LoadUI()
        end

        EventRegistry:RegisterFrameEventAndCallback("CALENDAR_UPDATE_EVENT_LIST", function(owner)
            if CalendarFrame:IsShown() then
                ToggleCalendar()
            end
            EventRegistry:UnregisterCallback('CALENDAR_UPDATE_EVENT_LIST', owner)
        end)
        if not CalendarFrame then
            ToggleCalendar()
        end
    end




    if Save().MaxButtonIsShow then
        maxButton:Show()
    else
        Frame:Show()
    end

    Init=function()end
end












EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
    if arg1~='WoWTools_Chinese_Scanner' then
        return
    end

    WoWTools_SC= WoWTools_SC or {}

    WoWTools_SC_Achievement = WoWTools_SC_Achievement or {}
    WoWTools_SC_Quest = WoWTools_SC_Quest or {}
    WoWTools_SC_Encounter= WoWTools_SC_Encounter or {}
    WoWTools_SC_SectionEncounter= WoWTools_SC_SectionEncounter or {}

    WoWTools_SC_Item= WoWTools_SC_Item or {}
    WoWTools_SC_SetsItem= WoWTools_SC_SetsItem or {}

    WoWTools_SC_Spell= WoWTools_SC_Spell or {}
    WoWTools_SC_Spell2= WoWTools_SC_Spell2 or {}
    WoWTools_SC_Unit= WoWTools_SC_Unit or {}

    WoWTools_SC_Holyday= WoWTools_SC_Holyday or {}

    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)



EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)
    Init()
    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)






















