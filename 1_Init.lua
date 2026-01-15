local addName= '|TInterface\\AddOns\\WoWTools_Chinese_Scanner\\Source\\WoWtools.tga:0:0|t'..'|cffff00ffWoW|r|cff00ff00Tools|r|cff28a3ffChinese|r数据扫描'
if not LOCALE_zhCN then
    print(addName, '|cnGREEN_FONT_COLOR:需求 简体中文|r')
    return
end

local function Save()
    return WoWTools_SC
end

local Ver= GetBuildInfo()
local GameVer= select(4, GetBuildInfo())/1e4--11

local MaxAchievementID= (GameVer-4)* 1e4--11.2.5 版本，最高61406 https://wago.tools/db2/Achievement
local MaxQuestID= GameVer* 1e4--11.2.5 版本 93516
local MaxEncounterID= (GameVer-8)* 1e4--25000


local MaxUnitID= (GameVer-8)* 10e4--30w0000 11.25 最高 25w4359 https://wago.tools/db2/Creature





local MaxItemID= 15e4
local MaxItemID2= (GameVer-8)* 10e4--30w0000 11.2.5 最高 25w8483  https://wago.tools/db2/Item

local MaxSetsID= (GameVer-9)*1e3 + 100-- 12.0 2000 https://wago.tools/db2/ItemSet

local MaxSpellID=(GameVer-6)* 10e4-- 50w0000 229270
local MinSpell2ID= 12* 1e5
local MaxSpell2ID= (GameVer+2)* 10e4--120w- 150w

local difficultyIDs= {1,2,23, 17,14,15,16}-- 16史诗 15英雄 14普通 17随机, 1,2,23
local difficultyID= 1
local difficultyIndex=1
local MaxSectionEncounterID= (GameVer-8)*1e4--12.0版本，最高35159 https://wago.tools/db2/JournalEncounterSection

local MaxFactionID=(GameVer-9)*1e3+ 100 --12.0 2781 https://wago.tools/db2/Faction



local Frame, MaxButtonLabel
local Buttons={}
local ClassButton={}

local MaxCount= 1--运行次数
local MaxLoopCount= 100



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
        and not text:find('TEST')
        and not ReceString[text]
end
local function MK(number, notColor)
    number= number and tonumber(number)
    if number then
        local b=3
        local t=''
        local hex
        if number>=1e8 then
            number= (number/1e8)-- 1 0000 0000
            hex='|cffff4800%s|r'
            t='m'
            b=8
        elseif number>= 1e4 then
            number= (number/1e4)
            hex= '|cffff00ff%s|r'
            t='w'
            b=4
        elseif number>=1e3 then
            number= (number/1e3)
            hex= '|cff00ff00%s|r'
            t='k'
        else
            return number..''
        end

        local num, point= math.modf(number)
        if not notColor then
            t= format(hex, t)
        end

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
            '|cffff8200暂停|r  %s条  %.1f%%',
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
            '|cffff00ff完成|r  %s条  %s',
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

        MaxButtonLabel:SetText('|cnGREEN_FONT_COLOR:完成')
        print(
            self.text..'|TInterface\\AddOns\\WoWTools_Chinese_Scanner\\Source\\WoWtools.tga:0:0|t',
            '|cnGREEN_FONT_COLOR:完成|r '..num..'条 |cnWARNING_FONT_COLOR:'..clock..'|r'
        )

        self:settings()

        if WoWTools_SC_IsLoopRun then
            self:run()
            print(
                self.text..'|TInterface\\AddOns\\WoWTools_Chinese_Scanner\\Source\\WoWtools.tga:0:0|t',
                '循环运行'
            )
        end
        return true
    end
end

local function Set_ValueText(self, startIndex)
    if self.isStop then
        return
    end

    local va= (startIndex-self.min)/(self.max-self.min)*100
    local clock= SecondsToClock(GetTime()-self.time)
    clock= clock:gsub('：', ':')
    self.Value:SetFormattedText(
        '%s  %s条  %.1f%%',
        clock,
        MK(self.num),
        va
    )
    MaxButtonLabel:SetFormattedText('%.1f', va)
    self.bar:SetValue(va)
end

local function Is_StopCahceRun(self, startIndex)
    if self.isCahceStop then
        print(addName, '|cffff0000停止|r 获取“'..self.name..'”数据')
        self.bar2:Hide()
        self.bar2:SetValue(0)
        return true

    elseif (startIndex > self.max) then
        print(addName, '获取“'..self.name..'” 数据 |cnGREEN_FONT_COLOR:完成|r')
        self.bar2:SetValue(0)
        self.bar2:Hide()
        local clock= SecondsToClock(GetTime()-self.cahceTime)
        clock= clock:gsub('：', ':')
        self.isCahceStop= true
        self.cahce:settings()
        return true
    end
end

local function Save_Value(self, id, tab)
    if tab and id then
        if not _G['WoWTools_SC_'..self.name] then
            _G['WoWTools_SC_'..self.name]= {}
        end

        _G['WoWTools_SC_'..self.name][tonumber(id)] = tab

        self.num= self.num+1
        self.Name:SetText(MK(id)..(self.isStop and '|cnGREEN_FONT_COLOR: ' or ' ')..(tab.T or ''))
    end
end

