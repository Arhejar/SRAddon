--------------------------------
--     OnLoad and OnEvent     --
--------------------------------

function SRAddon_OnLoad()
    -- addon loaded, time to give it something to work with
    this:RegisterEvent("PLAYER_LEVEL_UP");
    this:RegisterEvent("PLAYER_ENTERING_WORLD");
    this:RegisterEvent("VARIABLES_LOADED");
    this:RegisterEvent("ZONE_CHANGED_NEW_AREA");
    SRAddon_SlashCommands();
end

function SRAddon_OnEvent(this, event, arg1)
    if ( event == "PLAYER_LEVEL_UP" ) then
        -- Track player level
        ChatFrame1:AddMessage("Check one. ");
        SRAddonVariables["playerLevel"] = arg1;
    elseif ( event == "VARIABLES_LOADED" ) then
        if ( not SRAddonVariables ) then
            SRAddon_InitVars();
        end
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        -- Run on world loading to ensure player has a level
        SRAddonVariables["playerLevel"] = UnitLevel("player");
        SRAddonVariables["currentZone"] = GetZoneText();

        -- If the player's level is 1 with 0 xp, wipe the saved variables.
        -- This safeguards against quests being carried over from deleted characters.
        if ( SRAddonVariables["playerLevel"] == 1 ) then
            if ( UnitXP("player") == 0 ) then
                SRAddon_InitVars();
            end
        end

        -- Build the internal quest log from the quests in the player's quest log.
        SRAddonVariables["questLog"] = {};
        local count = 0;
        ExpandQuestHeader(0)
        for i=1,GetNumQuestLogEntries() do
            local title, level, _, isHeader = GetQuestLogTitle(i);
            if ( not isHeader ) then
                count = count + 1;
                SRAddonVariables["questLog"][count] = title;
            end
        end
    elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
        SRAddonVariables["currentZone"] = GetZoneText();
    end
end

function SRAddon_InitVars()
    if ( SRAddonVariables and SRAddonVariables["DEBUG_MODE"] ) then
        ChatFrame1:AddMessage("InitVars command initiated.")
    end

    SRAddonVariables = {};
    SRAddonVariables["playerLevel"] = 1;
    SRAddonVariables["DEBUG_MODE"] = false;
    SRAddonVariables["currentZone"] = nil;
    SRAddonVariables["questLog"] = {};
    SRAddonVariables["completedQuestLog"] = {};
end

function SRAddon_SlashCommands()
    SLASH_SRLEVEL1 = "/SRlevel";
    SlashCmdList["SRLEVEL"] = function()
        ChatFrame1:AddMessage("Player level is: "..SRAddonVariables["playerLevel"]);
    end
    SLASH_SRDEBUG1 = "/SRdebug";
    SlashCmdList["SRDEBUG"] = function()
        SRAddonVariables["DEBUG_MODE"] = not SRAddonVariables["DEBUG_MODE"];
        if ( SRAddonVariables["DEBUG_MODE"] ) then
            ChatFrame1:AddMessage("Debug state set to true.");
        else
            ChatFrame1:AddMessage("Debug state set to false.");
        end
    end
    SLASH_SRLOG1 = "/SRlog";
    SlashCmdList["SRLOG"] = function()
        if ( not SRAddonVariables["questLog"] ) then
            ChatFrame1:AddMessage("The quest log does not exist.")
        elseif ( next(SRAddonVariables["questLog"]) == nil ) then
            ChatFrame1:AddMessage("The quest log is empty.")
        else
            ChatFrame1:AddMessage("Quests found. Listing quests:")
            for i,quest in SRAddonVariables["questLog"] do
                ChatFrame1:AddMessage("The quest "..quest.." is in quest log position "..i..".")
            end
        end
    end
    SLASH_SRCOMPLETED1 = "/SRcompleted";
    SlashCmdList["SRCOMPLETED"] = function()
        if ( not SRAddonVariables["completedQuestLog"] ) then
            ChatFrame1:AddMessage("The completed quests log does not exist.")
        elseif ( next(SRAddonVariables["completedQuestLog"]) == nil ) then
            ChatFrame1:AddMessage("The completed quests log is empty.")
        else
            ChatFrame1:AddMessage("Completed quests found. Listing first twenty quests:")
            local i = 1;
            for i,quest in SRAddonVariables["completedQuestLog"] do
                if i>20 then
                    break
                else
                    ChatFrame1:AddMessage("The quest "..quest[1].." was completed at player level "..quest[2].." in the zone "..quest[3].." and is listed in position "..i..".")
                end
            end
        end
    end
    SLASH_SRQUEST1 = "/SRquest";
    SlashCmdList["SRQUEST"] = function(msg)
        local title, level, _, isHeader = GetQuestLogTitle(msg);
        ChatFrame1:AddMessage(title);
        ChatFrame1:AddMessage(level);
        if isHeader then
            ChatFrame1:AddMessage(isHeader);
        end
    end
