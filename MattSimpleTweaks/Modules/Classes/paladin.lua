local addonName, addonTable = ...

local module = {}

function module:SetupHideHolyPowerBar()
    if _G.PaladinPowerBarFrame then
        _G.PaladinPowerBarFrame:Hide()
        _G.PaladinPowerBarFrame:HookScript("OnShow", function(self)
            if MattSimpleTweaksDB.hideHolyPowerBar then
                self:Hide()
            end
        end)
    end
end

addonTable.modules.paladin = module