local function clear_data(name)
    Save()[name..'Ver']= nil

    if _G['WoWTools_SC_'..name] then
        _G['WoWTools_SC_'..name]= nil
    end

--Boss 技能
    if name=='SectionEncounter' then
        difficultyID= 1
        difficultyIndex=1
    end

    local self= _G['WoWToolsSC'..name..'Button']
    if not self.isStop then
        self:settings()
    else
        self.time=nil
    end



    self.bar:SetValue(0)
    self.Value:SetText('')
    self.Ver:SetText('')

    print('清除数据|cnWARNING_FONT_COLOR:', self.text, '|r|cnGREEN_FONT_COLOR:完成|r')
end

StaticPopupDialogs['WoWTools_SC']={
    text = '你确定要|n|n清除 |cnGREEN_FONT_COLOR:%s|r 数据 吗？|n|n',
    button1 = '确定', button2 = '取消',
    whileDead=true, hideOnEscape=true, exclusive=true, showAlert=true,--, acceptDelay=1,
    OnAccept=function(_, data)
        if data then
            clear_data(data)
        else
            WoWTools_SC_LogClass={[PlayerUtil.GetClassID()]= true}
            WoWTools_Sc_KeepRunName= nil
            _G['WoWToolsSCKeepRunButton']:set_atlas()

            for _, name in pairs(ClassButton) do
                _G[name]:set_stat()
            end

            for _, name in pairs(Buttons) do
                clear_data(name)
            end
            --C_UI.Reload()
        end
    end
}











































local function Settings(self)
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



local function RUN(self)
    _G['WoWTools_SC_'..self.name]= _G['WoWTools_SC_'..self.name] or {}

    self:settings()
    if not self.isStop then
        self:func(self.min or 1, 0)
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

local function Set_ItemSets(self, itemID)
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

                local tab= WoWTools_SC_Sets[setID] or {}
                tab[specID]= desc

                Save_Value(self, setID, tab)
            end
        end
    end
end

local function Save_Item(self, itemID, isSet)
    local data= C_TooltipInfo.GetItemByID(itemID)
    if data
        and data.lines
        and data.lines[1]
        and IsCN(data.lines[1].leftText)
    then
        if isSet then
            Set_ItemSets(self, itemID)
        else
            Save_Value(self, itemID, {
                T=C_Item.GetItemInfo(itemID) or data.lines[1].leftText,
                D= Get_Item_Lines(data.lines)
            })
        end
    end
end

local function Load_Item(self, id, isSet)
    if not C_Item.IsItemDataCachedByID(id) then
        ItemEventListener:AddCancelableCallback(id, function()
            Save_Item(self, id, isSet)
        end)
    else
        Save_Item(self, id, isSet)
    end
end


local function S_Item(self, startIndex, count)
    count= count +1
    if Is_StopRun(self, startIndex) then
        return
    end
    for itemID = startIndex, startIndex + MaxLoopCount do
        if C_Item.GetItemInfoInstant(itemID) then
            Load_Item(self, itemID, false)
        end
    end
    if count==1 then
        Set_ValueText(self, startIndex)
    end
    if count>=MaxCount then
        C_Timer.After(0.3, function() S_Item(self, startIndex + MaxLoopCount+1, 0) end)
    else
        C_Timer.After(0.3, function() S_Item(self, startIndex, count) end)
    end
end








--C_LootJournal.GetItemSetItems
local function S_SetsItem(self, setID)
    for _, sets in pairs(C_Transmog.GetAllSetAppearancesByID(setID) or {}) do
        local itemID= sets.itemID
        if itemID then
            Load_Item(self, itemID, true)
        end
    end
    for _, sets in pairs(C_LootJournal.GetItemSetItems(setID) or {}) do
        local itemID= sets.itemID
        if itemID then
            Load_Item(self, itemID, true)
        end
    end
end

local function Load_Sets(self)
    for classID= 1, GetNumClasses() do
		classID = select(3, GetClassInfo(classID)) or classID
        for specIndex = 1, C_SpecializationInfo.GetNumSpecializationsForClassID(classID) or 0 do
            local specID= GetSpecializationInfoForClassID(classID, specIndex)
            if specID then
                for _, data in pairs(C_LootJournal.GetItemSets(classID, specID) or {}) do
                    if data.setID then
                        S_SetsItem(self, data.setID)
                    end
                end
            end
        end
    end
end





local function S_Sets(self, startIndex, count)
    count= count +1
    if startIndex==self.min or startIndex==self.max then
        Load_Sets(self)
    end
    if Is_StopRun(self, startIndex) then
        return
    end
    for itemID = startIndex, startIndex + 50 do
        S_SetsItem(self, itemID)
    end
    if count==1 then
        Set_ValueText(self, startIndex)
    end
    if count>=MaxCount then
        C_Timer.After(0.3, function() S_Sets(self, startIndex + 51, 0) end)
    else
        C_Timer.After(0.3, function() S_Sets(self, startIndex, count) end)
    end
end





















