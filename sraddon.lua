--------------------------------
--     Addon Initilization    --
--------------------------------

function SRAddon_OnLoad()
    -- addon loaded, time to give it something to work with
    this:RegisterEvent("PLAYER_LEVEL_UP");
    this:RegisterEvent("PLAYER_ENTERING_WORLD");
    this:RegisterEvent("VARIABLES_LOADED");
    this:RegisterEvent("ZONE_CHANGED_NEW_AREA");
    this:RegisterEvent("TIME_PLAYED_MSG");
    InitFrame();
    SRAddon_SlashCommands()
end

function SRAddon_OnEvent(this, event, arg1, arg2)
    if ( event == "TIME_PLAYED_MSG" ) then
        if ( playedRequest ) then
			totalTimeString, localTimeString = GetPlayedTimeString(arg1, arg2);
			ChatFrame1:AddMessage(totalTimeString);
			ChatFrame1:AddMessage(localTimeString);
	    playedRequest =  false;
        end
    elseif ( event == "PLAYER_LEVEL_UP" ) then
        -- Track player level
        SRAddon_StackInsertPlayerLeveled(arg1)
    elseif ( event == "VARIABLES_LOADED" ) then
        if ( not SRAddonVariables ) then
            SRAddon_InitVars();
        end
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        -- Run on world loading to ensure player has a level and a position
        SRAddonVariables["playerLevel"] = UnitLevel("player");
        SRAddonVariables["currentZone"] = GetZoneText();

        --Unregisters an event from the chat window to avoid yellow system messages spam
        --/played will still work through this addon
        DEFAULT_CHAT_FRAME:UnregisterEvent("TIME_PLAYED_MSG");

        -- If the player's level is 1 with 0 xp, wipe the saved variables.
        -- This safeguards against quests being carried over from deleted characters with an identical name.
        if ( SRAddonVariables["playerLevel"] == 1 ) then
            if ( UnitXP("player") == 0 ) then
                SRAddon_InitVars();
            end
        end

        -- Build the internal quest log from the quests in the player's quest log.
        SRAddonVariables["currentQuestLog"] = {};
        local count = 0;
        ExpandQuestHeader(0)
        for i=1,GetNumQuestLogEntries() do
            local title, level, _, isHeader = GetQuestLogTitle(i);
            if ( not isHeader ) then
                count = count + 1;
                SRAddonVariables["currentQuestLog"][count] = title;
            end
        end
    elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
        SRAddon_StackInsertZoneChange();
    end
end

function SRAddon_InitVars()
    SRAddonVariables = {
	["playerLevel"] = 1,
	["currentZone"] = "",
	["DEBUG_MODE"] = false,
	["selectedLevel"] = nil,
	["currentQuestLog"] = {},
	["completedQuestLog"] = {}
	};
	SRAddonStack = {};
end

function SRAddon_SlashCommands()
    --HIJACKING DEFAULT WOW FUNCTION
    --Overwrites /played so it functions after we unregister the TIME_PLAYED_MSG event from the default chat frame.
	SLASH_PLAYED1 = "/played";
    SlashCmdList["PLAYED"] = function()
        playedRequest = true;
        RequestTimePlayed();
    end

    --Addon-specific commands
    SLASH_SR1 = "/sr";
    SlashCmdList["SR"] = SlashCommandParser;
end

local CommandList = {
	["FRAME"] = 	function()
       			 		ShowFrames();
    				end,
	["QUEST"] = function(index)
                    index = tonumber(index)
                    if ( GetNumQuestLogEntries() == 0 ) then
                        ChatFrame1:AddMessage("The quest log is empty.")
					elseif ( index == math.floor(index) and index > 0 and GetNumQuestLogEntries() >= index ) then
                        local title, level, _, isHeader = GetQuestLogTitle(index);
                        ChatFrame1:AddMessage(title);
                        ChatFrame1:AddMessage(level);
                        if isHeader then
                            ChatFrame1:AddMessage(isHeader);
                        end
					else
						ChatFrame1:AddMessage("Function QUEST expects an integer as input.");
					end
				end,
	["COMPLETED"] = function()
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
    				end,
	["LOG"] = 	function()
					if ( not SRAddonVariables["currentQuestLog"] ) then
            			ChatFrame1:AddMessage("The quest log does not exist.")
        			elseif ( next(SRAddonVariables["currentQuestLog"]) == nil ) then
            			ChatFrame1:AddMessage("The quest log is empty.")
        			else
            			ChatFrame1:AddMessage("Quests found. Listing quests:")
            			for i,quest in SRAddonVariables["currentQuestLog"] do
                			ChatFrame1:AddMessage("The quest "..quest.." is in quest log position "..i..".")
            			end
        			end
    			end,
	["DEBUG"] = function()
					SRAddonVariables["DEBUG_MODE"] = not SRAddonVariables["DEBUG_MODE"];
        			if ( SRAddonVariables["DEBUG_MODE"] ) then
            			ChatFrame1:AddMessage("Debug state set to true.");
        			else
            			ChatFrame1:AddMessage("Debug state set to false.");
        			end
    			end
};

function SlashCommandParser(msg)
    if ( msg == "" ) then
        CommandList["FRAME"]()
    else
        local words = {}
        --read all words (seperated by whitespace)
        for w in string.gfind(msg,'(%S+)') do
            table.insert(words, w)
        end
        command = string.upper(words[1]);
        table.remove(words,1);
        if CommandList[command] then
            CommandList[command](unpack(words))
        else
            ChatFrame1:AddMessage("Unrecognized command '"..command.."' for SRAddon");
        end
	end