end


-----------------------------------------------
-- Overwriting Blizzard UI element functions --
-----------------------------------------------

local AbandonQuestFunction = AbandonQuest;
abandonFlag = 0;
function AbandonQuest()
    -- This code is apparently run twice.
    -- Added code to manage our quest log
    abandonFlag = not abandonFlag;
    if ( abandonFlag ) then
        if ( SRAddonVariables["DEBUG_MODE"] ) then
            ChatFrame1:AddMessage("The abandoned quest is named: "..GetAbandonQuestName());
        end
        for i,questName in SRAddonVariables["questLog"] do
            if ( questName == GetAbandonQuestName() ) then
                table.remove(SRAddonVariables["questLog"], i);
                break
            end
		end
    end

    -- Run the normal 1.12 WoW function
    return AbandonQuestFunction();
end

function QuestDetailAcceptButton_OnClick()
    -- Normal 1.12 WoW code
	AcceptQuest();

	-- Added code to manage our quest log
	table.insert(SRAddonVariables["questLog"],GetTitleText())
	if ( SRAddonVariables["DEBUG_MODE"] ) then
        ChatFrame1:AddMessage("These quests are now in the quest log:")
        for i,questName in SRAddonVariables["questLog"] do
            ChatFrame1:AddMessage(questName)
        end
    end
end

function QuestRewardCompleteButton_OnClick()
    -- Normal 1.12 WoW code
	if ( QuestFrameRewardPanel.itemChoice == 0 and GetNumQuestChoices() > 0 ) then
		QuestChooseRewardError();
	else
		GetQuestReward(QuestFrameRewardPanel.itemChoice);
		PlaySound("igQuestListComplete");

		-- Added code to manage our quest log
		local name = GetTitleText();
		if ( SRAddonVariables["DEBUG_MODE"] ) then
            ChatFrame1:AddMessage("You have completed the quest "..name);
        end
		for i,questName in SRAddonVariables["questLog"] do
            if ( questName == name ) then
                table.remove(SRAddonVariables["questLog"], i);
                break
            end
		end

		table.insert(SRAddonVariables["completedQuestLog"],{name,SRAddonVariables["playerLevel"],SRAddonVariables["currentZone"]});
    end
end


--------------------------------------
--   Generating the AddOn's frame   --
--------------------------------------

function init()
  SRAddonFrame = CreateFrame("Frame", "SRAddonFrame")
  SRAddonFrame:SetHeight(200)
  SRAddonFrame:SetWidth(200)
  SRAddonFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",tile = true,tileSize = 16,insets = {left = -1.5, right = -1.5, top = -1.5, bottom = -1.5}})
  SRAddonFrame:SetBackdropColor(0.18,0.27,0.5)
  SRAddonFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  SRAddonFrame:SetFrameStrata("DIALOG")
  SRAddonFrame:EnableMouse(1)
  SRAddonFrame:SetMovable(1)
  SRAddonFrame:RegisterForDrag("LeftButton")
  SRAddonFrame:SetScript("OnDragStart", StartMoving)
  SRAddonFrame:SetScript("OnDragStop", StopMovingOrSizing)

  textfield = CreateFrame("Frame")
  SRAddonFrame.CloseButton = CreateFrame("Button", "SRAddonCloseButton", SRAddonFrame,"UIPanelCloseButton")
  SRAddonFrame.CloseButton:SetPoint("TOPRIGHT", SRAddonFrame, "TOPRIGHT", 0, 0)
  SRAddonFrame:Show()
end

function StartMoving()
  this:StartMoving()
end

function StopMovingOrSizing()
  this:StopMovingOrSizing()
end