--[[
local data= C_TooltipInfo.GetHyperlink('spell:'.. spellID)
local spell = Spell:CreateFromSpellID(spellID)
print(spell:GetSpellSubtext(), '|cnGREEN_FONT_COLOR:'..spellID..'|r', spell:GetSpellDescription())
]]
local function Save_Spell(self, id)
    local title= C_Spell.GetSpellName(id)
    if IsCN(title) then
        local desc, sub
        local d= C_Spell.GetSpellDescription(id)
        local s= C_Spell.GetSpellSubtext(id)
        if IsCN(d) then
            desc= d
        end
        if IsCN(s) then
            sub= s
        end
        Save_Value(self, id, {
            T= title,
            D= desc,
            S= sub,
        })
    end
end


local function S_LoadSpell(self, spellID)
    if not C_Spell.IsSpellDataCached(spellID) then
        SpellEventListener:AddCancelableCallback(spellID, function()
            Save_Spell(self, spellID)
        end)
    else
        Save_Spell(self, spellID)
    end
end


local function S_Spell(self, startIndex, count)
    count= count+ 1
    if Is_StopRun(self, startIndex) then
        return
    end
    for spellID = startIndex, startIndex + MaxLoopCount do
        S_LoadSpell(self, spellID)
    end
    if count==1 then
        Set_ValueText(self, startIndex)
    end
    if count>=MaxCount then
        C_Timer.After(0.3, function() S_Spell(self, startIndex + MaxLoopCount+1, 0) end)
    else
        C_Timer.After(0.3, function() S_Spell(self, startIndex, count) end)
    end
end





















--[[
任务
local quest = QuestCache:Get(questID);
if quest.isAutoComplete and quest:IsComplete() then
C_QuestLog.RequestLoadQuestByID(77794)

local QuestTooltip = CreateFrame("GameTooltip", "WoWToolsQuestSCTooltip", UIParent, "GameTooltipTemplate")
QuestTooltip:SetFrameStrata("TOOLTIP")
local function Quest_Desc_Regions(...)
  local texts = ''
    for i = 1, select("#", ...) do
        local region = select(i, ...)
        if region and region:GetObjectType() == "FontString" then
            local text = region:GetText()
			if IsCN(text) then
                --print(i, text)
            end
        end
	end
	return texts
end
local function Get_Quest_Desc(questID)
    QuestTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    QuestTooltip:ClearLines()
    QuestTooltip:SetHyperlink('quest:' .. questID)
    QuestTooltip:Show()
end
]]




--[[function Cahce_Campagn(campaignID)
    if campaignID then
        C_LoreText.RequestLoreTextForCampaignID(campaignID)
    end

end
EventRegistry:RegisterFrameEventAndCallback("LORE_TEXT_UPDATED_CAMPAIGN", function(_, campaignID, textEntries)
    if campaignID then
        local info= C_CampaignInfo.GetCampaignInfo(campaignID)
        if info then
            local title= IsCN(info.name)
            local desc= IsCN(info.description)
            if title or desc then
                WoWTools_SC_Campaign[campaignID]= WoWTools_SC_Campaign[campaignID] or {}
                if title then
                    WoWTools_SC_Campaign[campaignID].T= info.name
                end
                if desc then
                    WoWTools_SC_Campaign[campaignID].D= info.description
                end
            end
        end
    end
end)]]




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

local function Save_Quest(self, id)
    local data= C_TooltipInfo.GetHyperlink('quest:' .. id)
    if not data or
        not data.lines
        or not data.lines[1]
        or not IsCN(data.lines[1].leftText)
    then
        return
    end
    local title= QuestUtils_GetQuestName(id) or data.lines[1].leftText
    local obj
    if data.lines[3] and IsCN(data.lines[3].leftText) then
        obj= data.lines[3].leftText
    end

    local obs= Get_Objectives(id)

    --[[local campaignID= C_CampaignInfo.GetCampaignID(ID)
    if campaignID then
        C_LoreText.RequestLoreTextForCampaignID(campaignID)
    end]]

    Save_Value(self, id, {
        T= title,
        O= obj,
        S= obs,
    })
end

local function Load_Quest(self, questID)
    if not HaveQuestData(questID) then
        QuestEventListener:AddCancelableCallback(questID, function()
            Save_Quest(self, questID)
        end)
    else
        Save_Quest(self, questID)
    end
end


local function S_Quest(self, startIndex, count)
    count= count + 1
    if Is_StopRun(self, startIndex) then
        return
    end
    for questID = startIndex, startIndex + MaxLoopCount do
        Load_Quest(self, questID)
    end
    if count==1 then
        Set_ValueText(self, startIndex)
    end

    if count>=MaxCount then
        C_Timer.After(0.3, function() S_Quest(self, startIndex + MaxLoopCount+1, 0) end)
    else
        C_Timer.After(0.3, function() S_Quest(self, startIndex, count) end)
    end
end





























local function Save_Unit(self, id)
    local data= C_TooltipInfo.GetHyperlink('unit:Creature-0-0-0-0-'..id..'-0000000000')
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
        Save_Value(self, id, {
            T= title,
            D= desc,
        })
    end
end
local function S_Unit(self, startIndex, count)
    count= count+ 1
    if Is_StopRun(self, startIndex) then
        return
    end
    for id = startIndex, startIndex + MaxLoopCount do
        Save_Unit(self, id)
    end
    if count==1 then
        Set_ValueText(self, startIndex)
    end
    if count>=MaxCount then
        C_Timer.After(0.3, function() S_Unit(self, startIndex + MaxLoopCount+1, 0) end)
    else
        C_Timer.After(0.3, function() S_Unit(self, startIndex, count) end)
    end
