LibFilteredChatPanel = LibFilteredChatPanel or {}
local LFCP = LibFilteredChatPanel

local locked = true

function LFCP.CreateSettingsMenu()
    local LAM = LibAddonMenu2
    -- Register the Options panel with LAM
    local panelData = 
    {
        type = "panel",
        name = LFCP.name,
        author = "Kyzeragon",
        version = LFCP.version,
        -- website = "",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    -- Set the actual panel data
    local optionsData = {
        {
            type = "description",
            title = nil,
            text = "LibFilteredChatPanel provides an extra chat panel for addon authors to display whatever (potentially spammy) messages they want. Each created filter can be toggled on and off by the user, similar to logging levels. See the addon page at esoui.com for library usage.\n\nRight click on the timestamp to duplicate to the text field for copying. Typing in the text field and hitting ENTER will send messages to the \"Player\" filter.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Lock UI",
            tooltip = "Unlock the UI for moving or resizing",
            default = true,
            getFunc = function() return locked end,
            setFunc = function(value)
                locked = value
                if (locked) then
                    FilteredChatPanel:SetMouseEnabled(false)
                else
                    FilteredChatPanel:SetMouseEnabled(true)
                end
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Reset UI",
            tooltip = "Resets the chat panel's position and size",
            width = "full",
            func = function()
                LFCP.savedOptions.window = {
                    left = GuiRoot:GetWidth() - 530,
                    top = GuiRoot:GetHeight() / 2 - 70 - 350,
                    width = 530,
                    height = 700,
                }
                LFCP.AdjustAnchors()

                if (not LFCP.savedOptions.expanded) then
                    FilteredChatPanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GuiRoot:GetWidth(), LibFilteredChatPanel.savedOptions.window.top)
                    FilteredChatPanelContentFooterClose.slide:SetDeltaOffsetX(-LibFilteredChatPanel.savedOptions.window.width - 6)
                    FilteredChatPanelContentFooterClose.slideAnimation:PlayFromStart()
                    FilteredChatPanelContentFooterClose.rotateAnimation:PlayFromStart()
                end
            end
        },
    }

    LibFilteredChatPanel.addonPanel = LAM:RegisterAddonPanel("LibFilteredChatPanelOptions", panelData)
    LAM:RegisterOptionControls("LibFilteredChatPanelOptions", optionsData)
end

function LibFilteredChatPanel.OpenSettingsMenu()
    LibAddonMenu2:OpenToPanel(LibFilteredChatPanel.addonPanel)
end