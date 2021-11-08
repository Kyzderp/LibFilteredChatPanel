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
LFCP_Filter = {name = "", icon = "", color = {1, 1, 1}, showIcon = false, showTimestamp = true, lines = {}}

function LFCP_Filter:new(name, icon, color, showIcon, showTimestamp)
    o = {}
    setmetatable(o, self)
    self.__index = self
    self.name = name
    self.icon = icon
    self.color = color or {1, 1, 1}
    self.showIcon = showIcon or false
    self.showTimestamp = showTimestamp or true
    self.lines = {}
    return o
end

----------------------------------------------------------------------
-- Add a message to a specific filter
----------------------------------------------------------------------
function LFCP_Filter:AddMessage(text)
    local time = GetGameTimeMilliseconds()

    local timestamp = string.format("|c888888[%s.%03d]|r ",
        string.gsub(string.gsub(FormatTimeMilliseconds(time, TIME_FORMAT_STYLE_RELATIVE_TIMESTAMP), "%[", ""), "%]", ""),
        math.fmod(time, 1000))

    local formattedText = string.format("%s%s%s",
        self.showTimestamp and timestamp or "",
        self.showIcon and string.format("|t12:12:%s|t ", self.icon) or "",
        text)

    local line = {time = time, formattedText = formattedText}
    table.insert(self.lines, line)

    LFCP.AddColoredText(formattedText, self.color)
end

----------------------------------------------------------------------
-- Entry point to make a filter tab in the panel
----------------------------------------------------------------------
function LFCP.CreateFilter(name, icon, color, showIcon, showTimestamp)
    if (LFCP.filters[name]) then
        d("|cFF0000[LFCP] Filter already exists for name " .. name .. "!|r")
        return
    end

    local filter = LFCP_Filter:new(name, icon, color, showIcon, showTimestamp)
    LFCP.filters[name] = filter
    LFCP.numFilters = LFCP.numFilters + 1

    local headerControl = CreateControlFromVirtual(
        "$(parent)" .. name, 
        FilteredChatPanelContentHeader,
        "FCPHeaderIcon_Template",
        "")
    headerControl:GetNamedChild("Texture"):SetTexture(icon)

    headerControl:SetAnchor(BOTTOMLEFT, FilteredChatPanelContentHeader, BOTTOMLEFT, (LFCP.numFilters - 1) * 26 + 4, -6)

    return filter
end
