local addonName, ns = ...
ns = ns or {}

function ns.Print(...)
    print("|cffFFC700" .. addonName .. "|r:", ...)
end

local currentVersion = "2"
local frame = CreateFrame("Frame")
local layouts = nil

frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED") -- Add this new event

local function ApplyLayout()
    layouts = EditModeManagerFrame:GetLayouts()
    if not layouts then 
        C_Timer.After(0.5, ApplyLayout) -- Retry if layouts aren't available
        return 
    end
    
    local desired = MattSimpleTweaksDB.editMode.presetIndexOnLogin
    if desired and desired > 0 and desired <= #layouts then
        -- Force the layout selection even if it's already "selected"
        EditModeManagerFrame:SelectLayout(desired, true)
        
        -- Update both status text and dropdown
        if EditModeDeviceManagerFrameOptionsStatusText then
            EditModeDeviceManagerFrameOptionsStatusText:SetText("Current Layout: " .. layouts[desired].layoutName)
            -- Set dropdown selection
            UIDropDownMenu_SetSelectedValue(EditModeDeviceManagerLayoutDropdown, desired)
            UIDropDownMenu_SetText(EditModeDeviceManagerLayoutDropdown, layouts[desired].layoutName)
        end
    end
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "VARIABLES_LOADED" then
        -- Ensure editMode table exists
        if not MattSimpleTweaksDB.editMode then
            MattSimpleTweaksDB.editMode = {
                presetIndexOnLogin = 1,
                lastVersionLoaded = currentVersion
            }
        end
        C_Timer.After(1, ApplyLayout)
    elseif event == "EDIT_MODE_LAYOUTS_UPDATED" then
        C_Timer.After(0.2, ApplyLayout)
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        -- Reapply layout when spec changes
        C_Timer.After(0.5, ApplyLayout)
    end
end)

SLASH_EDITMODEDEVICEMANAGER1 = "/edm"
function SlashCmdList.EDITMODEDEVICEMANAGER(msg)
    EditModeDeviceManagerFrameOptions:SetShown(not EditModeDeviceManagerFrameOptions:IsShown())
end
