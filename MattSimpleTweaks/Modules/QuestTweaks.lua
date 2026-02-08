local addonName, addonTable = ...

local questTweaksFrame

local function CanAutoAccept()
    return MattSimpleTweaksDB and MattSimpleTweaksDB.enableAutoAcceptQuests and not IsShiftKeyDown()
end

local function CanAutoTurnIn()
    return MattSimpleTweaksDB and MattSimpleTweaksDB.enableAutoTurnInQuests and not IsShiftKeyDown()
end

local function HandleQuestDetail()
    if not CanAutoAccept() then
        return
    end
    AcceptQuest()
end

local function HandleQuestProgress()
    if not CanAutoTurnIn() then
        return
    end
    if IsQuestCompletable() then
        CompleteQuest()
    end
end

local function HandleQuestComplete()
    if not CanAutoTurnIn() then
        return
    end

    local numChoices = GetNumQuestChoices() or 0
    if numChoices > 0 then
        return
    end

    GetQuestReward(1)
end

local function HandleQuestGreeting()
    if not CanAutoTurnIn() and not CanAutoAccept() then
        return
    end

    if CanAutoTurnIn() then
        local activeQuests = GetNumActiveQuests() or 0
        for index = 1, activeQuests do
            local _, isComplete = GetActiveTitle(index)
            if isComplete then
                SelectActiveQuest(index)
                return
            end
        end
    end

    if CanAutoAccept() then
        local availableQuests = GetNumAvailableQuests() or 0
        if availableQuests > 0 then
            SelectAvailableQuest(1)
        end
    end
end

local function HandleGossipShow()
    if not C_GossipInfo then
        return
    end

    if CanAutoTurnIn() then
        local activeQuests = C_GossipInfo.GetActiveQuests and C_GossipInfo.GetActiveQuests() or nil
        if activeQuests then
            for _, questInfo in ipairs(activeQuests) do
                if questInfo.isComplete and questInfo.questID then
                    C_GossipInfo.SelectActiveQuest(questInfo.questID)
                    return
                end
            end
        end
    end

    if CanAutoAccept() then
        local availableQuests = C_GossipInfo.GetAvailableQuests and C_GossipInfo.GetAvailableQuests() or nil
        if availableQuests then
            for _, questInfo in ipairs(availableQuests) do
                if questInfo.questID then
                    C_GossipInfo.SelectAvailableQuest(questInfo.questID)
                    return
                end
            end
        end
    end
end

function addonTable:SetupQuestTweaks()
    if questTweaksFrame then
        return
    end

    questTweaksFrame = CreateFrame("Frame")
    questTweaksFrame:RegisterEvent("QUEST_DETAIL")
    questTweaksFrame:RegisterEvent("QUEST_PROGRESS")
    questTweaksFrame:RegisterEvent("QUEST_COMPLETE")
    questTweaksFrame:RegisterEvent("QUEST_GREETING")
    questTweaksFrame:RegisterEvent("GOSSIP_SHOW")

    questTweaksFrame:SetScript("OnEvent", function(_, event)
        if event == "QUEST_DETAIL" then
            HandleQuestDetail()
        elseif event == "QUEST_PROGRESS" then
            HandleQuestProgress()
        elseif event == "QUEST_COMPLETE" then
            HandleQuestComplete()
        elseif event == "QUEST_GREETING" then
            HandleQuestGreeting()
        elseif event == "GOSSIP_SHOW" then
            HandleGossipShow()
        end
    end)
end