end

























































--Encounter [字符journalEncounterID]= {T=, D=}
local function Get_Encounter_Tab(self, id)
    local name, desc
    local n, d = EJ_GetEncounterInfo(id)
    if IsCN(n) then
        name= n
    end
    if IsCN(d) then
        desc= d
    end
    if name or desc then
        Save_Value(self, id, {
            T=name,
            D=desc
        })
    end
end

local function S_Encounter(self, startIndex, count)
    count= count +1
    if Is_StopRun(self, startIndex) then
        return
    end
    for id = startIndex, startIndex + MaxLoopCount do
        Get_Encounter_Tab(self, id)
    end
    if count==1 then
        Set_ValueText(self, startIndex)
    end
    if count>=MaxCount then
        C_Timer.After(0.3, function() S_Encounter(self, startIndex + MaxLoopCount+1, 0) end)
    else
        C_Timer.After(0.3, function() S_Encounter(self, startIndex, count) end)
    end
end















--EncounterSection [字符sectionIDxdifficultyID]= {T=, D=}
--[[

function WoWeuCN_Scanner_ScanEncounterSectionAuto(startIndex, attempt, counter)
  if (startIndex > 50000) then
    WoWeuCN_Scanner_Index = 0
    return;
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
     WoWeuCN_Scanner_wait(0.1, WoWeuCN_Scanner_ScanEncounterSectionAuto, startIndex + 100, attempt + 1, 0)
  else
     WoWeuCN_Scanner_wait(0.1, WoWeuCN_Scanner_ScanEncounterSectionAuto, startIndex, attempt + 1, counter + 1)
  end
end
]]

local function S_SectionEncounter(self, startIndex, count)
    count= count +1

    if not EncounterJournal  then
        EncounterJournal_LoadUI()
    end

    if Is_StopRun(self, startIndex) then
        if count>=MaxCount then
            print(self.text, '|cnWARNING_FONT_COLOR:难度结束', DifficultyUtil.GetDifficultyName(difficultyID)..'('..(select(10, GetDifficultyInfo(difficultyID))..'人)'), difficultyIndex..'/'..7)

            if startIndex > self.max then
                difficultyIndex= difficultyIndex+1

                difficultyIndex= difficultyIndex> #difficultyIDs and 1 or difficultyIndex

                difficultyID= difficultyIDs[difficultyIndex]
            end
        end
        return
    end

    if EJ_GetDifficulty()~=difficultyID then
        EJ_SetDifficulty(difficultyID)
    end

    local name= 'WoWTools_SC_'..self.name
    local id= difficultyID
    for sectionID= startIndex, startIndex + MaxLoopCount do
        local sectionInfo = C_EncounterJournal.GetSectionInfo(sectionID)
        if sectionInfo and not sectionInfo.filteredByDifficulty then
            EJ_GetSectionPath(sectionID)

            local title, desc
            if IsCN(sectionInfo.title) then
                title= sectionInfo.title
            end
            if IsCN(sectionInfo.description) then
                desc= sectionInfo.description
            end
            if title or desc then
                if desc then
                    desc= desc:gsub('^\r\n\r\n', '')
                    desc= desc:gsub('|cffffffff', '|cff000000')
                    desc= desc:gsub('%d+,%d+', function(number)
                        return MK(number:gsub(',', ''), true)
                    end)
                end

                local tab={}

                if _G[name] and _G[name][sectionID] then
                    tab= _G[name][sectionID]
                end

                tab.T= title or tab.T

                tab[id]= desc or tab[id]

                if count==1 then
                    Save_Value(self, sectionID, tab)
                end
            end
        end
    end
    if count==1 then
        Set_ValueText(self, startIndex)
    end
    if count>=MaxCount then
        C_Timer.After(0.3, function() S_SectionEncounter(self, startIndex + MaxLoopCount+1, 0) end)
    else
        C_Timer.After(0.3, function() S_SectionEncounter(self, startIndex, count) end)
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
    C_Timer.After(0.3, function() S_CacheAchievement(self, startIndex + 101) end)
end

local function Save_Achievement(self, id)
    local _, title, _, _, _, _, _, desc, _, _, reward = GetAchievementInfo(id)
    if IsCN(title) then
        local d,r
        if IsCN(desc) then
            d= desc--概述
        end
        if IsCN(reward) then
            r= reward--奖励
        end
        local s, find
        local numCriteria= GetAchievementNumCriteria(id) or 0--条件
        if numCriteria>0 then
            local t={}
            for index = 1, numCriteria do
                local criteriaString = GetAchievementCriteriaInfo(id, index)
                if IsCN(criteriaString) then
                    t[index]= criteriaString
                    find= true
                end
            end
            if find then
                s= t
            end
        end
        Save_Value(self, id, {
            T= title,
            D= d,
            R= r,
            S= s,
        })
    end
end

local function S_Achievement(self, startIndex, count)
    count= count+ 1
    if Is_StopRun(self, startIndex) then
        return
    end
    for id = startIndex, startIndex + MaxLoopCount do
        if C_AchievementInfo.IsValidAchievement(id) then
            Save_Achievement(self, id)
        end
    end
    if count==1 then
        Set_ValueText(self, startIndex)
    end
    if count>=MaxCount then
        C_Timer.After(0.3, function() S_Achievement(self, startIndex + MaxLoopCount+1, 0) end)
    else
        C_Timer.After(0.3, function() S_Achievement(self, startIndex, count) end)
    end
