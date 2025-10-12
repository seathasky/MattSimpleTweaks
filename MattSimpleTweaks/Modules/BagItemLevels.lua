local AddonName, addonTable = ... -- Renamed Private to addonTable for clarity

-- Lua API
local _G = _G
local ipairs = ipairs
local string_find = string.find
local string_gsub = string.gsub
local string_match = string.match
local tonumber = tonumber

-- WoW API
local CreateFrame = CreateFrame
local GetContainerItemInfo = GetContainerItemInfo
local GetDetailedItemLevelInfo = GetDetailedItemLevelInfo
local GetItemInfo = C_Item and C_Item.GetItemInfo or GetItemInfo
local hooksecurefunc = hooksecurefunc
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES
local NUM_BANKGENERIC_SLOTS = NUM_BANKGENERIC_SLOTS
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local NUM_BANKBAGSLOTS = NUM_BANKBAGSLOTS

-- WoW10 API
local C_Container_GetContainerItemInfo = C_Container and C_Container.GetContainerItemInfo
local C_TooltipInfo = C_TooltipInfo

-- Tooltip used for scanning.
local _SCANNER = "GP_ScannerTooltip"
local Scanner = _G[_SCANNER] or CreateFrame("GameTooltip", _SCANNER, WorldFrame, "GameTooltipTemplate")

-- Tooltip and scanning patterns
local S_ILVL = "^" .. string_gsub(ITEM_LEVEL, "%%d", "(%%d+)")
local S_SLOTS = "^" .. (string_gsub(string_gsub(CONTAINER_SLOTS, "%%([%d%$]-)d", "(%%d+)"), "%%([%d%$]-)s", "%.+"))

-- Cache of information objects
local Cache = GP_ItemButtonInfoFrameCache or {}
GP_ItemButtonInfoFrameCache = Cache

-- Quality/Rarity colors
local colors = {
	[0] = { 157/255, 157/255, 157/255 }, -- Poor
	[1] = { 240/255, 240/255, 240/255 }, -- Common
	[2] = { 30/255, 178/255, 0/255 }, -- Uncommon
	[3] = { 0/255, 112/255, 221/255 }, -- Rare
	[4] = { 163/255, 53/255, 238/255 }, -- Epic
	[5] = { 225/255, 96/255, 0/255 }, -- Legendary
	[6] = { 229/255, 204/255, 127/255 }, -- Artifact
	[7] = { 79/255, 196/255, 225/255 }, -- Heirloom
	[8] = { 79/255, 196/255, 225/255 } -- Blizzard
}

-- Create an internal table for module-specific logic
local Module = {}

-- Flag to track if hooks are active
local hooksApplied = false

-- Function to clear iLvl text from a button
local function ClearItemLevelText(button)
    local cache = Cache[button]
    if (cache and cache.ilvl) then
        cache.ilvl:SetText("")
    end
    -- Restore upgrade icon position if needed
    local upgrade = button.UpgradeIcon
	if (upgrade and upgrade.mstMoved) then
        upgrade:ClearAllPoints()
		upgrade:SetPoint("TOPLEFT", 0, 0) -- Assuming default is TOPLEFT
        upgrade.mstMoved = nil
	end
end

-- Function to clear iLvl text from all visible container/bank buttons
local function ClearAllVisibleItemLevels()
    -- Clear regular containers
    for i = 1, NUM_CONTAINER_FRAMES do
        local frame = _G["ContainerFrame"..i]
        if frame and frame:IsShown() then
            local name = frame:GetName()
            local id = 1
            local button = _G[name.."Item"..id]
            while (button) do
                ClearItemLevelText(button)
                id = id + 1
                button = _G[name.."Item"..id]
            end
        end
    end

    -- Clear combined bag container
    if _G.ContainerFrameCombinedBags and _G.ContainerFrameCombinedBags:IsShown() then
         if (_G.ContainerFrameCombinedBags.EnumerateValidItems) then
            for id,button in _G.ContainerFrameCombinedBags:EnumerateValidItems() do
                ClearItemLevelText(button)
            end
        elseif (_G.ContainerFrameCombinedBags.Items) then
            for id,button in ipairs(_G.ContainerFrameCombinedBags.Items) do
                 ClearItemLevelText(button)
            end
        end
    end

    -- Clear bank frame
    if _G.BankFrame and _G.BankFrame:IsShown() then
        local BankSlotsFrame = _G.BankSlotsFrame -- Ensure it's accessed correctly
        if BankSlotsFrame then
             -- local bag = BankSlotsFrame:GetID() -- Not needed for clearing
            for id = 1, NUM_BANKGENERIC_SLOTS do
                local button = BankSlotsFrame["Item"..id]
                if (button and not button.isBag) then
                    ClearItemLevelText(button)
                end
            end
        end
        -- Also clear bank bags if they are separate frames
        for i = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
             local frame = _G["ContainerFrame"..i]
             if frame and frame:IsShown() then
                 local name = frame:GetName()
                 local id = 1
                 local button = _G[name.."Item"..id]
                 while (button) do
                     ClearItemLevelText(button)
                     id = id + 1
                     button = _G[name.."Item"..id]
                 end
             end
        end
    end
