local addonName, addonTable = ...
local frame = CreateFrame("Frame")

-- Initialize modules table
addonTable.modules = {
    deathknight = {},
    paladin = {},
    nameplates = {
        SetupNameplateCastbarScale = function() end  -- Add this stub
    },
    interruptAnnouncer = {
        EnableInterruptAnnouncer = function() end,  -- Stub function that will be replaced
        DisableInterruptAnnouncer = function() end  -- Stub function that will be replaced
    }
}

-- Default settings
MattSimpleTweaksDB_Defaults = {
    enableQuickBind = false,
    enableReloadAlias = false,
    enableEditModeAlias = false,
    enablePerformanceMonitor = false,
    enableInterruptAnnouncer = false, 
    hideHitIndicators = false,
    enableObjectiveFrameScale = false,
    enableStatusBarScale = false,
    enableHideMicroMenu = false,
    enableHideBagBar = false,
    enableActionBarTweaks = false,
    enableActionBarMouseover = false,
    enableBagItemLevels = false,
    enableABGrowth = false,
    hideRuneFrame = false,
    enableNameplateQuestObjectives = false,
    hideHolyPowerBar = false,
    enableHideMacroText = false, 
    enableNameplateCastbarScale = false,
    nameplateCastbarScale = 0.8,
    enableAssistedHighlight = false,
    enableNameplateTargetArrows = false,
}

local function InitializeDB()
    if not MattSimpleTweaksDB then
        MattSimpleTweaksDB = {}
    end
    for k, v in pairs(MattSimpleTweaksDB_Defaults) do
        if MattSimpleTweaksDB[k] == nil then
            MattSimpleTweaksDB[k] = v
        end
    end
end

local function LoadModules()
    if MattSimpleTweaksDB.enableQuickBind or MattSimpleTweaksDB.enableReloadAlias or MattSimpleTweaksDB.enableEditModeAlias then
        addonTable:SetupSlashCommands()
    end
    if MattSimpleTweaksDB.hideHitIndicators then
        addonTable:SetupHideHitIndicators()
    end
    if MattSimpleTweaksDB.enableActionBarTweaks then
        addonTable:SetupActionBarTweaks()
    end
    if MattSimpleTweaksDB.enableObjectiveFrameScale then
        addonTable:SetupObjectiveFrameScale()
    end
    if MattSimpleTweaksDB.enableStatusBarScale then
        addonTable:SetupStatusBarScale()
    end
    if MattSimpleTweaksDB.enablePerformanceMonitor then
        addonTable:SetupPerformanceMonitor()
    end
    if MattSimpleTweaksDB.enableHideMicroMenu then
        addonTable:SetupHideMicroMenu()
    end
    if MattSimpleTweaksDB.enableHideBagBar then
        addonTable:SetupHideBagBar()
    end
    if MattSimpleTweaksDB.enableActionBarMouseover then
        addonTable:SetupActionBarMouseover()
    end
    if MattSimpleTweaksDB.enableBagItemLevels then
        addonTable:EnableBagItemLevels()
    end
    if MattSimpleTweaksDB.hideRuneFrame then
        addonTable.modules.deathknight:SetupHideRuneFrame()
    end
    if MattSimpleTweaksDB.hideHolyPowerBar then
        addonTable.modules.paladin:SetupHideHolyPowerBar()
    end
    if MattSimpleTweaksDB.enableABGrowth then
        addonTable:SetupABGrowth()
    end
    if MattSimpleTweaksDB.enableInterruptAnnouncer then
        addonTable.modules.interruptAnnouncer.EnableInterruptAnnouncer()
    end
    if MattSimpleTweaksDB.enableNameplateCastbarScale then
        addonTable.modules.nameplates:SetupNameplateCastbarScale()
    end
    if MattSimpleTweaksDB.enableNameplateTargetArrows then
        addonTable.modules.nameplates:SetupNameplateTargetArrows()
    end
    if MattSimpleTweaksDB.enableAssistedHighlight then
        addonTable:SetupAssistedHighlight()
    end
end