end



















--[[
C_CovenantSanctumUI.GetRenownLevels(covenantID) : levels
C_CovenantSanctumUI.GetRenownRewardsForLevel(covenantID, renownLevel) : rewards
]]
local function Get_MajoData(self, factionID)
    
    local data= C_MajorFactions.GetMajorFactionData(factionID)
    if not data then
        return
    end

    local tab={}
    local find=false

    if IsCN(data.name) then
        tab.T= data.name
        find=true
    end
    if IsCN(data.description) then
        tab.D= data.description
        find=true
    end
    if IsCN(data.unlockDescription) then
        tab.U= data.unlockDescription
        find=true
    end


    local rew={}
    local findRew= false

    for level in pairs(C_MajorFactions.GetRenownLevels(factionID) or {}) do
         for index, info in pairs(C_MajorFactions.GetRenownRewardsForLevel(factionID, level) or {}) do
            if IsCN(info.name) then
                rew[level]= rew[level] or {}
                rew[level][index]= rew[level][index] or {}
                rew[level][index].T= info.name
                if IsCN(info.description) then
                    rew[level][index].D=info.description
                end
                if IsCN(info.toastDescription) then
                    rew[level][index].U=info.toastDescription
                end
                findRew=true
            end
        end
    end

    if findRew then
        tab.O=rew
        find=true
    end

    if find then
        Save_Value(self, factionID, tab)
    end
end

local function Get_Faction(self, factionID)
    if C_Reputation.IsMajorFaction(factionID) then
        Get_MajoData(self, factionID)
    else
        local data= C_Reputation.GetFactionDataByID(factionID)
        if data and IsCN(data.name) and data.factionID then
            factionID= data.factionID

            local tab={
                T= data.name
            }
            if IsCN(data.description) then
                tab.D= data.description
            end
            Save_Value(self, data.factionID, tab)
        end
    end
end
--[[
    local data= C_Reputation.GetFactionDataByID(factionID)
    if data and IsCN(data.name) and data.factionID then
        factionID= data.factionID

        local tab={
            T= data.name
        }
        if IsCN(data.description) then
            tab.D= data.description
        end
        if C_Reputation.IsMajorFaction(factionID) then
            local rew={}
            local find

            local major= C_MajorFactions.GetMajorFactionData(factionID) or {}
            if major.isUnlocked==false and IsCN(major.unlockDescription) then
                tab.U= major.unlockDescription
            end

            for i=1, #C_MajorFactions.GetRenownLevels(factionID) do
                local rewards = C_MajorFactions.GetRenownRewardsForLevel(factionID, i)
                if rewards then
                    for index, info in pairs(rewards) do
                        if IsCN(info.name) then
                            rew[i]= rew[i] or {}
                            rew[i][index]= rew[i][index] or {}
                            rew[i][index].T= info.name
                            if IsCN(info.description) then
                                rew[i][index].D=info.description
                            end
                            find=true
                        end
                    end
                end
            end
            if find then
                tab.O=rew
            end
        end
        if factionID==2722 then
            print(data.name, data.description)
        end
        Save_Value(self, factionID, tab)
    end
end]]

local function S_Faction(self, startIndex, count)
    count= count +1

    if Is_StopRun(self, startIndex) then
        return
    end
    for id = startIndex, startIndex + MaxLoopCount do
        Get_Faction(self, id)
    end
    if count==1 then
        Set_ValueText(self, startIndex)
    end
    if count>=MaxCount then
        C_Timer.After(0.3, function() S_Faction(self, startIndex + MaxLoopCount+1, 0) end)
    else
        C_Timer.After(0.3, function() S_Faction(self, startIndex, count) end)
    end
end




















local function Save_Holyday(self, day, index)
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
            Save_Value(self, data.eventID, {
                T=title,
                D=desc
            })
        end
    end
end

local function S_Holyday(self, startIndex)
    if Is_StopRun(self, startIndex) then
        return
    end
    if startIndex==1 then
        C_Calendar.SetAbsMonth(tonumber(date('%M')), tonumber(date('%Y')))
        C_Calendar.SetMonth(-12)
    end

    C_Calendar.SetMonth(1)

    for day=1, 31 do
        for index= 1, C_Calendar.GetNumDayEvents(0, day), 1 do
            Save_Holyday(self, day, index)
        end
    end
    Set_ValueText(self, startIndex)
    C_Timer.After(0.3, function() S_Holyday(self, startIndex+1) end)
end









local function Init_Gossip()
--自定义，对话，文本
    local function Set_Gossip_Text(self, info)
        if info and info.gossipOptionID then
            local text= self:GetText()
            if IsCN(text) then
                WoWTools_SC_Gossip= WoWTools_SC_Gossip or {}
                if not WoWTools_SC_Gossip[info.gossipOptionID] then
                    print(addName, '|cnGREEN_FONT_COLOR:添加|r',info.gossipOptionID, text)
                end
                WoWTools_SC_Gossip[info.gossipOptionID]= text
            end
        end
    end

    hooksecurefunc(GossipOptionButtonMixin, 'Setup', Set_Gossip_Text)
    hooksecurefunc(GossipSharedAvailableQuestButtonMixin, 'Setup', Set_Gossip_Text)
    hooksecurefunc(GossipSharedActiveQuestButtonMixin, 'Setup', Set_Gossip_Text)

    Init_Gossip=function()end
