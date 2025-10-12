local addonName, addonTable = ...

function addonTable:SetupObjectiveFrameScale()
    if ObjectiveTrackerFrame then
        ObjectiveTrackerFrame:SetScale(0.7)
    end
end