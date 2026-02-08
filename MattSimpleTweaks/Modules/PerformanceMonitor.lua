-- Modules/PerformanceMonitor.lua
local addonName, addonTable = ...
local db -- Reference to saved variables
local perfFrame = nil -- Will be created when needed

-- Save the current position to the database
local function SavePosition()
    if perfFrame and db then
        local point, relativeTo, relativePoint, xOfs, yOfs = perfFrame:GetPoint()
        local relativeToName = "UIParent"
        if relativeTo and relativeTo.GetName and relativeTo:GetName() then
            relativeToName = relativeTo:GetName()
        end
        db.perfMonitorPos = { 
            point = point, 
            relativeTo = relativeToName, 
            relativePoint = relativePoint, 
            xOfs = xOfs, 
            yOfs = yOfs 
        }
    end
end

local function CreatePerformanceFrame()
    if perfFrame then return perfFrame end
    
    perfFrame = CreateFrame("Frame", "MST_PerformanceFrame", UIParent, "BackdropTemplate")
    perfFrame:SetSize(110, 22)
    perfFrame:SetClampedToScreen(true)
    perfFrame:SetMovable(true)
    perfFrame:EnableMouse(true)
    perfFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    perfFrame:SetFrameLevel(100)
    perfFrame:SetToplevel(true)

    perfFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        tile = true, tileSize = 16, edgeSize = 0,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    perfFrame:SetBackdropColor(0, 0, 0, 0.5)

    local text = perfFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    text:SetPoint("CENTER")
    text:SetJustifyH("CENTER")
    text:SetTextColor(1, 1, 1)
    perfFrame.text = text

    local updateInterval = 1
    local timeSinceLastUpdate = 0

    perfFrame:SetScript("OnUpdate", function(self, elapsed)
        timeSinceLastUpdate = timeSinceLastUpdate + elapsed
        if timeSinceLastUpdate >= updateInterval then
            local currentFps = math.floor(GetFramerate())
            local homeLatency, worldLatency = select(3, GetNetStats())
            local latency = math.max(homeLatency or 0, worldLatency or 0)
            text:SetFormattedText("%d FPS %dms", currentFps, latency)
            timeSinceLastUpdate = 0
        end
    end)

    perfFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and IsShiftKeyDown() then
            self:StartMoving()
            self.isMoving = true
        end
    end)

    perfFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.isMoving then 
            self:StopMovingOrSizing()
            self.isMoving = false
            SavePosition()
        end
    end)

    -- Register for logout to save position
    perfFrame:RegisterEvent("PLAYER_LOGOUT")
    perfFrame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_LOGOUT" then
            SavePosition()
        end
    end)

    perfFrame:SetScript("OnShow", function(self) self:SetFrameLevel(100) end)

    return perfFrame
end

function addonTable:SetupPerformanceMonitor()
    if not MattSimpleTweaksDB.enablePerformanceMonitor then return end
    
    db = MattSimpleTweaksDB
    local frame = CreatePerformanceFrame()
    
    local pos = db.perfMonitorPos
    frame:ClearAllPoints()
    if pos and _G[pos.relativeTo] then
        frame:SetPoint(pos.point, _G[pos.relativeTo], pos.relativePoint, pos.xOfs, pos.yOfs)
    else
        frame:SetPoint("TOP", UIParent, "TOP", 0, -100)
    end
    
    frame:Show()
end

function addonTable:DisablePerformanceMonitor()
    if perfFrame then
        -- Save position before disabling
        SavePosition()
        perfFrame:Hide()
        perfFrame:SetScript("OnUpdate", nil)
        perfFrame:UnregisterAllEvents()
        perfFrame:SetParent(nil)
        _G.MST_PerformanceFrame = nil
        perfFrame = nil
    end
end