end





















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
    btn:SetPoint('TOPRIGHT', -23*2-13, y)

    function btn:set_event()
        if self:IsVisible() then
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
        else
            self:UnregisterAllEvents()
        end
    end
    btn:SetScript('OnHide', btn.set_event)
    btn:SetScript('OnShow', btn.set_event)
    btn:SetScript('OnEvent', function(self)
        if not self.isStop then
            Settings(self)
        end
    end)
    btn:set_event()

    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(self.text, self.name)
        GameTooltip:AddLine(self.isStop and '|cnGREEN_FONT_COLOR:运行' or '|cffffffff暂停')
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
        WoWTools_Sc_KeepRunName= self.name
        _G['WoWToolsSCKeepRunButton']:set_atlas()
        self:run()
    end)
    btn.run= RUN
    btn.settings= Settings



    btn.bar= CreateFrame('StatusBar', nil, btn)
    btn.bar:SetPoint('RIGHT', btn, 'LEFT', -2, 0)
    btn.bar:SetSize(Frame:GetWidth()-55-23*3, 18)
    btn.bar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOff-Bar-Focus')
    if WoWTools_TextureMixin then
        WoWTools_TextureMixin:SetStatusBar(btn.bar)
    end
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
    btn.clear:SetScript('OnLeave', GameTooltip_Hide)
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
        btn.cahce:SetPoint('LEFT', btn, 'RIGHT')
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
        btn.cahce:SetScript('OnLeave', GameTooltip_Hide)
        btn.cahce:SetScript('OnEnter', function(self)
           self:set_tooltip()
        end)
        function btn.cahce:settings()
            if not self:GetParent().isCahceStop then
                self:SetNormalAtlas('perks-warning-small')
            else
                self:SetNormalAtlas('Islands-QuestTurnin')
            end
        end
        btn.isCahceStop= true
        btn.cahce:settings()
        function btn.cahce:run()
            local p= self:GetParent()
            p.isCahceStop= not p.isCahceStop and true or false
            self.func(p, self.min, 0)
            p.cahceTime= not p.isCahceStop and GetTime() or nil
            self:settings()
            self:set_tooltip()
        end
        btn.cahce:SetScript('OnMouseDown', function(self)
            self:run()
        end)
    end


    btn.view= CreateFrame('Button', nil, btn)
    btn.view.name= name
    btn.view.text= text
    btn.view:SetNormalAtlas('Perks-PreviewOn')
    btn.view:SetPushedAtlas('PetList-ButtonSelect')
    btn.view:SetHighlightAtlas('PetList-ButtonHighlight')
    btn.view:SetPoint('LEFT', btn, 'RIGHT', 23, 0)
    btn.view:SetSize(23,23)
    btn.view:SetScript('OnLeave', GameTooltip_Hide)
    btn.view:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:SetText('查看结果, '..self.text)
        GameTooltip:AddLine(' ')
        GameTooltip_AddErrorLine(GameTooltip, '如果数据太大会出错')
        local va= (Save()[self.name..'Data'] or {})[1]
        if va then
            GameTooltip:AddLine(va:match(' .- .- (.-条)') or va)
        end
        GameTooltip:Show()
    end)
    btn.view:SetScript('OnMouseDown', function(self)
        WoWToolsSCViewFrame:SetText(self.name, self.text)
    end)
    btn.view:SetAlpha(0.3)



    Settings(btn)

    if WoWTools_Sc_KeepRunName==name and WoWTools_SC_IsKeepRun then
        btn:run()
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
    maxButton.texture= maxButton:CreateTexture(nil, "BACKGROUND")
    maxButton.texture:SetAllPoints()
    maxButton.texture:SetColorTexture(0,0,0)
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
        if Frame:IsProtected() and InCombatLockdown() then
            return
        end

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
    function minButton:set_event()
        if self:IsVisible() then
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
        else
            self:UnregisterAllEvents()
        end
    end
    minButton:SetScript('OnHide', minButton.set_event)
    minButton:SetScript('OnShow', function(self)
        self:SetButtonState('NORMAL')
        self:set_event()
    end)
    minButton:SetScript('OnMouseDown', function(self)
        if Frame:IsProtected() and InCombatLockdown() then
            return
        end
        self:GetParent():Hide()
        maxButton:Show()
    end)
    minButton:SetScript('OnEvent', function(self)
        self:GetParent():Hide()
        maxButton:Show()
    end)
    minButton:set_event()

    Frame.Border= CreateFrame('Frame', nil, Frame, 'DialogBorderTemplate')
    Frame.Header= CreateFrame('Frame', nil, Frame, 'DialogHeaderTemplate')--DialogHeaderMixin
    Frame.Header:Setup(addName)


    local note= Frame:CreateFontString(nil, "OVERLAY")
    note:SetFontObject('GameFontNormal')
    note:SetPoint('BOTTOM', 0, 12)
    note:SetText(
        '当前游戏版本 '..Ver
        ..'|n不要一起扫描，数据会出错'
        ..'|n|cffffffff数据：|rWTF\\Account\\...\\SavedVariables\\WoWTools_Chinese_Scanner.lua'
    )



    local clear= CreateFrame('Button', 'WoWToolsSCClearDataButton', Frame, 'UIPanelButtonTemplate')
    clear:SetSize(150, 23)
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
    reload:SetSize(150, 23)
    reload:SetText('重新加载UI')
    reload:SetScript('OnClick', C_UI.Reload)
    reload:SetPoint('BOTTOMRIGHT', -12, 24)

    local keepRun= CreateFrame('CheckButton', 'WoWToolsSCKeepRunButton', Frame, 'UICheckButtonArtTemplate')
    keepRun:SetPoint('BOTTOM', reload, 'TOP')
    keepRun:SetSize(23,23)
    keepRun:SetScript('OnLeave', GameTooltip_Hide)
    function keepRun:set_tooltip()
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText('重新加载UI时，继续上次运行')
        GameTooltip:AddDoubleLine('|cffffffff当前|r '..(WoWTools_Sc_KeepRunName or '|cff626262无'), WoWTools_SC_IsKeepRun and '|cnGREEN_FONT_COLOR:启用' or '|cff626262禁用')
        GameTooltip:Show()
    end
    keepRun:SetScript('OnEnter', keepRun.set_tooltip)
    function keepRun:set_atlas()
        self:SetCheckedTexture(WoWTools_Sc_KeepRunName and 'checkmark-minimal' or 'checkmark-minimal-disabled')
    end
    keepRun:set_atlas()
    keepRun:SetChecked(WoWTools_SC_IsKeepRun)
    keepRun:SetScript('OnMouseDown', function(self)
        WoWTools_SC_IsKeepRun= not WoWTools_SC_IsKeepRun and true or nil
        self:set_tooltip()
    end)

    local loopRun= CreateFrame('CheckButton', 'WoWToolsSCLoopRunButton', Frame, 'UICheckButtonArtTemplate')
    loopRun:SetPoint('RIGHT', keepRun, 'LEFT', -4, 0)
    loopRun:SetSize(23,23)
    loopRun:SetScript('OnLeave', GameTooltip_Hide)
    function loopRun:set_tooltip()
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText('循环运行')
        GameTooltip:AddDoubleLine('完成运行后，再次运行', WoWTools_SC_IsLoopRun and '|cnGREEN_FONT_COLOR:启用' or '|cff626262禁用')
        GameTooltip:Show()
    end
    loopRun:SetScript('OnEnter', loopRun.set_tooltip)
    loopRun:SetCheckedTexture('FlightMasterArgus')
    loopRun:SetChecked(WoWTools_SC_IsLoopRun)
    loopRun:SetScript('OnMouseDown', function(self)
        WoWTools_SC_IsLoopRun= not WoWTools_SC_IsLoopRun and true or nil
        self:set_tooltip()
    end)


    local runCount= CreateFrame('DropdownButton', 'WoWToolsSCRunCountMenuButton', Frame)
    runCount.text= runCount:CreateFontString(nil, nil, 'GameFontNormal')
    runCount.text:SetPoint('CENTER')
    runCount.text:SetJustifyH('CENTER')
    runCount:SetPoint('RIGHT', loopRun, 'LEFT')
    runCount:SetHighlightAtlas('Forge-ColorSwatchSelection')
    runCount:SetPushedAtlas('PetList-ButtonSelect')
    runCount:SetSize(23,23)
    runCount:SetScript('OnLeave', GameTooltip_Hide)
    runCount:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText('每次，运行 '..MaxCount..' 次数')
        GameTooltip:Show()
    end)
    function runCount:settings()
        runCount.text:SetText(MaxCount or 1)
    end
    runCount:SetupMenu(function(self, root)
        for i=1, 10 do
            root:CreateRadio(
                (i==1 and '|cnGREEN_FONT_COLOR:' or '')..i..' 次数',
            function(index)
                return MaxCount==index
            end, function(index)
                Save().runCount= index
                MaxCount= index
                self:settings()
                return MenuResponse.Refresh
            end, i)
        end
    end)
    runCount:settings()


    local out= CreateFrame('Button', 'WoWToolsSCLogoutButton', Frame, 'SecureActionButtonTemplate UIPanelButtonTemplate')
    out:SetSize(80, 23)
    out:SetPoint("TOPLEFT", 40, 0)
    out:SetText('登出')
    out:SetAttribute('type1', 'macro')
    out:SetAttribute("macrotext1", '/logout')
    out:RegisterForClicks('AnyDown')

    if WoWTools_TextureMixin then
        WoWTools_TextureMixin:SetButton(minButton)
        WoWTools_TextureMixin:SetFrame(Frame.Border, {alpha=1})
        WoWTools_TextureMixin:SetFrame(Frame.Header, {alpha=1})
        WoWTools_TextureMixin:SetUIButton(clear)
        WoWTools_TextureMixin:SetUIButton(reload)
        WoWTools_TextureMixin:SetUIButton(out)
        WoWTools_TextureMixin:SetCheckBox(keepRun)
        WoWTools_TextureMixin:SetCheckBox(loopRun)
    end



    









