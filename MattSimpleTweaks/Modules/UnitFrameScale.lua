local _, addonTable = ...

local function ApplyScale(frame, scale)
    if not frame then return end
    if frame.SetScale then
        frame:SetScale(scale)
    end
end

local scaleFrame = CreateFrame("Frame")
scaleFrame:RegisterEvent("PLAYER_LOGIN")
scaleFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
scaleFrame:SetScript("OnEvent", function(self, event)
    if PlayerFrame and MattSimpleTweaksDB.enablePlayerFrameScale then
        ApplyScale(PlayerFrame, 0.7)
    end
    
    if TargetFrame and MattSimpleTweaksDB.enableTargetFrameScale then
        ApplyScale(TargetFrame, 0.7)
    end
end)

function addonTable:SetupUnitFrameScale()
    -- Force immediate update
    if PlayerFrame and MattSimpleTweaksDB.enablePlayerFrameScale then
        ApplyScale(PlayerFrame, 0.7)
    end
    
    if TargetFrame and MattSimpleTweaksDB.enableTargetFrameScale then
        ApplyScale(TargetFrame, 0.7)
    end
end
