--[[
Slash command for glow style:
  /mstglow star   - Use animated star glow (default)
  /mstglow pixel  - Use pixel border flash glow
]]
SLASH_MSTGLOW1 = "/mstglow"
SlashCmdList["MSTGLOW"] = function(msg)
    local arg = msg and msg:lower():match("%S+")
    if arg == "star" or arg == "pixel" then
        if MattSimpleTweaks and MattSimpleTweaks.UpdateAssistedQueueGlowStyle then
            MattSimpleTweaks.UpdateAssistedQueueGlowStyle(arg)
            print("|cff00ff98[MST]|r Glow style set to: "..arg)
        end
    else
        print("|cff00ff98[MST]|r Usage: /mstglow star  or  /mstglow pixel")
    end
end
-- Assisted Queue Display (1-3 icons with keybinds and cooldowns)
local addonName, addonTable = ...

local MAX_ICONS = 4
local ICON_SIZE = 48
local ICON_SPACING = 4
local FIRST_ICON_SCALE = 1.4

-- Current active icon count
local activeIconCount = 3

-- Calculate dimensions
local firstIconSize = ICON_SIZE * FIRST_ICON_SCALE
local function CalculateTotalWidth(numIcons)
    if numIcons == 1 then
        return firstIconSize
    else
        return firstIconSize + (numIcons - 1) * (ICON_SIZE + ICON_SPACING)
    end
end
local totalWidth = CalculateTotalWidth(MAX_ICONS)

-- Create main frame
local frame = CreateFrame("Frame", "MST_AssistedQueueDisplay", UIParent)
frame:SetSize(totalWidth, firstIconSize)
frame:SetPoint("CENTER", 0, -150)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
frame:Hide()

-- Add a semi-transparent background so it's easier to grab
local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
bg:SetColorTexture(0, 0, 0, 0.2)

-- Add a border for visibility
local border = frame:CreateTexture(nil, "BORDER")
border:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
border:SetColorTexture(0.3, 0.3, 0.3, 0.4)
border:SetDrawLayer("BORDER", -1)

-- Create title bar (hidden by default, shown on mouseover)
local titleBar = CreateFrame("Frame", nil, frame)
titleBar:SetSize(200, 20)
titleBar:SetPoint("BOTTOM", frame, "TOP", 0, 2)
titleBar:EnableMouse(true)
titleBar:Hide()

local titleBg = titleBar:CreateTexture(nil, "BACKGROUND")
titleBg:SetAllPoints(titleBar)
titleBg:SetColorTexture(0, 0, 0, 0.8)

local titleBorder = titleBar:CreateTexture(nil, "BORDER")
titleBorder:SetAllPoints(titleBar)
titleBorder:SetColorTexture(0.5, 0.5, 0.5, 0.8)

local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
titleText:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
titleText:SetText("MST Visual Spell Queue")
titleText:SetTextColor(1, 0.82, 0, 1)

-- Show/hide title bar on mouseover
frame:SetScript("OnEnter", function(self)
    titleBar:Show()
end)
frame:SetScript("OnLeave", function(self)
    titleBar:Hide()
end)
titleBar:SetScript("OnEnter", function(self)
    titleBar:Show()
end)
titleBar:SetScript("OnLeave", function(self)
    titleBar:Hide()
end)

-- LibCustomGlow integration
local LibCustomGlow = LibStub and LibStub("LibCustomGlow-1.0", true)

