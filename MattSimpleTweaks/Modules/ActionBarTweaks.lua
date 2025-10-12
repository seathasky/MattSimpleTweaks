local addonName, addonTable = ...

local NAOWH_FONT = "Interface\\AddOns\\MattSimpleTweaks\\Media\\Fonts\\Naowh.ttf"

local function ScaleActionBars()
    local keybindScale = 2
    local macroScale = 1.3
    for i=1,12 do
        local elements = {
            _G["ActionButton" .. i .. "Count"],
            _G["ActionButton" .. i .. "HotKey"],
            _G["ActionButton" .. i .. "Name"],
            _G["MultiBarBottomLeftButton" .. i .. "Count"],
            _G["MultiBarBottomLeftButton" .. i .. "HotKey"],
            _G["MultiBarBottomLeftButton" .. i .. "Name"],
            _G["MultiBarBottomRightButton" .. i .. "Count"],
            _G["MultiBarBottomRightButton" .. i .. "HotKey"],
            _G["MultiBarBottomRightButton" .. i .. "Name"],
            _G["MultiBarRightButton" .. i .. "Count"],
            _G["MultiBarRightButton" .. i .. "HotKey"],
            _G["MultiBarRightButton" .. i .. "Name"],
            _G["MultiBarLeftButton" .. i .. "Count"],
            _G["MultiBarLeftButton" .. i .. "HotKey"],
            _G["MultiBarLeftButton" .. i .. "Name"]
        }
        
        for _, element in pairs(elements) do
            if element then -- Check if element exists
                local isHotKey = element:GetName():match("HotKey")
                element:SetFont(NAOWH_FONT, 10, "OUTLINE")  -- Fixed NAOWH to NAOWH_FONT
                element:SetTextScale(isHotKey and keybindScale or macroScale)
                if isHotKey then
                    element:SetTextColor(1, 1, 1)
                end
            end
        end
    end
end

local map = {
    ["Middle Mouse"] = "M3",
    ["Mouse Wheel Down"] = "WD",
    ["Mouse Wheel Up"] = "WP",
    ["Home"] = "Hm",
    ["Insert"] = "Ins",
    ["Page Down"] = "PD",
    ["Page Up"] = "PU",
    ["Spacebar"] = "SpB",
}

local patterns = {
    ["Middle Mouse"] = "M3",
    ["Mouse Wheel Down"] = "WD",
    ["Mouse Wheel Up"] = "WP",
    ["Mouse Button "] = "M", -- M4, M5
    ["Mouse Button 4 "] = "M4", -- M4, M5
    ["Mouse Button 5 "] = "M5", -- M4, M5
    ["Num Pad "] = "N",
    ["a%-"] = "A", -- alt
    ["c%-"] = "C", -- ctrl
    ["s%-"] = "S", -- shift
}

local bars = {
    "ActionButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarLeftButton",
    "MultiBarRightButton",
    "MultiBar5Button",
    "MultiBar6Button",
    "MultiBar7Button",
}

local function UpdateHotkey(self, actionButtonType)
    local hotkey = self.HotKey
    local text = hotkey:GetText()
    if not text then return end -- Add check for nil text

    for k, v in pairs(patterns) do
        text = text:gsub(k, v)
    end
    text = map[text] or text
    hotkey:SetText(string.sub(text, 1, 2)) -- Truncate to 2 characters
end

-- Add new function to handle macro text visibility
local function UpdateMacroText(button)
    if MattSimpleTweaksDB.enableHideMacroText then
        if button.Name then
            button.Name:Hide()
        end
    else
        if button.Name then
            button.Name:Show()
        end
    end
end

-- Define the setup function expected by the core file
function addonTable:SetupActionBarTweaks()
    -- Call the scaling function immediately
    ScaleActionBars()

    -- Hook the hotkey updates
    for _, bar in pairs(bars) do
        for i = 1, NUM_ACTIONBAR_BUTTONS do
            -- Ensure the button exists before hooking
            local button = _G[bar..i]
            if button then
                hooksecurefunc(button, "UpdateHotkeys", UpdateHotkey)
                -- Apply macro text visibility
                UpdateMacroText(button)
                -- Hook button updates to maintain macro text state
                hooksecurefunc(button, "Update", function(self)
                    UpdateMacroText(self)
                end)
            end
        end
    end
end