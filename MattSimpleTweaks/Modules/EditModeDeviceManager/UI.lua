local addonName, ns = ...

function ns.ToggleUI()
    EditModeDeviceManagerFrameOptions:SetShown(not EditModeDeviceManagerFrameOptions:IsShown())
end

local function UpdateLayoutDisplay()
    local layouts = EditModeManagerFrame:GetLayouts()
    local current = MattSimpleTweaksDB.editMode.presetIndexOnLogin
    if current and current > 0 and layouts and layouts[current] then
        EditModeDeviceManagerFrameOptionsCurrentLayout:SetText("Current Layout: " .. layouts[current].layoutName)
    else
        EditModeDeviceManagerFrameOptionsCurrentLayout:SetText("Current Layout: None")
    end
end

function EditModeDeviceManagerLayoutDropdown_OnLoad(self)
    UIDropDownMenu_Initialize(self, function(frame, level)
        local layouts = EditModeManagerFrame:GetLayouts()
        if not layouts then return end
        
        for i, l in ipairs(layouts) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = l.layoutName
            info.value = i
            info.func = function()
                MattSimpleTweaksDB.editMode.presetIndexOnLogin = i
                EditModeManagerFrame:SelectLayout(i)
                UIDropDownMenu_SetSelectedValue(self, i)
                UIDropDownMenu_SetText(self, l.layoutName)
                EditModeDeviceManagerFrameOptionsStatusText:SetText("Current Layout: " .. l.layoutName)
                ns.Print("Layout set: " .. l.layoutName)
            end
            info.checked = (MattSimpleTweaksDB.editMode.presetIndexOnLogin == i)
            UIDropDownMenu_AddButton(info)
        end
        
        UpdateLayoutDisplay()
    end)
    -- Set initial text
    local current = MattSimpleTweaksDB.editMode.presetIndexOnLogin
    if current and current > 0 and layouts and layouts[current] then
        EditModeDeviceManagerFrameOptionsStatusText:SetText("Current Layout: " .. layouts[current].layoutName)
    end
    UIDropDownMenu_SetWidth(self, 180)
    UIDropDownMenu_JustifyText(self, "LEFT")
end

