--------------------------------
--     OnLoad and OnEvent     --
--------------------------------

function SRAddon_OnLoad()
    -- addon loaded, time to give it something to work with
    this:RegisterEvent("PLAYER_LEVEL_UP");
    this:RegisterEvent("PLAYER_ENTERING_WORLD");
    this:RegisterEvent("VARIABLES_LOADED");
    this:RegisterEvent("ZONE_CHANGED_NEW_AREA");
    this:RegisterEvent("TIME_PLAYED_MSG");
    SRAddon_SlashCommands();
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
        SRAddonVariables["playerLevel"] = arg1;
    elseif ( event == "VARIABLES_LOADED" ) then
        if ( not SRAddonVariables ) then
            SRAddon_InitVars();
        end
        InitFrame(); --Defined in sraddonFrame.lua
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
    SRAddonVariables = {
	["playerLevel"] = 1,
	["currentZone"] = "",
	["DEBUG_MODE"] = false,
	["selectedLevel"] = nil,
	["currentQuestLog"] = {},
	["completedQuestLog"] = {}
	};
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
    SLASH_SR1 = "/SR";
    SlashCmdList["SR"] = SlashCommandParser(msg);
end

local CommandList = {
	["FRAME"] = 	function()
       			 		ShowFrames();
    				end,
	["QUEST"] = function(index)
					if ( index == math.floor(index) and index > 0 and GetNumQuestLogEntries() >= index ) then
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
end

local function SlashCommandParser(msg)
	if string.match(msg, '^.-%s')
		if CommandList[string.match(string.upper(msg), '^.-%s')] then
			CommandList[string.match(string.upper(msg), '^.-%s')]
		end
	else
		ChatFrame1:AddMessage("Input not defined for SRAddon");
	end
end

local function GetPlayedTimeString(arg1,arg2)
	--convert the life time of the character into a formatted string
	local totalTime = arg1;
	local localTime = arg2;
	local secondsPerPeriod = {30*86400, 604800, 86400, 3600, 60, 1};
	local periodName = {"month", "week", "day", "hour", "minute", "second"};
	local periods1 = {};
	local periods2 = {};
	for i,seconds in secondsPerPeriod do
		numPeriods1 = math.fmod(totalTime, seconds);
		numPeriods2 = math.fmod(localTime, seconds);
		table.insert(periods1,numPeriods1);
		table.insert(periods2,numPeriods2);
		totalTime = totalTime - numPeriods1*seconds;
		localTime = localTime - numPeriods2*seconds;
	end
	local playedTimeString1 = "Total time played: "
	local playedTimeString2 = "Time played this level: ";
	for i,periods in periods1 do
		if ( periods==1 ) then
			local playedTimeString1 = playedTimeString1..periods.." "..periodName[i].." ";
		else
			local playedTimeString1 = playedTimeString1..periods.." "..periodName[i].."s ";
		end
	end
	for i,periods in periods2 do
		if ( periods==1 ) then
			local playedTimeString2 = playedTimeString2..periods.." "..periodName[i].." ";
		else
			local playedTimeString2 = playedTimeString2..periods.." "..periodName[i].."s ";
		end
	end
	return playedTimeString1, playedTimeString2;
end

-----------------------------------------------
-- Overwriting Blizzard UI element functions --
-----------------------------------------------

local SRAbandonQuestFunction = AbandonQuest;
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
    return SRAbandonQuestFunction();
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


--[[FIX THIS
function SR_DisplayTimePlayed(totalTime, levelTime)
	local info = ChatTypeInfo["SYSTEM"];
    local d;
	local h;
	local m;
	local s;
	d, h, m, s = ChatFrame_TimeBreakDown(totalTime);
	local string = format(TEXT(TIME_PLAYED_TOTAL), format(TEXT(TIME_DAYHOURMINUTESECOND), d, h, m, s));
	this:AddMessage(string, info.r, info.g, info.b, info.id);

	d, h, m, s = ChatFrame_TimeBreakDown(levelTime);
	local string = format(TEXT(TIME_PLAYED_LEVEL), format(TEXT(TIME_DAYHOURMINUTESECOND), d, h, m, s));
this:AddMessage(string, info.r, info.g, info.b, info.id);
]]--
