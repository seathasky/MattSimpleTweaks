local addon_name, a = ...

local modified = {}

local function modify_bar1_growth()
    local barName = "MainMenuBar"
    local bar = _G[barName]
    if bar then
        -- Toggle vertical growth direction for Action Bar 1
        bar.addButtonsToTop = not bar.addButtonsToTop 
        modified[barName] = true
    end
end

local function update_grid_layouts()
    local c = 0
    for barName, _ in pairs(modified) do
        local bar = _G[barName]
        if bar and bar.UpdateGridLayout then
            bar:UpdateGridLayout()
            c = c + 1
        end
    end
    wipe(modified)
end

local ef = CreateFrame('Frame')
ef:RegisterEvent('PLAYER_LOGIN')

ef:SetScript('OnEvent', function(self, event, ...)
    -- Check the main addon's setting before doing anything
    if event == 'PLAYER_LOGIN' and MattSimpleTweaksDB and MattSimpleTweaksDB.enableABGrowth then
        modify_bar1_growth()
        update_grid_layouts()
    end
end)

