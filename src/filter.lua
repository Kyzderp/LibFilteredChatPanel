LibFilteredChatPanel = LibFilteredChatPanel or {}
local LFCP = LibFilteredChatPanel

----------------------------------------------------------------------
--[[
filters = {
    ["Player"] = {
        icon = "/esoui/art/asdfasdfs.dds",
        color = {1, 1, 1},
        showIcon = false,
        showTimestamp = true,
        linkOffset = 0,
        lines = {
            {
                time = GetGameTimeMilliseconds(),
                formattedText = "|c888888[12:32:19.081] |r|t12:12:/esoui/art/adsfsdf.dds|t yeeet"
            },
            {
                time = GetGameTimeMilliseconds(),
                formattedText = "yeeet some more"
            },
        }
    }
}
]]
LFCP.filters = {}
LFCP.numFilters = 0

----------------------------------------------------------------------
-- OOP? Trying it out
----------------------------------------------------------------------
local LFCP_Filter = {}
LFCP_Filter.__index = LFCP_Filter

function LFCP_Filter.new(name, icon, color, showIcon, showTimestamp)
    local self = setmetatable({}, LFCP_Filter)
    self.name = name
    self.icon = icon
    self.color = color or {1, 1, 1}
    self.showIcon = showIcon or false
    self.lines = {}
    return self
end

----------------------------------------------------------------------
-- Add a message to a specific filter
-- /script LibFilteredChatPanel.AddColoredText("|H0:LFCP:System2|h|c881122blahblah|r|h", {1, 1, 1})
-- /script for i = 2, 20 do LibFilteredChatPanel:GetSystemFilter():AddMessage("derp" .. tostring(i)) end
-- /script LibFilteredChatPanel:GetSystemFilter():AddMessage("derp21")
----------------------------------------------------------------------
function LFCP_Filter:AddMessage(text)
    local time = GetGameTimeMilliseconds()

    -- Wrap the timestamp in a link so that clicking it will put it in the text field
    local timestamp = string.format("|c888888|H0:LFCP:%s=%d|h[%s.%03d]|h|r ",
        self.name,
        #self.lines + 1,
        string.gsub(string.gsub(FormatTimeMilliseconds(time, TIME_FORMAT_STYLE_RELATIVE_TIMESTAMP), "%[", ""), "%]", ""),
        math.fmod(time, 1000))

    local formattedText = string.format("%s%s%s",
        timestamp,
        self.showIcon and string.format("|t12:12:%s|t ", self.icon) or "",
        text)

    local line = {time = time, formattedText = formattedText, rawText = text}
    table.insert(self.lines, line)

    LFCP.AddColoredText(formattedText, self.color)

    -- Clean up the lines table if it's too large
    if (#self.lines > LFCP.MAX_HISTORY_LINES * 2) then
        d("|cFF0000CLEANING UP LINES TABLE FOR " .. self.name .. "|r")
        -- LFCP.AddColoredText("CLEANING UP LINES TABLE FOR " .. self.name, {1, 0, 0})
        for i = 1, LFCP.MAX_HISTORY_LINES do
            table.remove(self.lines, 1)
        end
    end
end

----------------------------------------------------------------------
-- Entry point to make a filter tab in the panel
----------------------------------------------------------------------
function LFCP:CreateFilter(name, icon, color, showIcon)
    if (LFCP.filters[name]) then
        d("|cFF0000[LFCP] Filter already exists for name " .. name .. "!|r")
        return
    end

    local filter = LFCP_Filter.new(name, icon, color, showIcon)
    LFCP.filters[name] = filter
    LFCP.numFilters = LFCP.numFilters + 1

    local headerControl = CreateControlFromVirtual(
        "$(parent)" .. name, 
        FilteredChatPanelContentHeader,
        "FCPHeaderIcon_Template",
        "")
    headerControl:GetNamedChild("Texture"):SetTexture(icon)

    headerControl:SetAnchor(BOTTOMLEFT, FilteredChatPanelContentHeader, BOTTOMLEFT, (LFCP.numFilters - 1) * 26 + 4, -6)

    filter:AddMessage("Created " .. name .. " filter")

    return filter
end

----------------------------------------------------------------------
-- Allow use of the System filter
----------------------------------------------------------------------
function LFCP:GetSystemFilter()
    return LFCP.filters["System"]
end

