-- WoW API globals
local _, addon = ...
local _G = _G
local CreateFrame = _G.CreateFrame
local UnitGUID = _G.UnitGUID
local UnitName = _G.UnitName
local C_QuestLog = _G.C_QuestLog
local C_NamePlate = _G.C_NamePlate
local C_TaskQuest = _G.C_TaskQuest
local C_TooltipInfo = _G.C_TooltipInfo
local C_Map = _G.C_Map
local TooltipUtil = _G.TooltipUtil
local GetQuestObjectiveInfo = _G.GetQuestObjectiveInfo
local hooksecurefunc = _G.hooksecurefunc
local strsplit = _G.strsplit
local pairs = _G.pairs
local ipairs = _G.ipairs
local select = _G.select
local ceil = _G.ceil
local wipe = _G.wipe
local GetCVar = _G.GetCVar

local f = CreateFrame("Frame")
local OurName = UnitName('player')
local ActiveWorldQuests = {}
local QuestLogIndex = {}

local function SetupNameplateIcon(unitFrame)
    if not unitFrame.questIcon then
        local frame = CreateFrame('Frame', nil, unitFrame)
        frame:SetAllPoints()
        
        -- Progress text only
        local text = frame:CreateFontString(nil, 'OVERLAY', 'SystemFont_Shadow_Small')
        text:SetPoint('RIGHT', unitFrame.healthBar, 'RIGHT', 25, 8)
        text:SetTextColor(1, .82, 0)
        text:SetJustifyH('LEFT')  -- Left-align text so it grows rightward from the anchor point
        frame.progressText = text

        frame:Hide()
        unitFrame.questIcon = frame
    end
end

local function GetQuestProgress(unitID)
    if not unitID or not C_QuestLog.UnitIsRelatedToActiveQuest(unitID) then return end

    local tooltipData = C_TooltipInfo.GetUnit(unitID)
    if not tooltipData or not tooltipData.lines then return end

    local progressGlob
    local questType -- 1 for player, 2 for group, 3 for world quest
    local objectiveValue = 0 -- Can be remaining count OR actual percentage
    local questLogIndex
    local questID
    local isPercentQuest = false -- Flag for percentage-based quests

    for i = 1, #tooltipData.lines do
        local line = tooltipData.lines[i]
        if line and line.leftText then
            local text = line.leftText
            if text then
                -- Check if this is a world quest
                if ActiveWorldQuests[text] then
                    questID = ActiveWorldQuests[text]
                    local progress = C_TaskQuest.GetQuestProgressBarInfo(questID)
                    if progress then
                        -- Return ACTUAL progress percentage for WQ with % sign
                        local percentValue = ceil(progress)
                        return text, 3, percentValue, questID, true
                    end
                end

                -- Check for percentage in text (e.g. "50%")
                local percentValue = text:match("(%d+)%%")
                if percentValue then
                    local value = tonumber(percentValue)
                    -- Return with % flag for regular percentage quests
                    return text, 1, value, nil, nil, true
                end

                -- Check for regular x/y objectives (only if not already found a %)
                if not isPercentQuest then
                    local x, y = text:match("(%d+)/(%d+)")
                    if x and y then
                        x, y = tonumber(x), tonumber(y)
                        local numLeft = y - x
                        -- Store remaining count and never treat as percent
                        objectiveValue = numLeft
                        progressGlob = text
                        questType = 1
                        isPercentQuest = false
                        if numLeft > 0 then
                            -- If we found remaining kills, return immediately
                            return progressGlob, 1, numLeft, questLogIndex, nil, false
                        end
                    end
                end

                -- Check for quest titles (always do this)
                if QuestLogIndex[text] then
                    questLogIndex = QuestLogIndex[text]
                end
            end
        end
    end

    -- Return remaining count OR actual percentage
    return progressGlob, progressGlob and 1 or questType, objectiveValue, questLogIndex, questID, isPercentQuest
end

