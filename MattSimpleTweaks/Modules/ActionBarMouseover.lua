-- Modules/ActionBarMouseover.lua
local addonName, addonTable = ...
local db

-- Target Action Bar 4 and 5
local barsToManage = {
    "MultiBarRight",       -- Action Bar 4
    "MultiBarLeft"         -- Action Bar 5
}

-- Track if we are in Quick Keybind Mode
local inQuickKeybindMode = false

-- Function to set up mouseover behavior for a single bar frame
local function SetupBarMouseover(barFrame)
    if not barFrame then return end

    local barName = barFrame:GetName()
    if not barName then return end -- Need the name to find buttons


    -- Make the bar frame itself sensitive to mouse events
    barFrame:EnableMouse(true)

    -- Set initial state: transparent, unless in Quick Keybind Mode
    if inQuickKeybindMode then
        barFrame:SetAlpha(1)
    else
        barFrame:SetAlpha(0)
    end

    local function ShowBar()
        if barFrame then barFrame:SetAlpha(1) end
    end

    local function HideBar()
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


    -- Script for the main bar frame (disable in Quick Keybind Mode)
    if not inQuickKeybindMode then
        barFrame:SetScript("OnEnter", ShowBar)
        barFrame:SetScript("OnLeave", HideBar)
    else
        barFrame:SetScript("OnEnter", nil)
        barFrame:SetScript("OnLeave", nil)
    end

    -- Also apply scripts to the buttons within the bar
    for i = 1, 12 do
        local button = _G[barName .. "Button" .. i]
        if button then
            button:EnableMouse(true) -- Ensure buttons are mouse enabled
            if not inQuickKeybindMode then
                button:SetScript("OnEnter", ShowBar) -- Entering a button shows the bar
                button:SetScript("OnLeave", HideBar) -- Leaving a button checks if we should hide the bar
            else
                button:SetScript("OnEnter", nil)
                button:SetScript("OnLeave", nil)
            end
        end
    end
end

-- Function to remove mouseover behavior and reset the bar's appearance
local function ResetBarMouseover(barFrame)
    if not barFrame then return end
    local barName = barFrame:GetName()


    -- Remove the custom scripts from the bar
    barFrame:SetScript("OnEnter", nil)
    barFrame:SetScript("OnLeave", nil)

    -- Set alpha to full visibility
    barFrame:SetAlpha(1)

    -- Remove scripts from buttons
    if barName then
        for i = 1, 12 do
            local button = _G[barName .. "Button" .. i]
            if button then
                button:SetScript("OnEnter", nil)
                button:SetScript("OnLeave", nil)
                -- Don't disable mouse on buttons, other things might need it
            end
        end
    end
end

-- Main function called when the addon loads and the feature is enabled
function addonTable:SetupActionBarMouseover()
    db = MattSimpleTweaksDB -- Get reference to the saved settings
    -- Exit if the feature is disabled in settings
    if not db or not db.enableActionBarMouseover then return end

    -- Apply the mouseover setup to each targeted bar
    for _, barFrameName in ipairs(barsToManage) do
        local barFrame = _G[barFrameName]
        if barFrame then
            SetupBarMouseover(barFrame)
        else
            print(addonName .. ": Warning - Frame not found during setup: " .. barFrameName)
        end
    end
end

-- Function called potentially when the feature is disabled (requires reload for clean state)
function addonTable:DisableActionBarMouseover()
    -- Reset each targeted bar
    for _, barFrameName in ipairs(barsToManage) do
        local barFrame = _G[barFrameName]
        if barFrame then
            ResetBarMouseover(barFrame)
        else
             print(addonName .. ": Warning - Frame not found during disable: " .. barFrameName)
        end
    end
    -- Inform user that a reload is best for clean reset
    print(addonName .. ": Action Bar 4 & 5 mouseover disabled (requires UI reload to fully reset).")
end


local function ForceKeybindableBars()
    if not inQuickKeybindMode then return end
    for _, barFrameName in ipairs(barsToManage) do
        local barFrame = _G[barFrameName]
        if barFrame then
            barFrame:EnableMouse(true)
            barFrame:SetAlpha(1)
            local barName = barFrame:GetName()
            for i = 1, 12 do
                local button = _G[barName .. "Button" .. i]
                if button then
                    button:EnableMouse(true)
                    button:SetAlpha(1)
                end
            end
        end
    end
end

local function OnQuickKeybindModeChanged()
    inQuickKeybindMode = QuickKeybindFrame and QuickKeybindFrame:IsShown()
    -- Re-apply mouseover or always-visible logic
    for _, barFrameName in ipairs(barsToManage) do
        local barFrame = _G[barFrameName]
        if barFrame then
            SetupBarMouseover(barFrame)
        end
    end
    ForceKeybindableBars()
end

local quickKeybindWatcher = CreateFrame("Frame")
quickKeybindWatcher:RegisterEvent("PLAYER_LOGIN")
quickKeybindWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
quickKeybindWatcher:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        if QuickKeybindFrame and not quickKeybindWatcher._hooked then
            QuickKeybindFrame:HookScript("OnShow", OnQuickKeybindModeChanged)
            QuickKeybindFrame:HookScript("OnHide", OnQuickKeybindModeChanged)
            quickKeybindWatcher._hooked = true
        end
    end
end)

local function ForceKeybindableBars()
    if not inQuickKeybindMode then return end
    for _, barFrameName in ipairs(barsToManage) do
        local barFrame = _G[barFrameName]
        if barFrame then
            barFrame:EnableMouse(true)
            barFrame:SetAlpha(1)
            local barName = barFrame:GetName()
            for i = 1, 12 do
                local button = _G[barName .. "Button" .. i]
                if button then
                    button:EnableMouse(true)
                    button:SetAlpha(1)
                end
            end
        end
    end
end