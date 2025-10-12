-- Modules/HideMicroMenu.lua
local addonName, addonTable = ...

function addonTable:SetupHideMicroMenu()
    -- Hide Micro Menu Buttons
    local buttonsToHide = {
        "CharacterMicroButton", "PlayerSpellsMicroButton", "ProfessionMicroButton",
        "AchievementMicroButton", "QuestLogMicroButton", "GuildMicroButton",
        "LFDMicroButton", "CollectionsMicroButton", "EJMicroButton",
        "MainMenuMicroButton", "QuickJoinToastButton", "StoreMicroButton"
    }
    for _, buttonName in ipairs(buttonsToHide) do
        local button = _G[buttonName]
        if button then
            button:Hide()
            if buttonName == "StoreMicroButton" then
                 hooksecurefunc(button, "Show", function(self) self:Hide() end)
            end
        end
    end
end

-- Function to inform user that disabling requires reload
function addonTable:DisableHideMicroMenu()
    print(addonName .. ": Disabling Micro Menu hiding requires a UI reload (/rl).")
end