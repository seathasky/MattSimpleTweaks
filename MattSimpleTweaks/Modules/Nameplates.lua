local addonName, addonTable = ...
local LibCustomGlow = LibStub("LibCustomGlow-1.0")

-- Table of interrupt spells by class ID
local interruptSpells = {
    [1] = { 6552 },      -- Warrior
    [2] = { 96231 },     -- Paladin
    [3] = { 147362, 187707 }, -- Hunter
    [4] = { 1766 },      -- Rogue
    [5] = { 15487 },     -- Priest
    [6] = { 47528 },     -- Death Knight
    [7] = { 57994 },     -- Shaman
    [8] = { 2139 },      -- Mage
    [9] = { 19647, 115781, 89766 }, -- Warlock
    [10] = { 116705 },   -- Monk
    [11] = { 78675 },    -- Druid
    [12] = { 183752 },   -- Demon Hunter
    [13] = { 351338 },   -- Evoker
}

function addonTable.modules.nameplates:SetupNameplateCastbarScale()
    local function GetInterruptColor(unit)
        -- Basic checks
        if not unit then return "gray" end

        -- Check cast state
        local spellName, _, _, _, _, _, _, notInterruptible = UnitCastingInfo(unit)
        if not spellName then
            spellName, _, _, _, _, _, _, notInterruptible = UnitChannelInfo(unit)
        end

        if not spellName then return nil end -- No cast happening

        -- Simple color logic - only yellow or gray
        if notInterruptible then
            return "gray" -- Cast is not interruptible
        else
            return "yellow" -- Cast IS interruptible
        end
    end

    local function ModifyCastBar(castBar, unit)
        if not castBar or not unit then return end

        castBar:SetHeight(16)
        castBar:SetWidth(200)

        local color = GetInterruptColor(unit)

        if color == "yellow" then
            castBar:SetStatusBarColor(1, 0.85, 0)
            if not castBar.hasPixelGlow then
                LibCustomGlow.PixelGlow_Start(castBar, {1, 0.85, 0, 1}, 8, 0.25, 8, 2, 2, 2, false)
                castBar.hasPixelGlow = true
            end
        else -- "gray" or nil
            castBar:SetStatusBarColor(0.7, 0.7, 0.7)
            if castBar.hasPixelGlow then
                LibCustomGlow.PixelGlow_Stop(castBar)
                castBar.hasPixelGlow = false
            end
        end

        if castBar.Icon then castBar.Icon:SetSize(16, 16) end
        if castBar.Flash then castBar.Flash:SetSize(16, 16) end
        if castBar.BorderShield then 
            castBar.BorderShield:SetSize(16, 16)
            castBar.BorderShield:SetVertexColor(0.8, 0.8, 0.8)
        end
        if castBar.Text then
            local font, _, flags = castBar.Text:GetFont()
            castBar.Text:SetFont(font, 11, "OUTLINE")
        end
    end

    -- Hook the OnHide to cleanup glow
    local function HookCastBar(castBar)
        if not castBar.glowHooked then
            castBar:HookScript("OnHide", function(self)
                if self.hasPixelGlow then
                    LibCustomGlow.PixelGlow_Stop(self)
                    self.hasPixelGlow = false
                end
            end)
            castBar.glowHooked = true
        end
    end

    -- Simple event-based approach
    local f = CreateFrame("Frame")
    f:RegisterEvent("UNIT_SPELLCAST_START")
    f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    f:RegisterEvent("NAME_PLATE_UNIT_ADDED")

    f:SetScript("OnEvent", function(self, event, unit)
        if event == "NAME_PLATE_UNIT_ADDED" then
            local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
            if nameplate and nameplate.UnitFrame and nameplate.UnitFrame.castBar then
                HookCastBar(nameplate.UnitFrame.castBar)
                ModifyCastBar(nameplate.UnitFrame.castBar, unit)
            end
        elseif unit and unit:match("^nameplate") then
            local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
            if nameplate and nameplate.UnitFrame and nameplate.UnitFrame.castBar then
                ModifyCastBar(nameplate.UnitFrame.castBar, unit)
            end
        end
    end)
end

function addonTable.modules.nameplates:SetupNameplateTargetArrows()
    local function SetupTargetArrows(unitFrame)
        if not unitFrame.targetArrowLeft then
           
            -- Left arrow pointing right toward nameplate
            local leftArrow = unitFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
            leftArrow:SetText('>')
            leftArrow:SetTextColor(1, 1, 1, 1) -- Bright white
            leftArrow:SetShadowColor(0, 0, 0, 1)
            leftArrow:SetShadowOffset(1, -1)
            leftArrow:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
            
            -- Right arrow pointing left toward nameplate
            local rightArrow = unitFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
            rightArrow:SetText('<')
            rightArrow:SetTextColor(1, 1, 1, 1) -- Bright white
            rightArrow:SetShadowColor(0, 0, 0, 1)
            rightArrow:SetShadowOffset(1, -1)
            rightArrow:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")

            unitFrame.targetArrowLeft = leftArrow
            unitFrame.targetArrowRight = rightArrow
        end
    end

    local function UpdateTargetArrows()
        for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
            local unitFrame = namePlate.UnitFrame
            if unitFrame then
                SetupTargetArrows(unitFrame)
                if UnitIsUnit(unitFrame.unit, 'target') then
                    -- Check if this is an elite mob (has elite icon)
                    local classification = UnitClassification(unitFrame.unit)
                    local isElite = classification == "elite" or 
                                   classification == "worldboss" or
                                   classification == "rareelite" or
                                   classification == "rare"
                    
                    -- Clear and reset positions every time
                    unitFrame.targetArrowLeft:ClearAllPoints()
                    unitFrame.targetArrowRight:ClearAllPoints()
                    
                    -- Adjust left arrow position for elites
                    if isElite then
                        unitFrame.targetArrowLeft:SetPoint('RIGHT', unitFrame.healthBar, 'LEFT', -16, 0)  -- Far outside left edge for elites (avoid dragon icon)
                        unitFrame.targetArrowRight:SetPoint('LEFT', unitFrame.healthBar, 'RIGHT', 2, 0)   -- Outside right edge for elites
                    else
                        unitFrame.targetArrowLeft:SetPoint('RIGHT', unitFrame.healthBar, 'LEFT', -1.5, 0)     -- Just outside left edge for regulars (avoid skull/icons)
                        unitFrame.targetArrowRight:SetPoint('LEFT', unitFrame.healthBar, 'RIGHT', 2, 0)    -- Outside right edge for regulars
                    end
                    
                    unitFrame.targetArrowLeft:Show()
                    unitFrame.targetArrowRight:Show()
                else
                    unitFrame.targetArrowLeft:Hide()
                    unitFrame.targetArrowRight:Hide()
                end
            end
        end
    end

    local f = CreateFrame("Frame")
    f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    f:RegisterEvent("PLAYER_TARGET_CHANGED")

    f:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_TARGET_CHANGED" then
            -- Small delay for target changes to help with elite detection
            C_Timer.After(0.05, UpdateTargetArrows)
        else
            UpdateTargetArrows()
        end
    end)
end
