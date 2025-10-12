local addonName, addonTable = ...

function addonTable:SetupStatusBarScale()
    if StatusTrackingBarManager then
        StatusTrackingBarManager:SetScale(0.7)
    end
end