end

-- Function to update all visible container/bank buttons
-- Forward declaration
local UpdateContainer_Impl
local UpdateCombinedContainer_Impl
local UpdateBank_Impl
local UpdateBankButton_Impl

local function UpdateAllVisibleItemLevels()
    -- Update regular containers
    for i = 1, NUM_CONTAINER_FRAMES do
        local frame = _G["ContainerFrame"..i]
        if frame and frame:IsShown() then
             UpdateContainer_Impl(frame) -- Call implementation directly
        end
    end

    -- Update combined bag container
    if _G.ContainerFrameCombinedBags and _G.ContainerFrameCombinedBags:IsShown() then
         UpdateCombinedContainer_Impl(_G.ContainerFrameCombinedBags) -- Call implementation directly
    end

    -- Update bank frame
    if _G.BankFrame and _G.BankFrame:IsShown() then
        UpdateBank_Impl() -- Call implementation directly
        -- Also update bank bags if they are separate frames
        for i = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
             local frame = _G["ContainerFrame"..i]
             if frame and frame:IsShown() then
                 UpdateContainer_Impl(frame) -- Call implementation directly
             end
        end
    end
end


-- Callbacks
-----------------------------------------------------------
-- Update an itembutton's itemlevel
local Update = function(button, bag, slot) -- Renamed 'self' to 'button' for clarity
    -- Check if the feature is enabled
    if not MattSimpleTweaksDB or not MattSimpleTweaksDB.enableBagItemLevels then
        ClearItemLevelText(button) -- Ensure text is cleared if disabled
        return
    end

	local message, rarity, itemLink, _
	local r, g, b = 240/255, 240/255, 240/255
	if (C_Container_GetContainerItemInfo) then
		local containerInfo = C_Container_GetContainerItemInfo(bag,slot)
		if (containerInfo) then
			itemLink = containerInfo.hyperlink
		end
	else
		_, _, _, _, _, _, itemLink = GetContainerItemInfo(bag,slot)
	end
	if (itemLink) then
		local _, _, itemQuality, itemLevel, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)

		-- Display container slots of equipped bags.
		if (itemEquipLoc == "INVTYPE_BAG") then

			-- Use C_TooltipInfo for Retail/Modern clients
			if (C_TooltipInfo) then

				local tooltipData = C_TooltipInfo.GetBagItem(bag, slot)
				if (tooltipData and tooltipData.lines) then
					for i = 3,4 do
						local msg = tooltipData.lines[i] and tooltipData.lines[i].leftText
						if (not msg) then break end

						local numslots = string_match(msg, S_SLOTS)
						if (numslots) then
							numslots = tonumber(numslots)
							if (numslots > 0) then
								message = numslots
							end
							break
						end
					end
				end

			else -- Fallback for older clients (Classic Era, etc.)

				Scanner.owner = button
				Scanner.bag = bag
				Scanner.slot = slot
				Scanner:SetOwner(button, "ANCHOR_NONE")
				Scanner:SetBagItem(bag,slot)

				for i = 3,4 do
					local line = _G[_SCANNER.."TextLeft"..i]
					if (line) then
						local msg = line:GetText()
						if (msg) and (string_find(msg, S_SLOTS)) then
							local bagSlots = string_match(msg, S_SLOTS)
							if (bagSlots) and (tonumber(bagSlots) > 0) then
								message = bagSlots
							end
							break
						end
					end
				end
				Scanner:Hide() -- Hide scanner after use
			end


		elseif (itemQuality and itemQuality > 0 and itemEquipLoc and _G[itemEquipLoc] and itemEquipLoc ~= "INVTYPE_NON_EQUIP" and itemEquipLoc ~= "INVTYPE_NON_EQUIP_IGNORE" and itemEquipLoc ~= "INVTYPE_TABARD" and itemEquipLoc ~= "INVTYPE_AMMO" and itemEquipLoc ~= "INVTYPE_QUIVER") then

			local tipLevel

			-- Use C_TooltipInfo for Retail/Modern clients
			if (C_TooltipInfo) then

				local tooltipData = C_TooltipInfo.GetBagItem(bag, slot)
				if (tooltipData and tooltipData.lines) then
					for i = 2,3 do
						local msg = tooltipData.lines[i] and tooltipData.lines[i].leftText
						if (not msg) then break end

						local itemlevel = string_match(msg, S_ILVL)
						if (itemlevel) then
							itemlevel = tonumber(itemlevel)
							if (itemlevel > 0) then
								tipLevel = itemlevel
							end
							break
						end
					end
				end

			else -- Fallback for older clients

				Scanner.owner = button
				Scanner.bag = bag
				Scanner.slot = slot
				Scanner:SetOwner(button, "ANCHOR_NONE")
				Scanner:SetBagItem(bag,slot)

				for i = 2,3 do
					local line = _G[_SCANNER.."TextLeft"..i]
					if (line) then
						local msg = line:GetText()
						if (msg) and (string_find(msg, S_ILVL)) then
							local ilvl = (string_match(msg, S_ILVL))
							if (ilvl) and (tonumber(ilvl) > 0) then
								tipLevel = ilvl
							end
							break
						end
					end
				end
				Scanner:Hide() -- Hide scanner after use
			end

			-- Set a threshold to avoid spamming the classics with ilvl 1 whities
			tipLevel = tonumber(tipLevel or GetDetailedItemLevelInfo(itemLink) or itemLevel)
			if (tipLevel and tipLevel > 1) then
				message = tipLevel
				rarity = itemQuality
			end

		end
	end

	if (message and message > 1) then

		-- Retrieve or create the button's info container.
		local container = Cache[button]
		if (not container) then
			container = CreateFrame("Frame", nil, button)
			container:SetFrameLevel(button:GetFrameLevel() + 5)
			container:SetAllPoints()
			Cache[button] = container
		end

		-- Retrieve of create the itemlevel fontstring
		if (not container.ilvl) then
			container.ilvl = container:CreateFontString(nil, "OVERLAY") -- Ensure fontstring exists
			container.ilvl:SetDrawLayer("ARTWORK", 1)
			container.ilvl:SetPoint("TOPLEFT", 2, -2)
			container.ilvl:SetFontObject(NumberFont_Outline_Med or NumberFontNormal)
			container.ilvl:SetShadowOffset(1, -1)
			container.ilvl:SetShadowColor(0, 0, 0, .5)
		end

		-- Move conflicting upgrade icons
		local upgrade = button.UpgradeIcon
		if (upgrade) then
            -- Only move if it hasn't been moved already by us
            if not upgrade.mstMoved then
                upgrade:ClearAllPoints()
                upgrade:SetPoint("BOTTOMRIGHT", 2, 0)
                upgrade.mstMoved = true
            end
		end

		-- Colorize.
		if (rarity and colors[rarity]) then
			local col = colors[rarity]
			r, g, b = col[1], col[2], col[3]
        else -- Default color if rarity is missing
            r, g, b = 240/255, 240/255, 240/255
		end

		-- Tadaa!
		container.ilvl:SetTextColor(r, g, b)
		container.ilvl:SetText(message)

	else
        -- Use the helper function to clear text and reset icon
		ClearItemLevelText(button)
	end

