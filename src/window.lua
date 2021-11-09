LibFilteredChatPanel = LibFilteredChatPanel or {}
local LFCP = LibFilteredChatPanel

local LFCP_MAX_HISTORY_LINES = 500
LFCP.MAX_HISTORY_LINES = LFCP_MAX_HISTORY_LINES

----------------------------------------------------------------------
-- Yoinked from Combat Metrics - combat log
----------------------------------------------------------------------
local function AdjustSlider()
    local buffer = FilteredChatPanelContentBuffer
    local slider = FilteredChatPanelContentSlider

    local numHistoryLines = buffer:GetNumHistoryLines()
    local numVisHistoryLines = buffer:GetNumVisibleLines() --it seems numVisHistoryLines is getting screwed by UI Scale
    local bufferScrollPos = buffer:GetScrollPosition()

    local sliderMin, sliderMax = slider:GetMinMax()
    local sliderValue = slider:GetValue()

    slider:SetMinMax(numVisHistoryLines, numHistoryLines)

    if sliderValue == sliderMax then -- If the slider's at the bottom, stay at the bottom to show new text
        slider:SetValue(numHistoryLines)
    elseif numHistoryLines == buffer:GetMaxHistoryLines() then -- If the buffer is full start moving the slider up
        slider:SetValue(sliderValue-1)
    end -- Else the slider does not move

    if numHistoryLines > numVisHistoryLines then -- If there are more history lines than visible lines show the slider
        slider:SetHidden(false)
        slider:SetThumbTextureHeight(math.max(20, math.floor(numVisHistoryLines / numHistoryLines * slider:GetHeight())))
    else -- else hide the slider
        slider:SetHidden(true)
    end
end

local function AddColoredText(text, color)
    if not text or #color~=3 then return end

    local red   = color[1] or 1
    local green = color[2] or 1
    local blue  = color[3] or 1

    FilteredChatPanelContentBuffer:AddMessage(text, red, green, blue) -- Add message first

    if FilteredChatPanelContentSlider then AdjustSlider() end -- Set new slider value & check visibility
end
LFCP.AddColoredText = AddColoredText

local function InitBuffer()
    local buffer = FilteredChatPanelContentBuffer
    local slider = FilteredChatPanelContentSlider

    buffer:SetMaxHistoryLines(LFCP_MAX_HISTORY_LINES)
    buffer:SetFont("$(MEDIUM_FONT)|$(KB_13)|soft-shadow-thin")

    buffer:SetHandler("OnMouseWheel", function(self, delta, ctrl, alt, shift)
        local offset = delta
        local slider = buffer:GetParent():GetNamedChild("Slider")

        if shift then
            offset = offset * math.floor((buffer:GetNumVisibleLines()))
        elseif ctrl then
            offset = offset * buffer:GetNumHistoryLines()
        end

        buffer:SetScrollPosition(math.min(buffer:GetScrollPosition() + offset, math.floor(buffer:GetNumHistoryLines()-buffer:GetNumVisibleLines())))
        slider:SetValue(slider:GetValue() - offset)

    end)

    slider:SetHandler("OnValueChanged", function(self, value, eventReason)
        local numHistoryLines = buffer:GetNumHistoryLines()
        local sliderValue = math.max(slider:GetValue(), math.floor((buffer:GetNumVisibleLines()+1)))

        if eventReason == EVENT_REASON_HARDWARE then
            buffer:SetScrollPosition(numHistoryLines-sliderValue)
        end
    end)

    -- Assign Button Functions
    local scrollUp = slider:GetNamedChild("ScrollUp")
    local scrollDown = slider:GetNamedChild("ScrollDown")
    local scrollEnd = slider:GetNamedChild("ScrollEnd")

    scrollUp:SetHandler("OnMouseDown", function(...)
        buffer:SetScrollPosition(math.min(buffer:GetScrollPosition()+1, math.floor(buffer:GetNumHistoryLines()-buffer:GetNumVisibleLines())))
        slider:SetValue(slider:GetValue()-1)
    end)

    scrollDown:SetHandler("OnMouseDown", function(...)
        buffer:SetScrollPosition(buffer:GetScrollPosition()-1)
        slider:SetValue(slider:GetValue()+1)
    end)

    scrollEnd:SetHandler("OnMouseDown", function(...)
        buffer:SetScrollPosition(0)
        slider:SetValue(buffer:GetNumHistoryLines())
    end)
end

----------------------------------------------------------------------
-- Init
----------------------------------------------------------------------
function LFCP.InitializeWindow()
    HUD_SCENE:AddFragment(ZO_SimpleSceneFragment:New(FilteredChatPanel))
    HUD_UI_SCENE:AddFragment(ZO_SimpleSceneFragment:New(FilteredChatPanel))
    FilteredChatPanel:SetHidden(false)

    FilteredChatPanel.slideAnimation = GetAnimationManager():CreateTimelineFromVirtual("ZO_LootSlideInAnimation", FilteredChatPanel)
    FilteredChatPanel.slide = FilteredChatPanel.slideAnimation:GetFirstAnimation()

    InitBuffer()

    if (LFCP.savedOptions.expanded) then
        FilteredChatPanel.slide:SetDeltaOffsetX(-1 * FilteredChatPanelContent:GetWidth())
        FilteredChatPanel.slideAnimation:PlayFromStart()
    end

    LFCP:CreateFilter("System", "/esoui/art/mail/mail_systemicon.dds", {0.93, 0.93, 0}, false)
    LFCP:CreateFilter("Player", "/esoui/art/menubar/gamepad/gp_playermenu_icon_textchat.dds", {0.4, 1, 1}, true)
end
