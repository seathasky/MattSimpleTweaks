-- Modules/SlashCommands.lua
local addonName, addonTable = ...

local function UnregisterSlashCommand(command)
    if _G["SLASH_" .. command .. "1"] then
        _G["SLASH_" .. command .. "1"] = nil
        SlashCmdList[command] = nil
        hash_SlashCmdList[("/%s"):format(command:lower())] = nil
    end
end

function addonTable:SetupSlashCommands()
    UnregisterSlashCommand("QUICKBIND")
    UnregisterSlashCommand("RELOADUI")
    UnregisterSlashCommand("EDITMODE")
    UnregisterSlashCommand("PULLCOUNTDOWN")

    if MattSimpleTweaksDB.enableQuickBind then
        SLASH_QUICKBIND1 = '/kb'
        SlashCmdList["QUICKBIND"] = function()
            if not C_AddOns.IsAddOnLoaded("Blizzard_BindingUI") then
                C_AddOns.LoadAddOn("Blizzard_BindingUI")
            end
            if QuickKeybindFrame then
                QuickKeybindFrame:Show()
            end
        end
    end

    if MattSimpleTweaksDB.enableReloadAlias then
        SLASH_RELOADUI1 = '/rl'
        SlashCmdList["RELOADUI"] = function() ReloadUI() end
    end

    if MattSimpleTweaksDB.enableEditModeAlias then
        SLASH_EDITMODE1 = '/edit'
        SlashCmdList["EDITMODE"] = function()
            if EditModeManagerFrame then
                EditModeManagerFrame:Show()
            end
        end
    end

    if MattSimpleTweaksDB.enablePullAlias then
        SLASH_PULLCOUNTDOWN1 = '/pull'
        SlashCmdList["PULLCOUNTDOWN"] = function(msg)
            local seconds = tonumber((msg or ""):match("^(%d+)"))
            if not seconds then
                seconds = 10
            end

            seconds = math.floor(seconds)
            if seconds < 1 or seconds > 60 then
                print(addonName .. ": /pull value must be between 1 and 60.")
                return
            end

            if C_PartyInfo and C_PartyInfo.DoCountdown then
                C_PartyInfo.DoCountdown(seconds)
            else
                print(addonName .. ": Countdown API not available.")
            end
        end
    end
end