end

-- Implementation for parsing a container
UpdateContainer_Impl = function(frame) -- Accept frame explicitly
    -- Check if the feature is enabled
    if not MattSimpleTweaksDB or not MattSimpleTweaksDB.enableBagItemLevels then return end

	local bag = frame:GetID() -- Use frame
	local name = frame:GetName() -- Use frame
	local id = 1
	local button = _G[name.."Item"..id]
	while (button) do
		if (button.hasItem) then
			Update(button, bag, button:GetID())
		else
			ClearItemLevelText(button)
		end
		id = id + 1
		button = _G[name.."Item"..id]
	end
end

-- Implementation for parsing combined container
UpdateCombinedContainer_Impl = function(frame) -- Accept frame explicitly
    -- Check if the feature is enabled
    if not MattSimpleTweaksDB or not MattSimpleTweaksDB.enableBagItemLevels then return end

	if (frame.EnumerateValidItems) then
		for id,button in frame:EnumerateValidItems() do -- Use frame
			if (button.hasItem) then
				Update(button, button:GetBagID(), button:GetID())
			else
				ClearItemLevelText(button)
			end
		end
	elseif (frame.Items) then
		for id,button in ipairs(frame.Items) do -- Use frame
			if (button.hasItem) then
				Update(button, button:GetBagID(), button:GetID())
			else
				ClearItemLevelText(button)
			end
		end
	end
end

