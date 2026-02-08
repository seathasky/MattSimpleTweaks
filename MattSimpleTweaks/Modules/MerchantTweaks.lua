local addonName, addonTable = ...

local merchantFrame

local function FormatMoney(amount)
    if amount and amount > 0 and GetCoinTextureString then
        return GetCoinTextureString(amount)
    end
    return "0"
end

local function TryAutoRepair()
    if not MattSimpleTweaksDB or not MattSimpleTweaksDB.enableAutoRepair then
        return
    end

    if not CanMerchantRepair or not CanMerchantRepair() then
        return
    end

    local repairCost, canRepair = GetRepairAllCost()
    if not canRepair or not repairCost or repairCost <= 0 then
        return
    end

    local fundingSource = MattSimpleTweaksDB.autoRepairFundingSource or "GUILD"

    if fundingSource == "GUILD" then
        if IsInGuild and IsInGuild() and CanGuildBankRepair and CanGuildBankRepair() then
            local guildMoney = GetGuildBankMoney and GetGuildBankMoney() or 0
            local withdrawLimit = GetGuildBankWithdrawMoney and GetGuildBankWithdrawMoney() or 0

            if withdrawLimit == -1 then
                withdrawLimit = guildMoney
            end

            local usableGuildMoney = math.min(guildMoney or 0, withdrawLimit or 0)
            if usableGuildMoney >= repairCost then
                RepairAllItems(true)
                print(addonName .. ": Repaired all items using guild funds (" .. FormatMoney(repairCost) .. ").")
                return
            end
        end
    end

    local playerMoney = GetMoney and GetMoney() or 0
    if playerMoney >= repairCost then
        RepairAllItems(false)
        print(addonName .. ": Repaired all items (" .. FormatMoney(repairCost) .. ").")
    else
        print(addonName .. ": Not enough gold to repair (need " .. FormatMoney(repairCost) .. ").")
    end
end

local function TryAutoSellJunk()
    if not MattSimpleTweaksDB or not MattSimpleTweaksDB.enableAutoSellJunk then
        return
    end

    if not C_Container or not C_Container.GetContainerNumSlots or not C_Container.GetContainerItemInfo then
        return
    end

    local totalValue = 0
    local soldCount = 0
    local maxBag = NUM_TOTAL_EQUIPPED_BAG_SLOTS or 4

    for bag = 0, maxBag do
        local numSlots = C_Container.GetContainerNumSlots(bag)
        for slot = numSlots, 1, -1 do
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
            if itemInfo and itemInfo.quality == Enum.ItemQuality.Poor and not itemInfo.isLocked then
                local _, _, _, _, _, _, _, _, _, _, sellPrice = C_Item.GetItemInfo(itemInfo.hyperlink)
                if sellPrice and sellPrice > 0 then
                    local stackCount = itemInfo.stackCount or 1
                    totalValue = totalValue + (sellPrice * stackCount)
                    soldCount = soldCount + 1
                    C_Container.UseContainerItem(bag, slot)
                end
            end
        end
    end

    if soldCount > 0 then
        print(addonName .. ": Sold " .. soldCount .. " junk item(s) for " .. FormatMoney(totalValue) .. ".")
    end
end

function addonTable:SetupMerchantTweaks()
    if merchantFrame then
        merchantFrame:Show()
        return
    end

    merchantFrame = CreateFrame("Frame")
    merchantFrame:RegisterEvent("MERCHANT_SHOW")
    merchantFrame:SetScript("OnEvent", function()
        TryAutoRepair()
        TryAutoSellJunk()
    end)
end
