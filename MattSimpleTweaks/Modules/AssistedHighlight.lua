local addonName, addonTable = ...

-- Enhanced assisted combat highlight system

local function EnhanceAssistedHighlights()
    AssistedCombatManager.SetAssistedHighlightFrameShown = function(self, actionButton, shown)
        if LibStub and LibStub("LibCustomGlow-1.0", true) then
            local LibCustomGlow = LibStub("LibCustomGlow-1.0")
            if shown then
                LibCustomGlow.ProcGlow_Start(actionButton, {
                    color = {1, 1, 0, 1},
                    startAnim = false, -- No animation, just steady
                    duration = 3600,   -- Long duration, will be stopped manually
                    frameLevel = 8
                })
            else
                LibCustomGlow.ProcGlow_Stop(actionButton)
            end
        end
    end

    addonTable.CleanupAssistedHighlightGlows = function() end
end

function addonTable:SetupAssistedHighlight()
    if MattSimpleTweaksDB and MattSimpleTweaksDB.enableAssistedHighlight then
        EnhanceAssistedHighlights()
    end
end

function addonTable:DisableAssistedHighlight()
    if self.CleanupAssistedHighlightGlows then
        self.CleanupAssistedHighlightGlows()
    end
end