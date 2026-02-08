local addonName, addonTable = ...
local frame = CreateFrame("Frame")

-- Initialize modules table
addonTable.modules = {}

-- Default settings
MattSimpleTweaksDB_Defaults = {
    enableQuickBind = false,
    enableReloadAlias = false,
    enableEditModeAlias = false,
    enablePullAlias = false,
    enablePerformanceMonitor = false,
    enableEditModeDeviceManager = false,
    enableObjectiveFrameScale = false,
    enableStatusBarScale = false,
    enableHideMicroMenu = false,
    enableHideBagBar = false,
    enableActionBarTweaks = false,
    actionBarFontScale = 1.0,
    enableActionBarMouseover = false,
    enableBagItemLevels = false,
    enableAutoRepair = false,
    autoRepairFundingSource = "GUILD",
    enableAutoSellJunk = false,
    enableABGrowth = false,
    enableHideMacroText = false,
    enableAutoAcceptQuests = false,
    enableAutoTurnInQuests = false,
}
-- Saved var defaults for minimap launcher
MattSimpleTweaksDB_Defaults.minimap = {}

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
    if MattSimpleTweaksDB.enableQuickBind or MattSimpleTweaksDB.enableReloadAlias or MattSimpleTweaksDB.enableEditModeAlias or MattSimpleTweaksDB.enablePullAlias then
        addonTable:SetupSlashCommands()
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
    if MattSimpleTweaksDB.enableAutoRepair or MattSimpleTweaksDB.enableAutoSellJunk then
        addonTable:SetupMerchantTweaks()
    end
    if MattSimpleTweaksDB.enableABGrowth then
        addonTable:SetupABGrowth()
    end
    if MattSimpleTweaksDB.enableAutoAcceptQuests or MattSimpleTweaksDB.enableAutoTurnInQuests then
        addonTable:SetupQuestTweaks()
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