do
    for _, tab in pairs({
        {name='Item', func=S_Item, tooltip='10w0365 02:42', max=MaxItemID, text='物品', atlas='bag-main'},
        {name='Item2', func=S_Item, tooltip='6w9934 04:14', min=MaxItemID+1, max=MaxItemID2, text='物品 II', atlas='bag-main'},
        {name='Sets', func=S_Sets, tooltip='qs 1w1705 00:40', max=MaxSetsID, text='套装', atlas='Warfronts-BaseMapIcons-Alliance-Heroes-Minimap'},
'-',
        {name='Spell', func=S_Spell, tooltip='27w9449', max=MaxSpellID, text='法术', atlas='UI-HUD-MicroMenu-SpellbookAbilities-Mouseover'},
        {name='Spell2', func=S_Spell, tooltip='1w0454', min=MinSpell2ID, max=MaxSpell2ID, text='法术II', atlas='UI-HUD-MicroMenu-SpellbookAbilities-Mouseover'},
'-',
        {name='Unit', func=S_Unit, tooltip='12.0 18w9561 13:12', max=MaxUnitID,text='怪物名称', atlas='BuildanAbomination-32x32'},
        {name='Achievement', func=S_Achievement, cahce=S_CacheAchievement, max=MaxAchievementID,text='成就', tooltip='1w2058', atlas='UI-Achievement-Shield-NoPoints'},
        {name='Quest', func=S_Quest, tooltip='2w0659', max=MaxQuestID,text='任务', atlas='CampaignAvailableQuestIcon'},

        {name='Encounter', func=S_Encounter, tooltip='1k103', max=MaxEncounterID, text='Boss 综述', atlas='adventureguide-icon-whatsnew'},
        {name='SectionEncounter', func=S_SectionEncounter, max=MaxSectionEncounterID, text='Boss 技能', tooltip='12.0 5k363 6k384 4k257 8k499 9k 9k', atlas='KyrianAssaults-64x64'},

        {name='Faction', func=S_Faction, max=MaxFactionID, text='派系', tooltip='12.0 1K713', atlas='VignetteEventElite'},

        '-',
        {name='Holyday', func=S_Holyday, max=24, text='|cff626262节日|r', tooltip='119条'},
    }) do
        if tab=='-' then
            y=y-12
        else
            Create_Button(tab)
        end

        table.insert(Buttons, tab.name)
    end
