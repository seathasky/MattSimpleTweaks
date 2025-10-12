-- Modules/HideBagBar.lua
local addonName, addonTable = ...

function addonTable:SetupHideBagBar()
    -- Hide main elements
    MainMenuBarBackpackButton:Hide()
    BagBarExpandToggle:Hide()
    CharacterReagentBag0Slot:Hide()

    -- Hide individual bag slots
    CharacterBag0Slot:Hide()
    CharacterBag1Slot:Hide()
    CharacterBag2Slot:Hide()
    CharacterBag3Slot:Hide()

    -- Ensure slots stay hidden if shown
    CharacterBag0Slot:SetScript("OnShow", CharacterBag0Slot.Hide)
    CharacterBag1Slot:SetScript("OnShow", CharacterBag1Slot.Hide)
    CharacterBag2Slot:SetScript("OnShow", CharacterBag2Slot.Hide)
    CharacterBag3Slot:SetScript("OnShow", CharacterBag3Slot.Hide)

    -- Also hook the main backpack button and reagent bag just in case
    MainMenuBarBackpackButton:SetScript("OnShow", MainMenuBarBackpackButton.Hide)
    CharacterReagentBag0Slot:SetScript("OnShow", CharacterReagentBag0Slot.Hide)
end

-- Function to inform user that disabling requires reload
function addonTable:DisableHideBagBar()
    print(addonName .. ": Disabling Bag Bar hiding requires a UI reload (/rl) to restore elements.")
    -- Note: A simple disable function cannot reliably un-hook and show elements
    -- hidden this way without causing potential taint or errors. Reload is safest.
end