StaticPopupDialogs["MST_RELOAD_CONFIRM"] = {
    text = "Settings changed. Reload UI now for changes to take effect?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

local function CreateOptionsPanel()
    local optionsFrame = CreateFrame("Frame", "MattSimpleTweaksOptionsFrame", UIParent, "BackdropTemplate")
    optionsFrame:SetSize(700, 500) -- Increased width from 600 to 700 to accommodate new tab
    optionsFrame:SetPoint("CENTER")
    optionsFrame:SetMovable(true)
    optionsFrame:EnableMouse(true)
    optionsFrame:RegisterForDrag("LeftButton")
    optionsFrame:SetScript("OnDragStart", optionsFrame.StartMoving)
    optionsFrame:SetScript("OnDragStop", optionsFrame.StopMovingOrSizing)

    -- Modern dark background
    optionsFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    optionsFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95) -- Dark gray, slightly transparent
    optionsFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1) -- Light gray border

    -- Modern header
    local header = CreateFrame("Frame", nil, optionsFrame, "BackdropTemplate")
    header:SetPoint("TOPLEFT")
    header:SetPoint("TOPRIGHT")
    header:SetHeight(40)
    header:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    header:SetBackdropColor(0.15, 0.15, 0.15, 1) -- Slightly lighter than main background
    header:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    -- Title text
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("CENTER", header, "CENTER")
    title:SetText("MATT'S SIMPLE TWEAKS")
    title:SetTextColor(0.565, 0.894, 0.757) -- Light teal (#90E4C1)

    -- Close button
    local closeButton = CreateFrame("Button", nil, header)
    closeButton:SetSize(24, 24)
    closeButton:SetPoint("TOPRIGHT", -2, -2)
    closeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    closeButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    closeButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
    closeButton:SetScript("OnClick", function() optionsFrame:Hide() end)

    -- Create tab container - Replace the existing tab container creation with this
    local tabContainer = CreateFrame("Frame", nil, optionsFrame, "BackdropTemplate")
    tabContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 5, -5)
    tabContainer:SetPoint("BOTTOMLEFT", optionsFrame, "BOTTOMLEFT", 5, 5)
    tabContainer:SetWidth(120) -- Width of vertical tabs

    -- Create content container - Update the positioning
    local contentContainer = CreateFrame("Frame", nil, optionsFrame, "BackdropTemplate")
    contentContainer:SetPoint("TOPLEFT", tabContainer, "TOPRIGHT", 5, 0)
    contentContainer:SetPoint("BOTTOMRIGHT", optionsFrame, "BOTTOMRIGHT", -5, 5)
    contentContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    contentContainer:SetBackdropColor(0.15, 0.15, 0.15, 1)
    contentContainer:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    -- Create ScrollFrame - ADD THIS SECTION
    local scrollFrame = CreateFrame("ScrollFrame", nil, contentContainer)
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -26, 10)

    -- Create the scrolling content frame
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetSize(scrollFrame:GetWidth(), 1000) -- Set initial height

    -- Create content frames for each category
    local contentFrames = {
        general = CreateFrame("Frame", nil, scrollChild),
        ui = CreateFrame("Frame", nil, scrollChild),
        actionbars = CreateFrame("Frame", nil, scrollChild),
        bags = CreateFrame("Frame", nil, scrollChild),
        nameplates = CreateFrame("Frame", nil, scrollChild),
        classes = CreateFrame("Frame", nil, scrollChild),
        editmode = CreateFrame("Frame", nil, scrollChild)
    }

    -- Set up each content frame
    for _, frame in pairs(contentFrames) do
        frame:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
        frame:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, 0)
        frame:SetHeight(1000) -- Set a fixed initial height
        frame:Hide()
    end

    -- Create the slider (scrollbar)
    local slider = CreateFrame("Slider", nil, scrollFrame, "UIPanelScrollBarTemplate")
    slider:SetPoint("TOPRIGHT", contentContainer, -8, -20)
    slider:SetPoint("BOTTOMRIGHT", contentContainer, -8, 20)
    slider:SetMinMaxValues(0, 1)
    slider:SetValueStep(0.1)
    slider:SetValue(0)
    slider:SetWidth(16)
    slider:SetScript("OnValueChanged", function(self, value)
        scrollFrame:SetVerticalScroll(value)
    end)

    -- Hook scroll frame to update slider
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local current = slider:GetValue()
        local min, max = slider:GetMinMaxValues()
        local step = 30 -- Adjust scroll speed

        if delta > 0 then
            slider:SetValue(math.max(min, current - step))
        else
            slider:SetValue(math.min(max, current + step))
        end
    end)

    -- Function to update scroll range
    local function UpdateScrollRange()
        local height = 0
        for _, frame in pairs(contentFrames) do
            if frame:IsVisible() then
                height = frame:GetHeight()
                break
            end
        end
        
        local viewHeight = scrollFrame:GetHeight()
        if height > viewHeight then
            local difference = height - viewHeight
            slider:SetMinMaxValues(0, difference)
            slider:Show()
        else
            slider:Hide()
        end
        scrollChild:SetHeight(height)
    end

    -- Create tabs
    local tabs = {}
    local tabFrameMap = {
        ["General"] = "general",
        ["UI"] = "ui",
        ["Action Bars"] = "actionbars",
        ["Bags"] = "bags",
        ["Nameplates"] = "nameplates",
        ["Classes"] = "classes",
        ["System"] = "editmode",
    }

    local function CreateTab(id, text)
        local tab = CreateFrame("Button", nil, tabContainer, "BackdropTemplate")
        tab:SetSize(110, 25)
        
        if #tabs == 0 then
            tab:SetPoint("TOPLEFT", 5, -5)
        else
            tab:SetPoint("TOPLEFT", tabs[#tabs], "BOTTOMLEFT", 0, -3)
        end

        tab:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })

        tab.contentFrame = contentFrames[tabFrameMap[text]]

        -- Create and store the text fontstring
        local tabText = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        tabText:SetPoint("CENTER")
        tabText:SetText(text:upper())
        tab.text = tabText -- Store reference to fontstring

        -- Use teal color (matching title) for selected tab
        local isSelected = id == 1
        tab:SetBackdropColor(0.15, 0.15, 0.15, isSelected and 1 or 0.5)
        tab:SetBackdropBorderColor(isSelected and 0.565 or 0.3, isSelected and 0.894 or 0.3, isSelected and 0.757 or 0.3, 1)
        tabText:SetTextColor(isSelected and 0.565 or 0.7, isSelected and 0.894 or 0.7, isSelected and 0.757 or 0.7)

        tab:SetScript("OnClick", function()
            for _, t in pairs(tabs) do
                t.contentFrame:Hide()
                t:SetBackdropColor(0.15, 0.15, 0.15, 0.5)
                t:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                t.text:SetTextColor(0.7, 0.7, 0.7) -- Use stored reference
            end
            tab.contentFrame:Show()
            tab:SetBackdropColor(0.15, 0.15, 0.15, 1)
            tab:SetBackdropBorderColor(0.565, 0.894, 0.757, 1)
            tab.text:SetTextColor(0.565, 0.894, 0.757) -- Use stored reference
            slider:SetValue(0)
            UpdateScrollRange()
        end)

        tab:SetScript("OnEnter", function()
            if tab.contentFrame:IsShown() then return end
            tab:SetBackdropColor(0.15, 0.15, 0.15, 0.8)
            tab:SetBackdropBorderColor(0.565, 0.894, 0.757, 0.5) -- Dimmed teal border on hover
        end)

        tab:SetScript("OnLeave", function()
            if tab.contentFrame:IsShown() then return end
            tab:SetBackdropColor(0.15, 0.15, 0.15, 0.5)
            tab:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        end)

        tabs[#tabs + 1] = tab
        return tab
    end

    -- Create all tabs
    CreateTab(1, "General")
    CreateTab(2, "UI")
    CreateTab(3, "Action Bars")
    CreateTab(4, "Bags")
    CreateTab(5, "Nameplates")
    CreateTab(6, "Classes")
    CreateTab(7, "System")

    -- Show first tab by default
    tabs[1]:Click()

    -- Helper functions
    local function CreateCheckbox(parent, text, dbKey, y, callback)
        local cb = CreateFrame("CheckButton", addonName .. dbKey .. "Checkbox", parent)
        cb:SetSize(20, 20)
        cb:SetPoint("TOPLEFT", 20, y)
        
        -- Modern checkbox textures
        cb:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
        cb:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
        cb:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
        cb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
        
        -- Create primary label
        local mainText = text:match("^([^%-]+)") -- Get text before the dash
        local labelText = cb:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        labelText:SetPoint("LEFT", cb, "RIGHT", 5, 0)
        labelText:SetText(mainText)
        labelText:SetTextColor(1, 1, 1)

        -- Create description text (after the dash)
        local description = text:match("%-(.+)$") -- Get text after the dash
        if description then
            local descText = cb:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
            descText:SetPoint("LEFT", labelText, "RIGHT", 5, 0)
            descText:SetText(description)
            descText:SetTextColor(0.5, 0.5, 0.5)
        end

        labelText:EnableMouse(true)
        labelText:SetScript("OnMouseDown", function() cb:Click() end)

        cb:SetChecked(MattSimpleTweaksDB[dbKey])
        
        -- Handle initial state for performance monitor
        if dbKey == "enablePerformanceMonitor" and not MattSimpleTweaksDB[dbKey] then
            if _G.MattPerfMonitor then
                _G.MattPerfMonitor:Hide()
                _G.MattPerfMonitor = nil
            end
        end
        
        cb:SetScript("OnClick", function(self)
            local wasChecked = MattSimpleTweaksDB[dbKey]
            local isChecked = self:GetChecked()
            MattSimpleTweaksDB[dbKey] = isChecked

            -- Special handling for performance monitor
            if dbKey == "enablePerformanceMonitor" then
                if isChecked then
                    addonTable:SetupPerformanceMonitor()
                else
                    addonTable:DisablePerformanceMonitor()
                end
                return -- Skip reload check for performance monitor
            end

            if callback then callback(isChecked) end

            -- Special handling for Nameplate Quest Objectives: Hide icons immediately if unchecked
            if dbKey == "enableNameplateQuestObjectives" and not isChecked then
                if C_NamePlate then -- Ensure C_NamePlate is available
                    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
                        if namePlate and namePlate.UnitFrame and namePlate.UnitFrame.questIcon then
                            namePlate.UnitFrame.questIcon:Hide()
                        end
                    end
                end
            end

            -- Check if reload is needed
            if wasChecked ~= isChecked then
                if dbKey == "enableHideMicroMenu" or dbKey == "enableHideBagBar" or
                   dbKey == "hideHitIndicators" or dbKey == "enableObjectiveFrameScale" or
                   dbKey == "enablePlayerFrameScale" or dbKey == "enableTargetFrameScale" or
                   dbKey == "enableStatusBarScale" or dbKey == "enableActionBarMouseover" or
                   dbKey == "enableActionBarTweaks" or dbKey == "enableQuickBind" or
                   dbKey == "enableReloadAlias" or dbKey == "enableEditModeAlias" or
                   dbKey == "enableABGrowth" or dbKey == "enableBagItemLevels" or
                   dbKey == "hideRuneFrame" or dbKey == "hideHolyPowerBar" or
                   dbKey == "enableInterruptAnnouncer" or  -- Add this line
                   dbKey == "enableNameplateQuestObjectives" or
                   dbKey == "enableHideMacroText" or
                   dbKey == "enableAssistedHighlight" or
                   dbKey == "enableNameplateTargetArrows" or
                   dbKey == "enableNameplateCastbarScale" then -- Add this line
                    print(addonName .. ": Change to '" .. text .. "' requires a UI reload (/rl) to apply.")
                    StaticPopup_Show("MST_RELOAD_CONFIRM")
                end
            end
        end)

        return cb, y - 25 -- Return the checkbox and new yOffset
    end

    local function CreateSectionHeader(parent, text, color, y)
        local header = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        header:SetPoint("TOPLEFT", 20, y)
        header:SetText(text)
        if color then
            header:SetTextColor(unpack(color))
        end
        return header, y - 30 -- Return header and new y position
    end

    local function AddOptions(frame, options, startY)
        local yOffset = startY or -10
        for _, option in ipairs(options) do
            _, yOffset = CreateCheckbox(frame, option.text, option.key, yOffset)
        end
        return yOffset
    end

    -- Add options to each frame
    AddOptions(contentFrames.general, {
        {text = "Keybind Mode |cffffd100(/kb)|r - Quick keybinding menu", key = "enableQuickBind"},
        {text = "Reload UI |cffffd100(/rl)|r - Quick reload command", key = "enableReloadAlias"},
        {text = "Edit Mode |cffffd100(/edit)|r - Quick edit mode command", key = "enableEditModeAlias"},
        {text = "Performance Monitor - Show FPS & MS |cffff0000(Shift+Left Click to move)|r", key = "enablePerformanceMonitor"},
        {text = "Interrupt Announcer - Auto announce interrupts |cff00ff00[Party]|r |cff00aeff[Raid]|r", key = "enableInterruptAnnouncer"},
    })

    AddOptions(contentFrames.ui, {
    {text = "Hide Combat Text - Remove floating combat text on player/pet frame", key = "hideHitIndicators"},
    {text = "Scale Objective Frame - Reduce objective tracker to |cffffd100(0.7)|r scale", key = "enableObjectiveFrameScale"},
    {text = "Scale Status Bar - Reduce experience/reputation bar to |cffffd100(0.7)|r scale", key = "enableStatusBarScale"},
    {text = "Hide Micro Menu - Hide the game menu buttons", key = "enableHideMicroMenu"},
    {text = "Hide Bag Bar - Hide the bag slot buttons", key = "enableHideBagBar"},
    })

    AddOptions(contentFrames.actionbars, {
        {text = "Better Action Bar Text - Improved hotkey text visibility", key = "enableActionBarTweaks"},
        {text = "Mouseover Fade - Hide action bars 4 & 5 until mouseover", key = "enableActionBarMouseover"},
        {text = "Hide Macro Text - Hide macro text on all action buttons", key = "enableHideMacroText"},
        {text = "Reverse Bar Growth - Action Bar 1 expands upward", key = "enableABGrowth"},
        {text = "Enhanced Assisted Highlight - Brighter, more visible ability highlights", key = "enableAssistedHighlight"},
    })

    -- Create Quest Progress checkbox first, then add description
    local questCheckbox, questDescY = CreateCheckbox(contentFrames.nameplates, "Quest Progress - Display completion numbers on nameplate targets", "enableNameplateQuestObjectives", -10)

    -- Add description for quest progress option
    local questDesc = contentFrames.nameplates:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    questDesc:SetPoint("TOPLEFT", contentFrames.nameplates, "TOPLEFT", 20, questDescY - 5)
    questDesc:SetWidth(380)
    questDesc:SetJustifyH("LEFT")
    questDesc:SetText("Requires UI refresh when changing between larger/smaller nameplates in WoW settings")
    questDesc:SetTextColor(0.5, 0.5, 0.5)  -- Gray color

    -- Add remaining nameplate options
    AddOptions(contentFrames.nameplates, {
        {text = "THICC Enemy Castbars - Increase enemy castbar size to |cffffd100(16px)|r height", key = "enableNameplateCastbarScale"},
        {text = "Target Arrows - Show > < on targeted nameplates", key = "enableNameplateTargetArrows"},
    }, questDescY - 35)

    AddOptions(contentFrames.bags, {
        {text = "Show Item Levels - Display gear iLvl |cffff0000(Combined Backpack Only)|r", key = "enableBagItemLevels"},
    })

    -- System tab content (formerly Edit Mode)
    -- Description text first
    local edmDesc = contentFrames.editmode:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    edmDesc:SetPoint("TOP", contentFrames.editmode, "TOP", 0, -10)
    edmDesc:SetWidth(400)
    edmDesc:SetJustifyH("CENTER")
    edmDesc:SetText("Edit Mode Device Manager automatically sets your preferred Edit Mode WoW layout for each device you play on")
    edmDesc:SetTextColor(1, 1, 1)

    -- Button below description
    local edmButton = CreateFrame("Button", nil, contentFrames.editmode, "UIPanelButtonTemplate")
    edmButton:SetSize(200, 25)
    edmButton:SetPoint("TOP", edmDesc, "BOTTOM", 0, -10)
    edmButton:GetFontString():SetTextColor(1, 1, 1)
    edmButton:SetText("Edit Mode Device Manager")
    
    -- Set button textures to teal
    edmButton.Left:SetVertexColor(0.565, 0.894, 0.757)
    edmButton.Middle:SetVertexColor(0.565, 0.894, 0.757)
    edmButton.Right:SetVertexColor(0.565, 0.894, 0.757)
    
    edmButton:SetScript("OnClick", function()
        if EditModeDeviceManagerFrameOptions then
            optionsFrame:Hide() -- Hide the main options panel
            EditModeDeviceManagerFrameOptions:Show()
            -- Store reference to main options panel
            EditModeDeviceManagerFrameOptions.mainPanel = optionsFrame
        else
            print(addonName .. ": Edit Mode Device Manager is not loaded.")
        end
    end)

    -- Set button textures to teal
    edmButton.Left:SetVertexColor(0.565, 0.894, 0.757)
    edmButton.Middle:SetVertexColor(0.565, 0.894, 0.757)
    edmButton.Right:SetVertexColor(0.565, 0.894, 0.757)
    
    edmButton:SetScript("OnClick", function()
        if EditModeDeviceManagerFrameOptions then
            optionsFrame:Hide() -- Hide the main options panel
            EditModeDeviceManagerFrameOptions:Show()
            -- Store reference to main options panel
            EditModeDeviceManagerFrameOptions.mainPanel = optionsFrame
        else
            print(addonName .. ": Edit Mode Device Manager is not loaded.")
        end
    end)

    -- Add options to Classes frame
    local classY = -10
    local CLASS_COLORS = {
        ["DEATHKNIGHT"] = {0.77, 0.12, 0.23},
        ["DEMONHUNTER"] = {0.64, 0.19, 0.79},
        ["DRUID"] = {1.00, 0.49, 0.04},
        ["EVOKER"] = {0.20, 0.58, 0.50},
        ["HUNTER"] = {0.67, 0.83, 0.45},
        ["MAGE"] = {0.25, 0.78, 0.92},
        ["MONK"] = {0.00, 1.00, 0.59},
        ["PALADIN"] = {0.96, 0.55, 0.73},
        ["PRIEST"] = {1.00, 1.00, 1.00},
        ["ROGUE"] = {1.00, 0.96, 0.41},
        ["SHAMAN"] = {0.00, 0.44, 0.87},
        ["WARLOCK"] = {0.53, 0.53, 0.93},
        ["WARRIOR"] = {0.78, 0.61, 0.43}
    }

    local function CreateClassPlaceholder(parent, y)
        local text = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        text:SetPoint("TOPLEFT", 40, y)
        text:SetText("None")
        text:SetTextColor(0.5, 0.5, 0.5) -- Gray color
        return text, y - 25
    end

    -- Create all class headers first
    local _, newY = CreateSectionHeader(contentFrames.classes, "Deathknight", CLASS_COLORS["DEATHKNIGHT"], classY)
    AddOptions(contentFrames.classes, {
        {text = "Hide Rune Frame", key = "hideRuneFrame"},
    }, newY)

    -- Add remaining class headers with spacing
    local function CreateClassHeader(class, y)
        local displayText = class:sub(1,1) .. class:sub(2):lower()
        local _, newY = CreateSectionHeader(contentFrames.classes, displayText, CLASS_COLORS[class], y)
        
        -- Special handling for Paladin to add options
        if class == "PALADIN" then
            local yPos = AddOptions(contentFrames.classes, {
                {text = "Hide Holy Power Bar", key = "hideHolyPowerBar"},
            }, newY)
            return _, yPos
        end
        
        local _, yPos = CreateClassPlaceholder(contentFrames.classes, newY)
        return _, yPos
    end

    -- Add remaining classes
    local currentY = newY - 30 -- Start after Death Knight section
    _, currentY = CreateClassHeader("DEMONHUNTER", currentY)
    _, currentY = CreateClassHeader("DRUID", currentY - 10)
    _, currentY = CreateClassHeader("EVOKER", currentY - 10)
    _, currentY = CreateClassHeader("HUNTER", currentY - 10)
    _, currentY = CreateClassHeader("MAGE", currentY - 10)
    _, currentY = CreateClassHeader("MONK", currentY - 10)
    _, currentY = CreateClassHeader("PALADIN", currentY - 10)
    _, currentY = CreateClassHeader("PRIEST", currentY - 10)
    _, currentY = CreateClassHeader("ROGUE", currentY - 10)
    _, currentY = CreateClassHeader("SHAMAN", currentY - 10)
    _, currentY = CreateClassHeader("WARLOCK", currentY - 10)
    _, currentY = CreateClassHeader("WARRIOR", currentY - 10)

    SLASH_MATTSIMPLETWEAKS1 = '/mst'
    SlashCmdList["MATTSIMPLETWEAKS"] = function()
        if optionsFrame:IsShown() then
            optionsFrame:Hide()
        else
            optionsFrame:Show()
        end
    end

    optionsFrame:Hide()
    return optionsFrame
end

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        InitializeDB()
        CreateOptionsPanel()
        LoadModules()
        print("|cffff0000" .. addonName .. " loaded. Type /mst for options.|r")
        frame:UnregisterEvent("ADDON_LOADED")
    end
end)

function addonTable:SetupABGrowth()
end