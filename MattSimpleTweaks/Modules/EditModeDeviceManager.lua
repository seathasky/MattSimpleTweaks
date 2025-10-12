local addonName, addonTable = ...

local function CreateDeviceManagerFrame()
    local frame = CreateFrame("Frame", "EditModeDeviceManagerFrameOptions", UIParent, "BackdropTemplate")
    frame:SetSize(500, 250)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Modern dark background (matching MST)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    -- Modern header
    local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    header:SetPoint("TOPLEFT")
    header:SetPoint("TOPRIGHT")
    header:SetHeight(40)
    header:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    header:SetBackdropColor(0.15, 0.15, 0.15, 1)
    header:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    -- Title text
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("CENTER", header, "CENTER")
    title:SetText("EDIT MODE DEVICE MANAGER")
    title:SetTextColor(0.565, 0.894, 0.757) -- Light teal (#90E4C1)

    -- Close button
    local closeButton = CreateFrame("Button", nil, header)
    closeButton:SetSize(24, 24)
    closeButton:SetPoint("TOPRIGHT", -2, -2)
    closeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    closeButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    closeButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
    closeButton:SetScript("OnClick", function() frame:Hide() end)

    -- Content container
    local content = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    content:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 5, -5)
    content:SetPoint("BOTTOMRIGHT", -5, 5)
    content:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    content:SetBackdropColor(0.15, 0.15, 0.15, 1)
    content:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    -- Add your existing Edit Mode Device Manager content functionality here
    -- but use white text (1, 1, 1) for all text elements

    frame:Hide()
    return frame
end

function addonTable:SetupEditModeDeviceManager()
    if not EditModeDeviceManagerFrameOptions then
        CreateDeviceManagerFrame()
    end
end
