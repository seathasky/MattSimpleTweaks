-- Modules/ActionBarMouseover.lua
local addonName, addonTable = ...
local db

-- Target Action Bar 4 and 5
local barsToManage = {
    "MultiBarRight",       -- Action Bar 4
    "MultiBarLeft"         -- Action Bar 5
}

-- Track keybind mode using EventRegistry
local isInKeybindMode = false

-- Function to set up mouseover behavior for a single bar frame
local function SetupBarMouseover(barFrame)
    if not barFrame then return end

    local barName = barFrame:GetName()
    if not barName then return end

    -- Make the bar frame itself sensitive to mouse events
    barFrame:EnableMouse(true)
    barFrame:SetAlpha(0)

    local function ShowBar()
        if barFrame and not isInKeybindMode then 
            barFrame:SetAlpha(1) 
        end
    end

    local function HideBar()
        if isInKeybindMode then return end
        
        -- Check if mouse is still over the bar frame OR any of its buttons
        if barFrame and not MouseIsOver(barFrame) then
            local stillOverButton = false
            for i = 1, 12 do
                local button = _G[barName .. "Button" .. i]
                if button and MouseIsOver(button) then
                    stillOverButton = true
                    break
                end
            end
            if not stillOverButton then
                barFrame:SetAlpha(0)
            end
        end
    end

    -- Use HookScript instead of SetScript to preserve existing functionality
    barFrame:HookScript("OnEnter", ShowBar)
    barFrame:HookScript("OnLeave", HideBar)

    -- Also hook scripts on the buttons within the bar
    for i = 1, 12 do
        local button = _G[barName .. "Button" .. i]
        if button then
            button:EnableMouse(true)
            -- Hook instead of replace the button scripts
            button:HookScript("OnEnter", ShowBar)
            button:HookScript("OnLeave", HideBar)
        end
    end
end

-- Function to remove mouseover behavior and reset the bar's appearance
local function ResetBarMouseover(barFrame)
    if not barFrame then return end
    
    -- We can't easily unhook scripts, so just set alpha to 1
    barFrame:SetAlpha(1)
end

-- Function to handle keybind mode changes
local function OnKeybindModeEnabled()
    isInKeybindMode = true
    -- Make bars visible during keybind mode
    for _, barFrameName in ipairs(barsToManage) do
        local barFrame = _G[barFrameName]
        if barFrame then
            barFrame:SetAlpha(1)
        end
    end
end

local function OnKeybindModeDisabled()
    isInKeybindMode = false
    -- Restore mouseover behavior after keybind mode
    for _, barFrameName in ipairs(barsToManage) do
        local barFrame = _G[barFrameName]
        if barFrame then
            -- Set back to transparent, mouseover will show them
            barFrame:SetAlpha(0)
        end
    end
end

-- Main function called when the addon loads and the feature is enabled
function addonTable:SetupActionBarMouseover()
    db = MattSimpleTweaksDB -- Get reference to the saved settings
    -- Exit if the feature is disabled in settings
    if not db or not db.enableActionBarMouseover then return end

    -- Register for keybind mode events
    if EventRegistry then
        EventRegistry:RegisterCallback("QuickKeybindFrame.QuickKeybindModeEnabled", OnKeybindModeEnabled)
        EventRegistry:RegisterCallback("QuickKeybindFrame.QuickKeybindModeDisabled", OnKeybindModeDisabled)
    end

    -- Apply the mouseover setup to each targeted bar
    for _, barFrameName in ipairs(barsToManage) do
        local barFrame = _G[barFrameName]
        if barFrame then
            SetupBarMouseover(barFrame)
        end
    end
end

-- Function called when the feature is disabled
function addonTable:DisableActionBarMouseover()
    -- Reset each targeted bar to ensure they're visible
    for _, barFrameName in ipairs(barsToManage) do
        local barFrame = _G[barFrameName]
        if barFrame then
            ResetBarMouseover(barFrame)
        end
    end
    
    -- Unregister events
    if EventRegistry then
        EventRegistry:UnregisterCallback("QuickKeybindFrame.QuickKeybindModeEnabled", OnKeybindModeEnabled)
        EventRegistry:UnregisterCallback("QuickKeybindFrame.QuickKeybindModeDisabled", OnKeybindModeDisabled)
    end
    
    print(addonName .. ": Action Bar 4 & 5 mouseover disabled.")
end