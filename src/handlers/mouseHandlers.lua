LibFilteredChatPanel = LibFilteredChatPanel or {}
local LFCP = LibFilteredChatPanel

----------------------------------------------------------------------
----------------------------------------------------------------------
function LFCP.OnLinkClicked(button, linkText, linkData)
    if (button == MOUSE_BUTTON_INDEX_RIGHT) then
        -- Copy
        local key = string.gsub(linkData, "0:LFCP:", "")
        local filterName = nil
        local index = nil
        for word in string.gmatch(key, "([^=]+)") do
            if (not filterName) then
                filterName = word
            else
                index = tonumber(word)
            end
        end

        -- Offset due to cleanup
        local filter = LFCP.filters[filterName]
        if (index > #filter.lines) then
            index = index - LFCP.MAX_HISTORY_LINES
        end

        local line = filter.lines[index]
        d(line.formattedText)
        LFCP.SetTextAndFocus(line.rawText)
    end
end
