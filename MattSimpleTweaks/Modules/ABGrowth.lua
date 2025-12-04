local addon_name, a = ...

local modified = {}

local barMap = {
    [1] = 'MainActionBar',
    [2] = 'MultiBarBottomLeft',
    [3] = 'MultiBarBottomRight',
    [4] = 'MultiBarRight',
    [5] = 'MultiBarLeft',
    [6] = 'MultiBar5',
    [7] = 'MultiBar6',
    [8] = 'MultiBar7',
}

local fallbackMap = {
    ['MainMenuBar'] = 'MainActionBar',
    ['MainActionBar'] = 'MainMenuBar',
}

local function resolve_bar_name(name)
    if type(name) ~= 'string' then return nil end
    if _G[name] then return name end
    if fallbackMap[name] and _G[fallbackMap[name]] then return fallbackMap[name] end
    local alt = name:gsub('MainMenuBar', 'MainActionBar')
    if alt ~= name and _G[alt] then return alt end
    return nil
end

local function TryGetFrame(nameOrFrame)
    if type(nameOrFrame) == 'table' then
        local okName = nil
        if type(nameOrFrame.GetName) == 'function' then
            okName = nameOrFrame:GetName()
        end
        return nameOrFrame, okName
    end
    if type(nameOrFrame) ~= 'string' then
        return nil, nil
    end
    local resolved = resolve_bar_name(nameOrFrame) or nameOrFrame
    local frame = _G[resolved]
    if frame then
        return frame, resolved
    end
    return nil, nil
end

local function reverse_growth(frame, optName)
    if not frame then return end
    frame.addButtonsToTop = not frame.addButtonsToTop
end

local function modify_bars()
    local barName = barMap[1]
    local frame, resolved = TryGetFrame(barName)
    if frame then
        reverse_growth(frame, resolved or barName)
        modified[resolved or barName] = frame
    end
end

local function update_grid_layouts()
    local c = 0
    for name, frame in pairs(modified) do
        if frame and type(frame.UpdateGridLayout) == 'function' then
            frame:UpdateGridLayout()
            c = c + 1
        end
    end
    wipe(modified)
end

local ef = CreateFrame('Frame')
ef:RegisterEvent('PLAYER_LOGIN')

ef:SetScript('OnEvent', function(self, event, ...)
    if event == 'PLAYER_LOGIN' and MattSimpleTweaksDB and MattSimpleTweaksDB.enableABGrowth then
        modify_bars()
        update_grid_layouts()
    end
end)