end


------------------------------
--      Stack handlers      --
------------------------------

function SRAddon_StackInsertZoneChange()
	local newZone = GetZoneText();
    table.insert(SRAddonStack,{"ZoneChanged",SRAddonVariables["currentZone"],newZone});
	SRAddonVariables["currentZone"] = newZone;
end

function SRAddon_StackInsertPlayerLeveled(newLevel)
    SetMapToCurrentZone()
	local posX, posY = GetPlayerMapPosition("player");
    table.insert(SRAddonStack,{"PlayerLeveled",SRAddonVariables["playerLevel"],newLevel,posX,posY});
	SRAddonVariables["playerLevel"] = newLevel;
end

function SRAddon_StackInsertQuestAccepted(questTitle)
	SetMapToCurrentZone()
	local posX, posY = GetPlayerMapPosition("player");
	table.insert(SRAddonStack,{"QuestAccepted",questTitle,SRAddonVariables["playerLevel"],posX,posY});
end

function SRAddon_StackInsertQuestCompleted(questTitle)
	SetMapToCurrentZone()
	local posX, posY = GetPlayerMapPosition("player");
	table.insert(SRAddonStack,{"QuestCompleted",questTitle,SRAddonVariables["playerLevel"],posX,posY});
end

function SRAddon_StackAbandonQuest(questTitle)
	--quest abandoned
	for i = table.getn(SRAddonStack), 1, -1 do
        if ( SRAddonStack[i][1] == "QuestAccepted" and SRAddonStack[i][2] == questTitle ) then
            table.remove(SRAddonStack,i);
            return
        end
    end
end

-----------------------------
--    Utility Functions    --
-----------------------------

function GetPlayedTimeString(arg1,arg2)
	--convert the life time of the character into a formatted string
	local totalTime = arg1;
	local localTime = arg2;
	local secondsPerPeriod = {30*86400, 604800, 86400, 3600, 60, 1};
	local periodName = {"month", "week", "day", "hour", "minute", "second"};
	local periods1 = {};
	local periods2 = {};
	for i,seconds in secondsPerPeriod do
		numPeriods1 = math.floor(totalTime/seconds);
		numPeriods2 = math.floor(localTime/seconds);
		table.insert(periods1,numPeriods1);
		table.insert(periods2,numPeriods2);
		totalTime = totalTime - numPeriods1*seconds;
		localTime = localTime - numPeriods2*seconds;
	end
	local playedTimeString1 = "Total time played: "
	local playedTimeString2 = "Time played this level: ";
	for i,periods in periods1 do
		if ( periods==1 ) then
			playedTimeString1 = playedTimeString1..periods.." "..periodName[i].." ";
		else
			playedTimeString1 = playedTimeString1..periods.." "..periodName[i].."s ";
		end
	end
	for i,periods in periods2 do
		if ( periods==1 ) then
			playedTimeString2 = playedTimeString2..periods.." "..periodName[i].." ";
		else
			playedTimeString2 = playedTimeString2..periods.." "..periodName[i].."s ";
		end
	end
	return playedTimeString1, playedTimeString2;
end

-----------------------------------------------
-- Overwriting Blizzard UI element functions --
-----------------------------------------------

-- Why can't we just hook scripts to UI elements in this version? =(


--Overwrites the YES button of the static popup that appears after a quest is marked for abandonment
--jf. lines 749 to 774 of StaticPopup.lua of the 1.12 WoW source code
ABANDONQUEST_OnAccept = function()
    -- Normal 1.12 WoW code
    AbandonQuest();
	PlaySound("igQuestLogAbandonQuest");

	-- Added code to manage our quest log
	SRAddon_StackAbandonQuest(GetAbandonQuestName())
end

ABANDONQUESTWITHITEMS_OnAccept = function()
    -- Normal 1.12 WoW code
    AbandonQuest();
	PlaySound("igQuestLogAbandonQuest");

	-- Added code to manage our quest log
	SRAddon_StackAbandonQuest(GetAbandonQuestName())
end

StaticPopupDialogs["ABANDON_QUEST"]["OnAccept"] = ABANDONQUEST_OnAccept;
StaticPopupDialogs["ABANDON_QUEST_WITH_ITEMS"]["OnAccept"] = ABANDONQUESTWITHITEMS_OnAccept;


--Overwrites the Accept Quest button offers by quest givers
--jf. lines 571 to 573 of QuestFrame.lua of the 1.12 WoW source code
function QuestDetailAcceptButton_OnClick()
    -- Normal 1.12 WoW code
	AcceptQuest();

	-- Added code to manage our quest log
	table.insert(SRAddonVariables["currentQuestLog"],GetTitleText())
	if ( SRAddonVariables["DEBUG_MODE"] ) then
        ChatFrame1:AddMessage("These quests are now in the quest log:")
        for i,questName in SRAddonVariables["currentQuestLog"] do
            ChatFrame1:AddMessage(questName)
        end
    end
    SRAddon_StackInsertQuestAccepted(GetTitleText())
end


--Overwrites the Complete Quest button offers by quest givers
--jf. lines 96 to 103 of QuestFrame.lua of the 1.12 WoW source code
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
		for i,questName in SRAddonVariables["currentQuestLog"] do
            if ( questName == name ) then
                table.remove(SRAddonVariables["currentQuestLog"], i);
                break
            end
		end

		table.insert(SRAddonVariables["completedQuestLog"],{name,SRAddonVariables["playerLevel"],SRAddonVariables["currentZone"]});
    end
    SRAddon_StackInsertQuestCompleted(name)
end