--GUI height and width
local function CreateOptionsPanel()
    local optionsFrame = CreateFrame("Frame", "MattSimpleTweaksOptionsFrame", UIParent, "BackdropTemplate")
    optionsFrame:SetSize(650, 350)
    optionsFrame:SetPoint("CENTER")
    optionsFrame:SetMovable(true)
    optionsFrame:EnableMouse(true)
    optionsFrame:RegisterForDrag("LeftButton")
    optionsFrame:SetScript("OnDragStart", optionsFrame.StartMoving)
    optionsFrame:SetScript("OnDragStop", optionsFrame.StopMovingOrSizing)

    -- Ensure the options window stays above other UI elements
    optionsFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    optionsFrame:SetFrameLevel(100)
    optionsFrame:SetToplevel(true)
    optionsFrame:SetClampedToScreen(true)
    optionsFrame:SetScript("OnShow", function(self) self:SetFrameLevel(100) end)

    optionsFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    optionsFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    optionsFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    -- Header
    local header = CreateFrame("Frame", nil, optionsFrame, "BackdropTemplate")
    header:SetPoint("TOPLEFT")
    header:SetPoint("TOPRIGHT")
    header:SetHeight(40)
    header:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    header:SetBackdropColor(0.15, 0.15, 0.15, 1)
    header:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("CENTER", header, "CENTER")
    title:SetText("MATT'S SIMPLE TWEAKS")
    title:SetTextColor(0.565, 0.894, 0.757)

    -- Close button
    local closeButton = CreateFrame("Button", nil, header)
    closeButton:SetSize(24, 24)
    closeButton:SetPoint("TOPRIGHT", -2, -2)
    closeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    closeButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    closeButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
    closeButton:SetScript("OnClick", function() optionsFrame:Hide() end)

    -- Minimap icon hide/show checkbox (left of close button)
    local hideMinimapChk = CreateFrame("CheckButton", nil, header, "UICheckButtonTemplate")
    hideMinimapChk:SetSize(24, 24)
    hideMinimapChk:SetPoint("TOPRIGHT", -28, -2)

    local function UpdateHideMinimapButton()
        MattSimpleTweaksDB.minimap = MattSimpleTweaksDB.minimap or {}
        local db = MattSimpleTweaksDB.minimap
        if db.hide then
            hideMinimapChk:SetChecked(false)
        else
            hideMinimapChk:SetChecked(true)
        end
    end

    hideMinimapChk:SetScript("OnClick", function(self)
        MattSimpleTweaksDB.minimap = MattSimpleTweaksDB.minimap or {}
        local db = MattSimpleTweaksDB.minimap
        db.hide = not self:GetChecked()
        local LDBI = LibStub and LibStub("LibDBIcon-1.0", true)
        if LDBI then
            LDBI:Refresh(addonName, db)
        end
        UpdateHideMinimapButton()
    end)

    hideMinimapChk:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Minimap Icon")
        GameTooltip:Show()
    end)

    hideMinimapChk:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- label for the minimap checkbox
    local hideMinimapLabel = header:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    hideMinimapLabel:SetPoint("RIGHT", hideMinimapChk, "LEFT", -6, 0)
    hideMinimapLabel:SetText("Minimap Icon")
    hideMinimapLabel:SetTextColor(1, 1, 1)

    -- initialize checkbox state
    UpdateHideMinimapButton()

    -- Tab container
    local tabContainer = CreateFrame("Frame", nil, optionsFrame, "BackdropTemplate")
    tabContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 5, -5)
    tabContainer:SetPoint("BOTTOMLEFT", optionsFrame, "BOTTOMLEFT", 5, 5)
    tabContainer:SetWidth(120)

    -- Content container
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

    -- Content area (scrolling disabled)
    local scrollFrame = CreateFrame("Frame", nil, contentContainer)
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -26, 10)

    -- Content frames
    local contentFrames = {
        general = CreateFrame("Frame", nil, scrollFrame),
        ui = CreateFrame("Frame", nil, scrollFrame),
        actionbars = CreateFrame("Frame", nil, scrollFrame),
        bags = CreateFrame("Frame", nil, scrollFrame),
        quests = CreateFrame("Frame", nil, scrollFrame),
        editmode = CreateFrame("Frame", nil, scrollFrame)
    }

    -- Set up each content frame
    for _, frame in pairs(contentFrames) do
        frame:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
        frame:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 0, 0)
        frame:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 0)
        frame:Hide()
    end

    -- Scrolling disabled: no scrollbar or mousewheel handling

    -- Scrolling disabled: UpdateScrollRange is a no-op
    local function UpdateScrollRange()
        -- Intentionally left blank since scrolling is disabled
    end

    -- Create tabs
    local tabs = {}
    local tabFrameMap = {
        ["General"] = "general",
        ["UI"] = "ui",
        ["Action Bars"] = "actionbars",
        ["Bags"] = "bags",
        ["Quests"] = "quests",
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

        local tabText = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        tabText:SetPoint("CENTER")
        tabText:SetText(text:upper())
        tab.text = tabText

        local isSelected = id == 1
        tab:SetBackdropColor(0.15, 0.15, 0.15, isSelected and 1 or 0.5)
        tab:SetBackdropBorderColor(isSelected and 0.565 or 0.3, isSelected and 0.894 or 0.3, isSelected and 0.757 or 0.3, 1)
        tabText:SetTextColor(isSelected and 0.565 or 0.7, isSelected and 0.894 or 0.7, isSelected and 0.757 or 0.7)

        tab:SetScript("OnClick", function()
            for _, t in pairs(tabs) do
                t.contentFrame:Hide()
                t:SetBackdropColor(0.15, 0.15, 0.15, 0.5)
                t:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                t.text:SetTextColor(0.7, 0.7, 0.7)
            end
            tab.contentFrame:Show()
            tab:SetBackdropColor(0.15, 0.15, 0.15, 1)
            tab:SetBackdropBorderColor(0.565, 0.894, 0.757, 1)
            tab.text:SetTextColor(0.565, 0.894, 0.757)
            UpdateScrollRange()
        end)

        tab:SetScript("OnEnter", function()
            if tab.contentFrame:IsShown() then return end
            tab:SetBackdropColor(0.15, 0.15, 0.15, 0.8)
            tab:SetBackdropBorderColor(0.565, 0.894, 0.757, 0.5)
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
    CreateTab(5, "Quests")
    CreateTab(6, "System")

    tabs[1]:Click()

    -- Helper functions
    local function CreateCheckbox(parent, text, dbKey, y, callback)
        local cb = CreateFrame("CheckButton", addonName .. dbKey .. "Checkbox", parent)
        cb:SetSize(20, 20)
        cb:SetPoint("TOPLEFT", 20, y)
        
        cb:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
        cb:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
        cb:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
        cb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
        
        local mainText = text:match("^([^%-]+)")
        local labelText = cb:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        labelText:SetPoint("LEFT", cb, "RIGHT", 5, 0)
        labelText:SetText(mainText)
        labelText:SetTextColor(1, 1, 1)
        if dbKey == "enableAutoTurnInQuests" then
            labelText:SetFontObject("GameFontHighlight")
        end

        local description = text:match("%-(.+)$")
        if description then
            local descText = cb:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
            descText:SetPoint("LEFT", labelText, "RIGHT", 5, 0)
            descText:SetText(description)
            descText:SetTextColor(0.5, 0.5, 0.5)
        end

        labelText:EnableMouse(true)
        labelText:SetScript("OnMouseDown", function() cb:Click() end)

        cb:SetChecked(MattSimpleTweaksDB[dbKey])
        
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

            if dbKey == "enablePerformanceMonitor" then
                if isChecked then
                    addonTable:SetupPerformanceMonitor()
                else
                    addonTable:DisablePerformanceMonitor()
                end
            end
            if dbKey == "enableAutoRepair" or dbKey == "enableAutoSellJunk" then
                addonTable:SetupMerchantTweaks()
            end
            if dbKey == "enableAutoAcceptQuests" or dbKey == "enableAutoTurnInQuests" then
                addonTable:SetupQuestTweaks()
            end

            if callback then callback(isChecked) end


            if wasChecked ~= isChecked then
                print(addonName .. ": Change to '" .. text .. "' requires a UI reload (/rl) to apply.")
                StaticPopup_Show("MST_RELOAD_CONFIRM")
            end
        end)

        return cb, y - 25
    end

    local function CreateSectionHeader(parent, text, color, y)
        local header = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        header:SetPoint("TOPLEFT", 20, y)
        header:SetText(text)
        if color then
            header:SetTextColor(unpack(color))
        end
        return header, y - 30
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
        {text = "Pull Timer |cffffd100(/pull X)|r - Alias for countdown with seconds", key = "enablePullAlias"},
        {text = "Performance Monitor - Show FPS & MS |cffff0000(Shift+Left Click to move)|r", key = "enablePerformanceMonitor"},
    })

    AddOptions(contentFrames.ui, {
        {text = "Scale Objective Frame - Reduce objective tracker to |cffffd100(0.7)|r scale", key = "enableObjectiveFrameScale"},
        {text = "Scale Status Bar - Reduce experience/reputation bar to |cffffd100(0.7)|r scale", key = "enableStatusBarScale"},
        {text = "Hide Micro Menu - Hide the game menu buttons", key = "enableHideMicroMenu"},
        {text = "Hide Bag Bar - Hide the bag slot buttons", key = "enableHideBagBar"},
    })


    -- Better Action Bar Text with font scale slider
    local abTextCheckbox, abTextY = CreateCheckbox(contentFrames.actionbars, "Better Action Bar Text - Improved hotkey text visibility", "enableActionBarTweaks", -10)


    local scaleY = abTextY - 25

    local fontScaleLabel = contentFrames.actionbars:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fontScaleLabel:SetPoint("TOPLEFT", contentFrames.actionbars, "TOPLEFT", 35, scaleY)
    fontScaleLabel:SetText("Font Scale:")

    local fontScaleSlider = CreateFrame("Slider", "MST_ABFontScaleSlider", contentFrames.actionbars, "OptionsSliderTemplate")
    fontScaleSlider:SetPoint("LEFT", fontScaleLabel, "RIGHT", 10, 0)
    fontScaleSlider:SetMinMaxValues(0.5, 2.0)
    fontScaleSlider:SetValue(MattSimpleTweaksDB.actionBarFontScale or 1.0)
    fontScaleSlider:SetValueStep(0.1)
    fontScaleSlider:SetObeyStepOnDrag(true)
    fontScaleSlider:SetWidth(150)
    _G[fontScaleSlider:GetName() .. "Low"]:SetText("0.5")
    _G[fontScaleSlider:GetName() .. "High"]:SetText("2.0")
    _G[fontScaleSlider:GetName() .. "Text"]:SetText(string.format("%.1f", MattSimpleTweaksDB.actionBarFontScale or 1.0))

    fontScaleSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 10 + 0.5) / 10
        MattSimpleTweaksDB.actionBarFontScale = value
        _G[self:GetName() .. "Text"]:SetText(string.format("%.1f", value))
        if addonTable.UpdateActionBarFontScale then
            addonTable.UpdateActionBarFontScale(value)
        end
    end)

    AddOptions(contentFrames.actionbars, {
        {text = "Mouseover Fade - Hide action bars 4 & 5 until mouseover", key = "enableActionBarMouseover"},
        {text = "Hide Macro Text - Hide macro text on all action buttons", key = "enableHideMacroText"},
        {text = "Reverse Bar Growth - Action Bar 1 expands upward", key = "enableABGrowth"},
    }, scaleY - 45)

    local bagsY = AddOptions(contentFrames.bags, {
        {text = "Show Item Levels - Display gear iLvl |cffff0000(Combined Backpack Only)|r", key = "enableBagItemLevels"},
        {text = "Auto Repair - Repair all gear when opening a vendor", key = "enableAutoRepair"},
    })

    local fundingHeader = contentFrames.bags:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fundingHeader:SetPoint("TOPLEFT", contentFrames.bags, "TOPLEFT", 35, bagsY)
    fundingHeader:SetText("Auto Repair Funding:")
    fundingHeader:SetTextColor(0.9, 0.9, 0.9)

    local guildFundingCB = CreateFrame("CheckButton", addonName .. "AutoRepairGuildFunding", contentFrames.bags)
    guildFundingCB:SetSize(20, 20)
    guildFundingCB:SetPoint("TOPLEFT", contentFrames.bags, "TOPLEFT", 35, bagsY - 25)
    guildFundingCB:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
    guildFundingCB:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
    guildFundingCB:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
    guildFundingCB:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

    local guildFundingText = guildFundingCB:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    guildFundingText:SetPoint("LEFT", guildFundingCB, "RIGHT", 5, 0)
    guildFundingText:SetText("Guild Money")
    guildFundingText:SetTextColor(1, 1, 1)
    guildFundingText:EnableMouse(true)
    guildFundingText:SetScript("OnMouseDown", function() guildFundingCB:Click() end)

    local playerFundingCB = CreateFrame("CheckButton", addonName .. "AutoRepairPlayerFunding", contentFrames.bags)
    playerFundingCB:SetSize(20, 20)
    playerFundingCB:SetPoint("TOPLEFT", contentFrames.bags, "TOPLEFT", 35, bagsY - 50)
    playerFundingCB:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
    playerFundingCB:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
    playerFundingCB:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
    playerFundingCB:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

    local playerFundingText = playerFundingCB:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    playerFundingText:SetPoint("LEFT", playerFundingCB, "RIGHT", 5, 0)
    playerFundingText:SetText("Own Money")
    playerFundingText:SetTextColor(1, 1, 1)
    playerFundingText:EnableMouse(true)
    playerFundingText:SetScript("OnMouseDown", function() playerFundingCB:Click() end)

    local function RefreshRepairFundingChecks()
        local source = MattSimpleTweaksDB.autoRepairFundingSource or "GUILD"
        guildFundingCB:SetChecked(source == "GUILD")
        playerFundingCB:SetChecked(source == "PLAYER")
    end

    guildFundingCB:SetScript("OnClick", function()
        MattSimpleTweaksDB.autoRepairFundingSource = "GUILD"
        RefreshRepairFundingChecks()
    end)

    playerFundingCB:SetScript("OnClick", function()
        MattSimpleTweaksDB.autoRepairFundingSource = "PLAYER"
        RefreshRepairFundingChecks()
    end)

    RefreshRepairFundingChecks()

    CreateCheckbox(contentFrames.bags, "Auto Sell Junk - Sell poor quality items at vendor", "enableAutoSellJunk", bagsY - 85)

    AddOptions(contentFrames.quests, {
        {text = "Auto Accept Quests - Automatically accept quest offers from NPCs", key = "enableAutoAcceptQuests"},
        {text = "Auto Turn In Quests - Automatically complete/turn-in finished quests", key = "enableAutoTurnInQuests"},
    })

    -- System (Edit Mode Device Manager) 
    local edmCheckbox, edmCheckboxY = CreateCheckbox(contentFrames.editmode, "Enable Edit Mode Device Manager - Auto-apply Edit Mode layout on login", "enableEditModeDeviceManager", -10)
    
    local edmDesc = contentFrames.editmode:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    edmDesc:SetPoint("TOPLEFT", contentFrames.editmode, "TOPLEFT", 20, edmCheckboxY - 5)
    edmDesc:SetWidth(400)
    edmDesc:SetJustifyH("LEFT")
    edmDesc:SetText("Automatically sets your preferred Edit Mode WoW layout for each device you play on")
    edmDesc:SetTextColor(0.5, 0.5, 0.5)

    local edmButton = CreateFrame("Button", nil, contentFrames.editmode, "UIPanelButtonTemplate")
    edmButton:SetSize(200, 25)
    edmButton:SetPoint("TOPLEFT", edmDesc, "BOTTOMLEFT", 0, -10)
    edmButton:GetFontString():SetTextColor(1, 1, 1)
    edmButton:SetText("Edit Mode Device Manager")
    edmButton.Left:SetVertexColor(0.565, 0.894, 0.757)
    edmButton.Middle:SetVertexColor(0.565, 0.894, 0.757)
    edmButton.Right:SetVertexColor(0.565, 0.894, 0.757)
    edmButton:SetScript("OnClick", function()
        if EditModeDeviceManagerFrameOptions then
            optionsFrame:Hide()
            EditModeDeviceManagerFrameOptions:Show()
            EditModeDeviceManagerFrameOptions.mainPanel = optionsFrame
        else
            print(addonName .. ": Edit Mode Device Manager is not loaded.")
        end
    end)
    
    -- Show/hide button based on checkbox state
    local function UpdateEDMButtonVisibility()
        if MattSimpleTweaksDB.enableEditModeDeviceManager then
            edmButton:Show()
            edmDesc:Show()
        else
            edmButton:Hide()
            edmDesc:Hide()
        end
    end
    UpdateEDMButtonVisibility()
    
    -- Hook the checkbox to update button visibility
    edmCheckbox:HookScript("OnClick", function()
        UpdateEDMButtonVisibility()
    end)

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