end












    for class= 1, GetNumClasses() do
        local classInfo = C_CreatureInfo.GetClassInfo(class) or {}

        if classInfo.classFile and classInfo.classID then

            local btn= CreateFrame('Button', 'WoWToolsSCClassButton'..classInfo.classID, Frame)
            table.insert(ClassButton, 'WoWToolsSCClassButton'..classInfo.classID)

            btn.classID= classInfo.classID
            btn.name= classInfo.className

            btn.texture= btn:CreateTexture(nil, 'ARTWORK')
            btn.texture:SetAllPoints()
            btn.texture:SetAtlas('groupfinder-icon-class-'..classInfo.classFile)

            btn:SetSize(23,23)
            btn:SetPoint('BOTTOMLEFT', clear, 'TOPLEFT', classInfo.classID*32, 23)
            btn:SetPushedAtlas('PetList-ButtonSelect')
            btn:SetHighlightAtlas('PetList-ButtonHighlight')
            btn:SetNormalAtlas('groupfinder-icon-class-color-'..classInfo.classFile)
            function btn:get_value()
                return WoWTools_SC_LogClass[self.classID]
            end
            function btn:set_tooltip()
                local n=0
                for _ in pairs(WoWTools_SC_LogClass) do
                    n=n+1
                end
                local all= GetNumClasses()
                GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
                GameTooltip:SetText(self.name or self.classFile)
                GameTooltip:AddDoubleLine(
                    '记录职业: '
                    ..(btn:get_value() and '|cnGREEN_FONT_COLOR:已登入' or '|cff626262未登入'),

                    (n~=all and '' or '|cnGREEN_FONT_COLOR:')
                    ..(n..'/'..all)
                )
                GameTooltip:Show()
            end
            function btn:set_stat()
                self:SetButtonState(self:get_value() and 'PUSHED' or 'NORMAL')
            end
            btn:SetScript('OnLeave', function(self)
                GameTooltip:Hide()
                self:set_stat()
            end)
            btn:SetScript('OnEnter', function(self)
                self:set_tooltip()
                self:SetButtonState('PUSHED')
            end)
            btn:SetScript('OnMouseDown', function(self)
                WoWTools_SC_LogClass[self.classID]= not WoWTools_SC_LogClass[self.classID] and self.classID or nil
                self:set_tooltip()
                self:set_stat()
            end)
            btn:set_stat()
        end
    end

    Frame:SetHeight(-y+110)



    --[[https://wago.tools/db2/Campaign
    for campaignID= 1, 350 do
        Cahce_Campagn(campaignID)
    end]]


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
    MaxCount= Save().runCount or 1

    WoWTools_SC= WoWTools_SC or {isLoopRun=true}

    WoWTools_SC_LogClass= WoWTools_SC_LogClass or {}

    WoWTools_SC_LogClass[PlayerUtil.GetClassID()]= true

    Save().isKeepRun= nil
    Save().isLoopRun= nil
    Save().keepRun= nil

    Init_Gossip()
    Init()
    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)






EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)
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
    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)