local buttons = {}
for i = 1, MAX_ICONS do
    local isFirst = (i == 1)
    local size = isFirst and firstIconSize or ICON_SIZE
    local xPos = (i == 1) and 0 or (firstIconSize + (i - 2) * (ICON_SIZE + ICON_SPACING) + ICON_SPACING)

    local btn = CreateFrame("Button", nil, frame)
    btn:SetSize(size, size)
    btn:SetPoint("LEFT", frame, "LEFT", xPos, 0)
    btn:EnableMouse(false)

    -- Icon texture
    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetAllPoints(btn)
    btn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Cooldown frame
    btn.cooldown = CreateFrame("Cooldown", nil, btn, "CooldownFrameTemplate")
    btn.cooldown:SetAllPoints(btn)
    btn.cooldown:SetDrawEdge(true)
    btn.cooldown:SetDrawSwipe(true)
    btn.cooldown:SetHideCountdownNumbers(false)

    -- Keybind text
    btn.keybind = btn:CreateFontString(nil, "OVERLAY")
    local fontSize = isFirst and 36 or 28
    btn.keybind:SetFont(STANDARD_TEXT_FONT, fontSize, "OUTLINE")
    btn.keybind:SetTextColor(1, 1, 1, 1)
    btn.keybind:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)

        if isFirst then
            -- Star (animated) setup
            btn.focusGlow = btn:CreateTexture(nil, "OVERLAY", nil, 1)
            btn.focusGlow:SetPoint("CENTER", 0, 0)
            btn.focusGlow:SetSize(size + 24, size + 24)
            btn.focusGlow:SetTexture("Interface\\Cooldown\\star4")
            btn.focusGlow:SetBlendMode("ADD")
            btn.focusGlow:SetVertexColor(1, 0.9, 0.5, 0.75)
            btn.focusGlow:Hide()
            local animGroup = btn.focusGlow:CreateAnimationGroup()
            local rotation = animGroup:CreateAnimation("Rotation")
            rotation:SetDegrees(-360)
            rotation:SetDuration(10)
            rotation:SetOrigin("CENTER", 0, 0)
            animGroup:SetLooping("REPEAT")
            btn.focusGlow:SetScript("OnShow", function(self) animGroup:Play() end)
            btn.focusGlow:SetScript("OnHide", function(self) animGroup:Stop() end)

            btn.libGlowActive = false
            btn.ShowLibGlow = function(self)
                local style = (MattSimpleTweaksDB and MattSimpleTweaksDB.visualSpellQueueGlowStyle) or "star"
                if style == "star" then
                    -- Turn off pixel glow
                    if LibCustomGlow and self.libGlowActive then
                        LibCustomGlow.PixelGlow_Stop(self)
                        self.libGlowActive = false
                    end
                    -- Turn on star glow
                    self.focusGlow:Show()
                elseif style == "pixel" then
                    -- Turn off star glow
                    self.focusGlow:Hide()
                    -- Turn on pixel glow
                    if LibCustomGlow and not self.libGlowActive then
                        LibCustomGlow.PixelGlow_Start(self, {1, 0.82, 0, 1}, 8, 0.25, nil, 4, 2, 2, "flash", 1)
                        self.libGlowActive = true
                    end
                end
            end
            btn.HideLibGlow = function(self)
                self.focusGlow:Hide()
                if LibCustomGlow and self.libGlowActive then
                    LibCustomGlow.PixelGlow_Stop(self)
                    self.libGlowActive = false
                end
            end
        end
-- Function to update the glow style at runtime
function addonTable.UpdateAssistedQueueGlowStyle(style)
    if not MattSimpleTweaksDB then return end
    if style ~= "star" and style ~= "pixel" then return end
    MattSimpleTweaksDB.visualSpellQueueGlowStyle = style
    -- Force update display to apply new style
    if buttons[1] and buttons[1].ShowLibGlow then
        buttons[1]:HideLibGlow()
        buttons[1]:ShowLibGlow()
    end
end

    btn:Hide()
    buttons[i] = btn
end

-- Spell info cache for performance
local spellInfoCache = {}
local function GetCachedSpellInfo(spellID)
    if not spellID or spellID == 0 then return nil end
    if not spellInfoCache[spellID] then
        local info = (C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellID)) or nil
        if not info then
            local name, _, icon = GetSpellInfo(spellID)
            if name then info = { name = name, iconID = icon } end
        end
        spellInfoCache[spellID] = info
    end
    return spellInfoCache[spellID]
end

-- Helper function to check if spell is on cooldown
local function IsSpellOnCooldown(spellID)
    local cd = C_Spell and C_Spell.GetSpellCooldown and C_Spell.GetSpellCooldown(spellID)
    if cd and cd.startTime and cd.duration then
        return cd.duration > 1.5 and (cd.startTime + cd.duration - GetTime()) > 0.1
    end
    return false
end