-- Create a LibDBIcon minimap launcher and a Blizzard Interface Options entry
local function SetupLauncher()
    if not MattSimpleTweaksDB then return end
    MattSimpleTweaksDB.minimap = MattSimpleTweaksDB.minimap or {}

    local LDBI = LibStub and LibStub("LibDBIcon-1.0", true)
    local iconPath = "Interface\\AddOns\\MattSimpleTweaks\\Media\\Icons\\ST.png"

    local iconData = {
        icon = iconPath,
        OnClick = function(self, button)
            if button == "LeftButton" then
                if MattSimpleTweaksOptionsFrame and MattSimpleTweaksOptionsFrame:IsShown() then
                    MattSimpleTweaksOptionsFrame:Hide()
                else
                    MattSimpleTweaksOptionsFrame:Show()
                end
            elseif button == "RightButton" then
                if InterfaceOptionsFrame_OpenToCategory then
                    InterfaceOptionsFrame_OpenToCategory(MattSimpleTweaksInterfaceOptions)
                end
            end
        end,
        OnTooltipShow = function(tt)
            tt:AddLine("Matt's Simple Tweaks")
            tt:AddLine("Left-click: Toggle settings", 1, 1, 1)
        end,
    }

    if LDBI then
        LDBI:Register(addonName, iconData, MattSimpleTweaksDB.minimap)
    end

    -- Create a Blizzard Interface Options category that opens our settings
    if not _G.MattSimpleTweaksInterfaceOptions then
        local panel = CreateFrame("Frame", "MattSimpleTweaksInterfaceOptions", UIParent)
        panel.name = "MattSimpleTweaks"
        panel.okay = function() end
        panel.refresh = function()
            if MattSimpleTweaksOptionsFrame and MattSimpleTweaksOptionsFrame:IsShown() then
                MattSimpleTweaksOptionsFrame:Hide()
            end
            MattSimpleTweaksOptionsFrame:Show()
        end

        -- add a small icon to the top-left of the panel
        local tex = panel:CreateTexture(nil, "ARTWORK")
        tex:SetSize(32, 32)
        tex:SetPoint("TOPLEFT", 16, -16)
        tex:SetTexture(iconPath)

        if InterfaceOptions_AddCategory then
            InterfaceOptions_AddCategory(panel)
        else
            -- Blizzard Interface Options may not be loaded yet; wait for it
            frame:RegisterEvent("ADDON_LOADED")
            frame:HookScript("OnEvent", function(self, event, arg1)
                if event == "ADDON_LOADED" and arg1 == "Blizzard_InterfaceOptions" then
                    if InterfaceOptions_AddCategory then
                        InterfaceOptions_AddCategory(panel)
                    end
                    frame:UnregisterEvent("ADDON_LOADED")
                end
            end)
        end
    end
end

-- Ensure launcher is setup after variables and UI are created
frame:RegisterEvent("PLAYER_LOGIN")
frame:HookScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        SetupLauncher()
        frame:UnregisterEvent("PLAYER_LOGIN")
    end
end)

function addonTable:SetupABGrowth()
end
