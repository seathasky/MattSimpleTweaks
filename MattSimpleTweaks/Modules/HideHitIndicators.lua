-- Modules/HideHitIndicators.lua
local addonName, addonTable = ...

function addonTable:SetupHideHitIndicators()
    -- Hide hit indicators
    if PlayerFrame and PlayerFrame.PlayerFrameContent and PlayerFrame.PlayerFrameContent.PlayerFrameContentMain and PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator then
        PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator:Hide()
        hooksecurefunc(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator, "Show", function(self) self:Hide() end) -- Ensure it stays hidden
    end
    if PetHitIndicator then
        hooksecurefunc(PetHitIndicator, "Show", PetHitIndicator.Hide)
        PetHitIndicator:Hide() -- Hide initially too
    end
end