local function Get_Text(name)
    name= 'WoWTools_SC_'..name

    local data= _G[name] or {}
    local num=0
    local text= name..'={'
    for id, tab in pairs(data) do
        text= text..'|n'

        if type(tab)=='table' then
            text= text..'['..id..']={'

            for t, t2 in pairs(tab) do

                if type(t2)=='table' then
                    text= text..'|n['..t..']={'

                    for s, s2 in pairs(t2) do
                        text= text..'['..s..']="'..tostring(s2)..'",'
                    end

                    text= text..'},'
                else
                    text= text..'|n['..t..']="'..tostring(t2)..'",'
                end
            end
            text= text..'|n},'

        else
            text= text..'|n['..id..']="'..tostring(tab)..'",'
        end
        num= num+1
    end
    text= text..'|n}'

    return text, num
end












EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)

    local frame= CreateFrame('Frame', 'WoWToolsSCViewFrame', WoWTools_SC_Frame)
    tinsert(UISpecialFrames, 'WoWToolsSCViewFrame')

    frame:Hide()
    frame:SetPoint('LEFT', WoWTools_SC_Frame, 'RIGHT')
    frame:SetScript('OnShow', function(self)
        self:SetSize(WoWTools_SC_Frame:GetSize())
    end)
    frame.BGFrame= CreateFrame('Frame', nil, frame, 'TooltipBackdropTemplate')
    frame.BGFrame:SetFrameStrata('BACKGROUND')
    frame.BGFrame:SetPoint('TOPLEFT', -5, 5)
    frame.BGFrame:SetPoint('BOTTOMRIGHT', 0, -5)
    frame.BGFrame:EnableMouse(true)
    frame.BGFrame:SetScript('OnMouseDown', function(s)
        s:GetParent().editBox:SetFocus()
    end)

--Border
    frame.Border= CreateFrame('Frame', nil, frame, 'DialogBorderTemplate')
    --frame.Border.Bg:SetTexture('Interface\\AddOns\\WoWTools\\Source\\Background\\Black.tga')
--Header
    frame.Header= CreateFrame('Frame', nil, frame, 'DialogHeaderTemplate')--DialogHeaderMixin
    frame.Header:SetFrameStrata('HIGH')
--CloseButton
    frame.CloseButton=CreateFrame('Button', nil, frame, 'UIPanelCloseButton')--SharedUIPanelTemplates.xml
    frame.CloseButton:SetPoint('TOPRIGHT')
    frame.CloseButton:SetFrameStrata('HIGH')





    local scrollFrame= CreateFrame('ScrollFrame', nil, frame, 'ScrollFrameTemplate')--InputScrollFrameTemplate SecureUIPanelTemplates.xml
    scrollFrame:HookScript('OnSizeChanged', function(s)
        s:GetParent().editBox:SetWidth(s:GetWidth()-23)
    end)
    scrollFrame:SetPoint('TOPLEFT', 11, -32)
    scrollFrame:SetPoint('BOTTOMRIGHT', -6, 12)
    local level= scrollFrame:GetFrameLevel()

    scrollFrame.ScrollBar:ClearAllPoints()--MinimalScrollBar
    scrollFrame.ScrollBar:SetPoint('TOPRIGHT', -8, -32)
    scrollFrame.ScrollBar:SetPoint('BOTTOMRIGHT', -8, 32)


    frame.ScrollToBottomButton= CreateFrame('Button', nil, scrollFrame.ScrollBar)
    frame.ScrollToBottomButton:SetSize(17,15)
    frame.ScrollToBottomButton:SetPoint('TOP', scrollFrame.ScrollBar, 'BOTTOM')
    frame.ScrollToBottomButton:SetNormalAtlas('minimal-scrollbar-arrow-returntobottom')
    frame.ScrollToBottomButton:SetPushedAtlas('minimal-scrollbar-arrow-returntobottom-down')
    frame.ScrollToBottomButton:SetHighlightAtlas('minimal-scrollbar-arrow-returntobottom-over')


    frame.ScrollToBottomButton:SetScript('OnMouseDown', function(b)
        b:GetParent():ScrollToEnd()
    end)

    frame.ScrollToBeginButton= CreateFrame('Button', nil, scrollFrame.ScrollBar)
    frame.ScrollToBeginButton:SetSize(17,15)
    frame.ScrollToBeginButton:SetPoint('BOTTOM', scrollFrame.ScrollBar, 'TOP')
    frame.ScrollToBeginButton:SetNormalAtlas('minimal-scrollbar-arrow-returntobottom')
    frame.ScrollToBeginButton:SetPushedAtlas('minimal-scrollbar-arrow-returntobottom-down')
    frame.ScrollToBeginButton:SetHighlightAtlas('minimal-scrollbar-arrow-returntobottom-over')

    frame.ScrollToBeginButton:GetNormalTexture():SetTexCoord(0,1,1,0)
    frame.ScrollToBeginButton:GetPushedTexture():SetTexCoord(0,1,1,0)
    frame.ScrollToBeginButton:GetHighlightTexture():SetTexCoord(0,1,1,0)

    frame.ScrollToBeginButton:SetScript('OnMouseDown', function(b)
        b:GetParent():ScrollToBegin()
    end)





    frame.editBox= CreateFrame('EditBox', nil, scrollFrame)--, 'SearchBoxTemplate')
    frame.editBox:SetAutoFocus(false)
    frame.editBox:ClearFocus()
    frame.editBox:SetFontObject('ChatFontNormal')
    frame.editBox:SetPoint('TOPLEFT', scrollFrame, 'TOPLEFT')
    frame.editBox:SetPoint('BOTTOMRIGHT', scrollFrame, 'BOTTOMRIGHT')

    frame.editBox:SetScript('OnEscapePressed', EditBox_ClearFocus)
    frame.editBox:SetScript('OnHide', function(s)
        if s:HasFocus() then
            s:ClearFocus()
        end
        s:SetText('')
    end)

    frame.editBox:SetMultiLine(true)
    frame.editBox:SetFrameLevel(level+2)
    frame.editBox:SetScript('OnUpdate', function(s, elapsed) ScrollingEdit_OnUpdate(s, elapsed, s:GetParent()) end)
    frame.editBox:SetScript('OnCursorChanged', ScrollingEdit_OnCursorChanged)



    frame.Instructions= frame.editBox:CreateFontString(nil, 'BORDER', 'GameFontNormal')
    frame.Instructions:SetPoint('BOTTOMRIGHT', frame.editBox)

    scrollFrame:SetScrollChild(frame.editBox)

--材质
    if WoWTools_TextureMixin then
        WoWTools_TextureMixin:SetButton(frame.CloseButton)
        WoWTools_TextureMixin:SetScrollBar(scrollFrame)
        WoWTools_TextureMixin:SetButton(frame.ScrollToBottomButton)
        WoWTools_TextureMixin:SetButton(frame.ScrollToBeginButton)
        WoWTools_TextureMixin:SetNineSlice(frame.BGFrame)
        WoWTools_TextureMixin:SetEditBox(frame.editBox)
        WoWTools_TextureMixin:SetFrame(frame.Header, {alpha=1})
        WoWTools_TextureMixin:SetFrame(frame.Border, {alpha=1})
    end


    function frame:SetText(name, header)
        local text, num= Get_Text(name)
        self.editBox:SetText(text)
        self.Header:Setup(header or '')
        self.Instructions:SetFormattedText('%d', num)
        self:SetShown(true)
    end


    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)