local function UpdateNameplate(namePlate)
    -- Check if the feature is enabled
    if not MattSimpleTweaksDB or not MattSimpleTweaksDB.enableNameplateQuestObjectives then
        local unitFrame = namePlate.UnitFrame
        if unitFrame and unitFrame.questIcon then
            unitFrame.questIcon:Hide()
        end
        return
    end

    local unitFrame = namePlate.UnitFrame
    if not unitFrame or not unitFrame.unit then return end
    
    SetupNameplateIcon(unitFrame)
    local icon = unitFrame.questIcon
    
    -- objectiveValue is actual % (0-100) if isPercentQuest is true
    -- objectiveValue is remaining count if isPercentQuest is false
    local progressGlob, questType, objectiveValue, questLogIndex, questID, isPercentQuest = GetQuestProgress(unitFrame.unit)
    
    if progressGlob and questType ~= 2 then
        -- CHANGE QUEST OBJECT TEXT POSITION HERE
        -- Position the text on the right side to avoid target arrows: count-based quests 5 pixels more to the right
        if isPercentQuest or questType == 3 then -- Percentage quest OR World Quest
            icon.progressText:SetPoint('RIGHT', unitFrame.healthBar, 'RIGHT', 45, 1)
        else -- Regular x/y quest
            icon.progressText:SetPoint('RIGHT', unitFrame.healthBar, 'RIGHT', 34, 1)
        end
        
        if isPercentQuest or questType == 3 then -- Percentage quest OR World Quest
            icon.progressText:SetText('(' .. objectiveValue .. '%)')  -- Always add % for percent quests with parentheses
            if questType == 3 then
                 icon.progressText:SetTextColor(0.2, 1, 1) -- Cyan for WQ
            else
                 icon.progressText:SetTextColor(1, .82, 0) -- Gold for regular % quest
            end
        else -- Regular x/y quest
            icon.progressText:SetText(objectiveValue > 0 and ('(' .. objectiveValue .. ')') or '') -- Show remaining count with parentheses
            icon.progressText:SetTextColor(1, .82, 0) -- Gold for regular count
        end

        if not icon:IsVisible() then
            icon:Show()
        end
    else
        icon:Hide()
    end
end

-- Cache quest data
local function UpdateQuestCache()
    wipe(QuestLogIndex)
    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local info = C_QuestLog.GetInfo(i)
        if info and not info.isHeader then
            QuestLogIndex[info.title] = i
        end
    end
end

-- World quest tracking
local function UpdateWorldQuests()
    wipe(ActiveWorldQuests)
    local mapID = C_Map.GetBestMapForUnit('player')
    if mapID then
        for _, task in pairs(C_TaskQuest.GetQuestsForPlayerByMapID(mapID) or {}) do
            if task.inProgress then
                local questTitle = select(1, C_TaskQuest.GetQuestInfoByQuestID(task.questID))
                if questTitle then
                    ActiveWorldQuests[questTitle] = task.questID
                end
            end
        end
    end
end

-- Event handling
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
f:RegisterEvent("QUEST_LOG_UPDATE")
f:RegisterEvent("QUEST_ACCEPTED")
f:RegisterEvent("QUEST_REMOVED")
f:RegisterEvent("QUEST_TURNED_IN")
f:RegisterEvent("UNIT_QUEST_LOG_CHANGED")

f:SetScript("OnEvent", function(self, event, ...)
    -- Check if the feature is enabled
    if not MattSimpleTweaksDB or not MattSimpleTweaksDB.enableNameplateQuestObjectives then
        if event == "NAME_PLATE_UNIT_ADDED" then
            local unit = ...
            local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
            if namePlate and namePlate.UnitFrame and namePlate.UnitFrame.questIcon then
                namePlate.UnitFrame.questIcon:Hide()
            end
        end
        return
    end

    if event == "PLAYER_LOGIN" then
        UpdateQuestCache()
        UpdateWorldQuests()
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        UpdateWorldQuests()
        
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        local unit = ...
        local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
        if namePlate then
            UpdateNameplate(namePlate)
        end
        
    elseif event == "QUEST_REMOVED" then
        local questID = ...
        local questTitle = select(1, C_TaskQuest.GetQuestInfoByQuestID(questID))
        if questTitle and ActiveWorldQuests[questTitle] then
            ActiveWorldQuests[questTitle] = nil
        end
        UpdateQuestCache()
        for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
            UpdateNameplate(namePlate)
        end

    elseif event == "QUEST_LOG_UPDATE" or 
           event == "QUEST_ACCEPTED" or 
           event == "QUEST_TURNED_IN" or
           event == "UNIT_QUEST_LOG_CHANGED" then
        UpdateQuestCache()
        for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
            UpdateNameplate(namePlate)
        end
    end
end)