-- Implementation for parsing the main bankframe
UpdateBank_Impl = function() -- Doesn't need frame argument
    -- Check if the feature is enabled
    if not MattSimpleTweaksDB or not MattSimpleTweaksDB.enableBagItemLevels then return end

	local BankSlotsFrame = _G.BankSlotsFrame
    if not BankSlotsFrame then return end
	local bag = BankSlotsFrame:GetID()
	for id = 1, NUM_BANKGENERIC_SLOTS do
		local button = BankSlotsFrame["Item"..id]
		if (button and not button.isBag) then
			if (button.hasItem) then
				Update(button, bag, button:GetID())
			else
				ClearItemLevelText(button)
			end
		end
	end
end

-- Implementation for updating a single bank button
UpdateBankButton_Impl = function(button) -- Accept button explicitly
    -- Check if the feature is enabled
    if not MattSimpleTweaksDB or not MattSimpleTweaksDB.enableBagItemLevels then
        ClearItemLevelText(button)
        return
    end

	if (button and not button.isBag) then
		-- Always run a full update here,
		-- as the .hasItem flag might not have been set yet.
        local BankSlotsFrame = _G.BankSlotsFrame
        if BankSlotsFrame then
		    Update(button, BankSlotsFrame:GetID(), button:GetID())
        end
	else
		ClearItemLevelText(button)
	end
end

-- Assign implementations to the Module table for external use if needed (though not strictly necessary with current structure)
Module.UpdateContainer = UpdateContainer_Impl
Module.UpdateCombinedContainer = UpdateCombinedContainer_Impl
Module.UpdateBank = UpdateBank_Impl
Module.UpdateBankButton = UpdateBankButton_Impl


-- Addon Core
-----------------------------------------------------------
local eventFrame = CreateFrame("Frame") -- Use a dedicated frame for events

-- Event handler.
Module.OnEvent = function(self, event, ...) -- 'self' here is eventFrame
    -- Check if the feature is enabled
    if not MattSimpleTweaksDB or not MattSimpleTweaksDB.enableBagItemLevels then return end

	if (event == "PLAYERBANKSLOTS_CHANGED") then
		local slot = ...
        local BankSlotsFrame = _G.BankSlotsFrame
        if not BankSlotsFrame then return end
		if (slot <= NUM_BANKGENERIC_SLOTS) then
			local button = BankSlotsFrame["Item"..slot]
			if (button and not button.isBag) then
                -- Call implementation directly
				UpdateBankButton_Impl(button)
			end
		end
	end
end

-- Enabling.
Module.OnEnable = function(self) -- 'self' here is the Module table
    if not hooksApplied then
        -- All the Classics
        if (_G.ContainerFrame_Update) then
            hooksecurefunc("ContainerFrame_Update", UpdateContainer_Impl)
        else
            -- Dragonflight and up
            local id = 1
            local frame = _G["ContainerFrame"..id]
            while (frame and frame.Update) do
                -- Pass the implementation function directly to hooksecurefunc
                hooksecurefunc(frame, "Update", UpdateContainer_Impl)
                id = id + 1
                frame = _G["ContainerFrame"..id]
            end
        end

        -- Dragonflight and up
        if (_G.ContainerFrameCombinedBags) then
            hooksecurefunc(_G.ContainerFrameCombinedBags, "Update", UpdateCombinedContainer_Impl)
        end

        -- Shadowlands and up
        if (_G.BankFrame_UpdateItems) then
            hooksecurefunc("BankFrame_UpdateItems", UpdateBank_Impl)

        -- Classics
        elseif (_G.BankFrameItemButton_UpdateLocked) then
            hooksecurefunc("BankFrameItemButton_UpdateLocked", UpdateBankButton_Impl)
        end
        hooksApplied = true
    end

	-- For single item changes
	eventFrame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
    eventFrame:SetScript("OnEvent", Module.OnEvent)

    -- Update currently visible items
    UpdateAllVisibleItemLevels()
end

-- Disabling
Module.OnDisable = function(self) -- 'self' here is the Module table
    -- Unregister events
    eventFrame:UnregisterEvent("PLAYERBANKSLOTS_CHANGED")
    eventFrame:SetScript("OnEvent", nil) -- Remove script handler

    -- Clear item levels from visible buttons
    ClearAllVisibleItemLevels()

    -- Note: Hooks remain applied but are bypassed by the DB check internally.
    -- Unhooking is complex and often unnecessary if the functions check the DB flag.
end

-- Expose functions to the main addon table
addonTable.EnableBagItemLevels = Module.OnEnable
addonTable.DisableBagItemLevels = Module.OnDisable

-- Check if enabled in DB and call OnEnable if needed
-- This runs when the file is loaded
if MattSimpleTweaksDB and MattSimpleTweaksDB.enableBagItemLevels then
    Module:OnEnable() -- Call OnEnable using colon notation on the Module table
end
