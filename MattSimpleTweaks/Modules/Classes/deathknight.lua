local addonName, addonTable = ...

-- Initialize modules table if it doesn't exist
addonTable.modules = addonTable.modules or {}

-- Create the module table with a metatable for proper method calls
local module = setmetatable({}, {
    __index = {}
})

function module:SetupHideRuneFrame()
    if _G.RuneFrame then
        _G.RuneFrame:Hide()
        _G.RuneFrame:HookScript("OnShow", function(self)
            if MattSimpleTweaksDB.hideRuneFrame then
                self:Hide()
            end
        end)
    end
end

-- Assign the module
addonTable.modules.deathknight = module