-- Helper function to check if spell is usable (has resources, in range, etc.)
local function IsSpellUsable(spellID)
    -- First check if we actually know the spell
    if not IsSpellKnown(spellID) then
        return false
    end
    
    if C_Spell and C_Spell.IsSpellUsable then
        return C_Spell.IsSpellUsable(spellID)
    else
        -- Fallback for older API
        local usable, noMana = IsUsableSpell(spellID)
        return usable or noMana
    end
end

-- Get spell queue
local function GetSpellQueue()
    local queue = {}
    local seen = {}
    local availableSpells = {}  -- Off cooldown spells
    local onCooldownSpells = {} -- On cooldown spells
    
    -- Get primary spell (always show first if present, even if on cooldown)
    local primarySpellID = C_AssistedCombat and C_AssistedCombat.GetNextCastSpell and C_AssistedCombat.GetNextCastSpell()
    if primarySpellID and primarySpellID > 0 then
        queue[#queue + 1] = primarySpellID
        seen[primarySpellID] = true
    end
    
    -- Get rotation spells and separate by cooldown status
    if activeIconCount > 1 then
        local rotationList = C_AssistedCombat and C_AssistedCombat.GetRotationSpells and C_AssistedCombat.GetRotationSpells()
        if rotationList and type(rotationList) == "table" then
            for i = 1, #rotationList do
                local spellID = rotationList[i]
                if spellID and spellID > 0 and not seen[spellID] then
                    local override = C_Spell and C_Spell.GetOverrideSpell and C_Spell.GetOverrideSpell(spellID) or 0
                    local actualSpellID = (override ~= 0) and override or spellID
                    if not seen[actualSpellID] and IsSpellUsable(actualSpellID) then
                        if IsSpellOnCooldown(actualSpellID) then
                            onCooldownSpells[#onCooldownSpells + 1] = actualSpellID
                        else
                            availableSpells[#availableSpells + 1] = actualSpellID
                        end
                        seen[actualSpellID] = true
                    end
                end
            end
        end
        
        -- Only add available (off cooldown) spells to positions 2, 3, 4
        for _, spellID in ipairs(availableSpells) do
            if #queue < activeIconCount then
                queue[#queue + 1] = spellID
            else
                break
            end
        end
        
        -- Add cooldown spells to positions 2, 3, 4 only if "Hide Cooldown Spells" is disabled
        if not (MattSimpleTweaksDB and MattSimpleTweaksDB.visualSpellQueueHideCooldowns) then
            for _, spellID in ipairs(onCooldownSpells) do
                if #queue < activeIconCount then
                    queue[#queue + 1] = spellID
                else
                    break
                end
            end
        end
    end
    
    -- Paladin: Only show one of Wake of Ashes (255937) or Hammer of Light (427453), prefer Hammer if available
    local isPaladin = select(2, UnitClass("player")) == "PALADIN"
    if isPaladin then
        local idxWake, idxHammer
        for i, spellID in ipairs(queue) do
            if spellID == 255937 then idxWake = i end
            if spellID == 427453 then idxHammer = i end
        end
        if idxWake and idxHammer then
            -- Prefer Hammer of Light if both are present
            table.remove(queue, idxWake)
        elseif idxWake or idxHammer then
            -- If only one is present, check if it's actually available (not on cooldown)
            if idxHammer and IsSpellOnCooldown(427453) and not idxWake then
                -- Hammer is on cooldown, but Wake is not in queue, so try to show Wake if available
                if not IsSpellOnCooldown(255937) then
                    -- Insert Wake at Hammer's position
                    queue[idxHammer] = 255937
                end
            elseif idxWake and IsSpellOnCooldown(255937) and not idxHammer then
                -- Wake is on cooldown, but Hammer is not in queue, so try to show Hammer if available
                if not IsSpellOnCooldown(427453) then
                    queue[idxWake] = 427453
                end
            end
        end
    end
    return queue
end

local lastQueue = {}
local lastUpdate = 0

local function GetUpdateInterval()
    return UnitAffectingCombat("player") and 0.03 or 0.08
end

-- Comprehensive keybind scanner (checks all action bars)
local actionBarBindings = {
    [1] = "ACTIONBUTTON",      -- Main bar
    [13] = "ACTIONBUTTON",     -- Main bar page 2
    [25] = "MULTIACTIONBAR3BUTTON",  -- Right bar
    [37] = "MULTIACTIONBAR4BUTTON",  -- Right bar 2
    [49] = "MULTIACTIONBAR2BUTTON",  -- Bottom right
    [61] = "MULTIACTIONBAR1BUTTON",  -- Bottom left
    [73] = "MULTIACTIONBAR5BUTTON",  -- Bar 6
    [85] = "MULTIACTIONBAR6BUTTON",  -- Bar 7
    [97] = "MULTIACTIONBAR7BUTTON",  -- Bar 8
}

local function GetKeybindForSlot(slot)
    for baseSlot, bindingPrefix in pairs(actionBarBindings) do
        if slot >= baseSlot and slot < baseSlot + 12 then
            local buttonNum = slot - baseSlot + 1
            local binding = bindingPrefix .. buttonNum
            local key = GetBindingKey(binding)
            if key then
                -- Abbreviate modifiers
                key = key:gsub("SHIFT%-", "S"):gsub("CTRL%-", "C"):gsub("ALT%-", "A")
                key = key:gsub("BUTTON", "M"):gsub("MOUSEWHEELUP", "WU"):gsub("MOUSEWHEELDOWN", "WD")
                return key
            end
        end
    end
    return nil
end

local function GetSpellKeybind(spellID)
    if not spellID or spellID == 0 then return nil end
    
    -- Check override spells
    local override = C_Spell and C_Spell.GetOverrideSpell and C_Spell.GetOverrideSpell(spellID) or 0
    local checkIDs = {spellID}
    if override ~= 0 then table.insert(checkIDs, override) end
    
    -- Scan all action slots (1-120 covers main + multi bars)
    for slot = 1, 120 do
        local actionType, id = GetActionInfo(slot)
        if actionType == "spell" then
            for _, checkID in ipairs(checkIDs) do
                if id == checkID then
                    local key = GetKeybindForSlot(slot)
                    if key then return key end
                end
            end
        elseif actionType == "macro" then
            -- Check macro icon spell
            local macroName = GetActionText(slot)
            if macroName then
                local _, _, macroBody = GetMacroInfo(macroName)
                if macroBody then
                    -- Simple check if spell name/ID is in macro
                    local spellInfo = GetCachedSpellInfo(spellID)
                    if spellInfo and spellInfo.name and macroBody:find(spellInfo.name) then
                        local key = GetKeybindForSlot(slot)
                        if key then return key end
                    end
                end
            end
        end
    end
    return nil
end

-- Compare queues
local function QueueChanged(q1, q2)
    if #q1 ~= #q2 then return true end
    for i = 1, #q1 do
        if q1[i] ~= q2[i] then return true end
    end
    return false
end

local function UpdateDisplay(force)
    local queue = GetSpellQueue()
    
    if force or QueueChanged(queue, lastQueue) then
        local anyShown = false
        
        for i = 1, MAX_ICONS do
            local btn = buttons[i]
            local spellID = queue[i]
            
            -- Only show buttons within active icon count
            if i > activeIconCount then
                btn:Hide()
                if i == 1 and btn.HideLibGlow then btn:HideLibGlow() end
            elseif spellID then
                local info = GetCachedSpellInfo(spellID)
                if info and info.iconID then
                    -- Update icon
                    btn.icon:SetTexture(info.iconID)
                    btn.icon:SetAlpha(1) -- Always full alpha now
                    
                    -- Update keybind
                    btn.keybind:SetText(GetSpellKeybind(spellID) or "")
                    
                    -- Update cooldown (GCD for first icon if enabled, spell CD for others)
                    if i == 1 and MattSimpleTweaksDB and MattSimpleTweaksDB.enableVisualSpellQueueGCD then
                        local gcdInfo = C_Spell and C_Spell.GetSpellCooldown and C_Spell.GetSpellCooldown(61304)
                        if gcdInfo and gcdInfo.startTime and gcdInfo.duration and gcdInfo.duration > 0 and gcdInfo.duration < 1.5 then
                            btn.cooldown:SetCooldown(gcdInfo.startTime, gcdInfo.duration)
                            btn.cooldown:Show()
                        else
                            local cdInfo = C_Spell and C_Spell.GetSpellCooldown and C_Spell.GetSpellCooldown(spellID)
                            if cdInfo and cdInfo.startTime and cdInfo.duration and cdInfo.duration > 1.5 then
                                btn.cooldown:SetCooldown(cdInfo.startTime, cdInfo.duration)
                                btn.cooldown:Show()
                            else
                                btn.cooldown:Hide()
                            end
                        end
                        if i == 1 and btn.ShowLibGlow then btn:ShowLibGlow() end
                    else
                        local cdInfo = C_Spell and C_Spell.GetSpellCooldown and C_Spell.GetSpellCooldown(spellID)
                        if cdInfo and cdInfo.startTime and cdInfo.duration and cdInfo.duration > 1.5 then
                            btn.cooldown:SetCooldown(cdInfo.startTime, cdInfo.duration)
                            btn.cooldown:Show()
                        else
                            btn.cooldown:Hide()
                        end
                        if i == 1 and btn.ShowLibGlow then btn:ShowLibGlow() end
                    end
                    
                    btn:Show()
                    anyShown = true
                end
            else
                btn:Hide()
                if i == 1 and btn.HideLibGlow then btn:HideLibGlow() end
            end
        end
        
        if anyShown then
            frame:Show()
        else
            frame:Hide()
        end
        
        lastQueue = queue
    end
end


-- Register all relevant events for instant updates
local events = {
    "PLAYER_ENTERING_WORLD",
    "PLAYER_TARGET_CHANGED",
    "UNIT_SPELLCAST_SUCCEEDED",
    "PLAYER_REGEN_ENABLED",
    "PLAYER_REGEN_DISABLED",
    "ACTIONBAR_SLOT_CHANGED",
    "SPELL_UPDATE_COOLDOWN",
    "UPDATE_BINDINGS",
}
for _, event in ipairs(events) do
    frame:RegisterEvent(event)
end

local onEventHandler = function(self, event, ...)
    if not addonTable.AssistedQueueDisplayEnabled then return end
    UpdateDisplay(true)
    lastUpdate = 0
end

local onUpdateHandler = function(self, elapsed)
    -- Handle spell queue updates
    if not addonTable.AssistedQueueDisplayEnabled then return end
    lastUpdate = lastUpdate + elapsed
    local interval = GetUpdateInterval()
    if lastUpdate >= interval then
        UpdateDisplay(false)
        lastUpdate = 0
    end
end

frame:SetScript("OnEvent", onEventHandler)
frame:SetScript("OnUpdate", onUpdateHandler)

addonTable.AssistedQueueDisplayEnabled = false
function addonTable.ToggleAssistedQueueDisplay(enable)
    addonTable.AssistedQueueDisplayEnabled = enable
    if enable then
        -- Set icon count, scale, and glow style from saved variables
        activeIconCount = (MattSimpleTweaksDB and MattSimpleTweaksDB.visualSpellQueueIcons) or 3
        local scale = (MattSimpleTweaksDB and MattSimpleTweaksDB.visualSpellQueueScale) or 1.0
        if MattSimpleTweaksDB and not MattSimpleTweaksDB.visualSpellQueueGlowStyle then
            MattSimpleTweaksDB.visualSpellQueueGlowStyle = "star" -- default
        end
        frame:SetScale(scale)
        frame:SetSize(CalculateTotalWidth(activeIconCount), firstIconSize)
        UpdateDisplay(true)
        frame:Show()
    else
        frame:Hide()
    end
end

-- Function to update icon count on the fly
function addonTable.UpdateAssistedQueueIconCount(count)
    if count < 1 or count > MAX_ICONS then return end
    activeIconCount = count
    frame:SetSize(CalculateTotalWidth(count), firstIconSize)
    UpdateDisplay(true)
end

-- Function to update scale on the fly
function addonTable.UpdateAssistedQueueScale(scale)
    if scale < 0.5 or scale > 2.0 then return end
    frame:SetScale(scale)
end
