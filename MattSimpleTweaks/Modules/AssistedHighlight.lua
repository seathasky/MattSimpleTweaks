local addonName, addonTable = ...

-- Hook the assisted combat highlight system
local function EnhanceAssistedHighlights()
    -- Hook the function that shows/hides the highlight frames
    local originalSetShown = AssistedCombatManager.SetAssistedHighlightFrameShown
    AssistedCombatManager.SetAssistedHighlightFrameShown = function(self, actionButton, shown)
        -- Add old-style spell alert glow
        if LibStub and LibStub("LibCustomGlow-1.0", true) then
            local LibCustomGlow = LibStub("LibCustomGlow-1.0")
            
            if shown then
                -- Don't call original function - we replace it entirely
                -- Add the classic spell alert glow (bright yellow pulsing)
                LibCustomGlow.ButtonGlow_Start(actionButton, {1, 1, 0, 1}, 0.5, 2, 8, 2)
            else
                -- Stop the glow when hiding
                LibCustomGlow.ButtonGlow_Stop(actionButton)
            end
        else
            -- Fallback to original if LibCustomGlow isn't available
            originalSetShown(self, actionButton, shown)
        end
    end
end

function addonTable:SetupAssistedHighlight()
    if MattSimpleTweaksDB and MattSimpleTweaksDB.enableAssistedHighlight then
        EnhanceAssistedHighlights()
    end
end