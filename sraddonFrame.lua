--------------------------------------
--   Generating the AddOn's frame   --
--------------------------------------

function InitFrame()
    InitVars()
    SRBaseFrame = CreateFrame("Frame", "SRAddonBaseFrame")
    frames["SRAddonBaseFrame"] = SRBaseFrame;
    SRBaseFrame:SetHeight(314)
    SRBaseFrame:SetWidth(200)
    --SRBaseFrame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 8, edgeSize = 16, insets = {left = 3, right = 3, top = 3, bottom = 3}})
    SRBaseFrame:SetBackdropColor(0.18,0.27,0.5)
    SRBaseFrame:SetBackdropBorderColor(0.6, 0.6, 0.6)
    SRBaseFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    SRBaseFrame:SetFrameStrata("LOW")
    SRBaseFrame:EnableMouse(1)
    SRBaseFrame:SetMovable(1)
    SRBaseFrame:RegisterForDrag("LeftButton")
    SRBaseFrame:SetScript("OnHide", SRBaseFrameRegisterVisibility)
    SRBaseFrame:SetScript("OnDragStart", StartMoving)
    SRBaseFrame:SetScript("OnDragStop", StopMovingOrSizing)

    --title frame
    SRCreateChildTileFrame("TitleTileFrame", SRBaseFrame)
    frames["SRAddonTitleTileFrame"]:SetHeight(32)
    frames["SRAddonTitleTileFrame"]:SetPoint("TOPLEFT", SRBaseFrame, "TOPLEFT", 0, 0)
    frames["SRAddonTitleTileFrame"]:CreateFontString("SRAddonTitle",this:GetFrameLevel()+1,"GameFontNormal")
    SRAddonTitle:SetPoint("LEFT", SRAddonTitleTileFrame, "LEFT", 20, 0)
    SRAddonTitle:SetText("Speed Runners' Addon")

    --close button
    SRBaseFrame.CloseButton = CreateFrame("Button", "SRAddonBaseFrameCloseButton", SRBaseFrame,"UIPanelCloseButton")
    buttons["SRAddonBaseFrameCloseButton"] = SRBaseFrame.CloseButton;
    SRBaseFrame.CloseButton:SetPoint("TOPRIGHT", SRAddonBaseFrame, "TOPRIGHT", 0, 0)
    SRBaseFrame.CloseButton:SetBackdrop({bgFile = nil,edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 16})
    SRBaseFrame.CloseButton:SetBackdropBorderColor(0.6, 0.6, 0.6)
    SRAddonBaseFrameCloseButton:SetScript("OnClick",HideFrames)
    SRAddonBaseFrameCloseButton:SetFrameLevel(10)

    --guide tile
    SRCreateChildTileFrame("GuideTileFrame", SRBaseFrame)
    frames["SRAddonGuideTileFrame"]:SetPoint("TOP", frames["SRAddonTitleTileFrame"], "BOTTOM", 0, 8)
    --buttons
    SRCreateChildButton("GuideOpenButton", frames["SRAddonGuideTileFrame"], SRGuideOpenButton_OnClick, "LEFT")
    SRCreateChildButton("GuideCloseButton", frames["SRAddonGuideTileFrame"], SRGuideCloseButton_OnClick, "RIGHT")

    --log tile
    SRCreateChildTileFrame("LogTileFrame", SRBaseFrame)
    frames["SRAddonLogTileFrame"]:SetPoint("TOP", frames["SRAddonGuideTileFrame"], "BOTTOM", 0, 8)
    --button
    SRCreateChildButton("LogOpenButton", frames["SRAddonLogTileFrame"], SRLogOpenButton_OnClick, "LEFT")
    SRCreateChildButton("LogCloseButton", frames["SRAddonLogTileFrame"], SRLogCloseButton_OnClick, "RIGHT")

    --summary tile
    SRCreateChildTileFrame("SummaryTileFrame", SRBaseFrame)
    frames["SRAddonSummaryTileFrame"]:SetPoint("TOP", frames["SRAddonLogTileFrame"], "BOTTOM", 0, 8)
    --buttons
    SRCreateChildButton("SummaryOpenButton", frames["SRAddonSummaryTileFrame"], SRSummaryOpenButton_OnClick, "LEFT")
    SRCreateChildButton("SummaryCloseButton", frames["SRAddonSummaryTileFrame"], SRSummaryCloseButton_OnClick, "RIGHT")

    --Create a button that begins an aoe farming session log
    SRAddonAoEBeginButton = CreateFrame("Button", "SRAddonFrameAoEBeginButton", SRAddonLogTileFrame,"UIPanelButtonTemplate")
    buttons["SRAddonFarmBeginButton"] = SRAddonAoEBeginButton
    SRAddonFrameAoEBeginButton:SetPoint("CENTER", SRAddonLogTileFrame, "CENTER", 0, 0)
    SRAddonFrameAoEBeginButton:SetFrameLevel(SRAddonLogTileFrame:GetFrameLevel()+1)
    SRAddonFrameAoEBeginButton:SetScript("OnClick",AoEBeginButton_OnClick)
    SRAddonFrameAoEBeginButton:SetText("Begin session")
    local width = SRAddonFrameAoEBeginButton:GetTextWidth();
    local height = SRAddonFrameAoEBeginButton:GetTextHeight();
    SRAddonFrameAoEBeginButton:SetWidth(width+16);
    SRAddonFrameAoEBeginButton:SetHeight(height+8);

    --Button to end the aoe farming session
    SRAddonAoEEndButton = CreateFrame("Button", "SRAddonFrameAoEEndButton", SRAddonLogTileFrame,"UIPanelButtonTemplate")
    buttons["SRAddonFarmEndButton"] = SRAddonAoEEndButton
    SRAddonFrameAoEEndButton:SetPoint("CENTER", SRAddonLogTileFrame, "CENTER", 0, 0)
    SRAddonFrameAoEEndButton:SetFrameLevel(SRAddonLogTileFrame:GetFrameLevel()+1)
    SRAddonFrameAoEEndButton:SetScript("OnClick",AoEEndButton_OnClick)
    SRAddonFrameAoEEndButton:SetText("End session")
    SRAddonFrameAoEEndButton:SetWidth(width+16);
    SRAddonFrameAoEEndButton:SetHeight(height+8);

    --Hide all frames
    HideFrames()

    --populate widgets table with ui elements
    for key, button in buttons do
        table.insert(widgets, button)
    end
    for key, frame in frames do
        table.insert(widgets, frame)
    end
    --hide alternate buttons
    SRAddonFrameAoEEndButton:Hide()
    SRAddonGuideCloseButton:Hide()
    SRAddonLogCloseButton:Hide()
    SRAddonSummaryCloseButton:Hide()
end

function InitVars()
    buttons = {};
    frames = {};
    widgets = {};
    beginBool = true;
    endBool = false;
end

function SRCreateChildTileFrame(tileFrameName, parentFrame)
    local longName = "SRAddon"..tileFrameName;
    frames[longName] = CreateFrame("Frame", longName , parentFrame)
    frames[longName]:SetHeight(100)
    frames[longName]:SetWidth(200)
    frames[longName]:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 8, edgeSize = 16, insets = {left = 3, right = 3, top = 3, bottom = 3}})
    frames[longName]:SetBackdropColor(0.18,0.27,0.5)
    frames[longName]:SetBackdropBorderColor(0.6, 0.6, 0.6)
    frames[longName]:SetFrameLevel(parentFrame:GetFrameLevel()+1)
end

function SRCreateChildButton(buttonName, parentFrame, OnClickFunction, orientation)
    local longName = "SRAddon"..buttonName;
    buttons[longName] = CreateFrame("Button", longName, parentFrame,"UIPanelCloseButton")
    buttons[longName]:SetFrameLevel(parentFrame:GetFrameLevel()+1)
    buttons[longName]:SetScript("OnClick", OnClickFunction)
    buttons[longName]:SetPoint("LEFT", parentFrame, "LEFT", 8, 0)
    if ( orientation == "LEFT" ) then
        buttons[longName]:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
        buttons[longName]:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    elseif  ( orientation == "RIGHT" ) then
        buttons[longName]:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
        buttons[longName]:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
    end
end

function SRGuideOpenButton_OnClick()
    PlaySound("GAMEGENERICBUTTONPRESS")
    buttons["SRAddonGuideOpenButton"]:Hide()
    buttons["SRAddonGuideCloseButton"]:Show()
end

function SRGuideCloseButton_OnClick()
    PlaySound("GAMEGENERICBUTTONPRESS")
    buttons["SRAddonGuideOpenButton"]:Show()
    buttons["SRAddonGuideCloseButton"]:Hide()
end

function SRLogOpenButton_OnClick()
    PlaySound("GAMEGENERICBUTTONPRESS")
    buttons["SRAddonLogOpenButton"]:Hide()
    buttons["SRAddonLogCloseButton"]:Show()
end

function SRLogCloseButton_OnClick()
    PlaySound("GAMEGENERICBUTTONPRESS")
    buttons["SRAddonLogOpenButton"]:Show()
    buttons["SRAddonLogCloseButton"]:Hide()
end

function SRSummaryOpenButton_OnClick()
    PlaySound("GAMEGENERICBUTTONPRESS")
    buttons["SRAddonSummaryOpenButton"]:Hide()
    buttons["SRAddonSummaryCloseButton"]:Show()
end

function SRSummaryCloseButton_OnClick()
    PlaySound("GAMEGENERICBUTTONPRESS")
    buttons["SRAddonSummaryOpenButton"]:Show()
    buttons["SRAddonSummaryCloseButton"]:Hide()
end

function AoEBeginButton_OnClick()
    PlaySound("GAMEGENERICBUTTONPRESS")
    ChatFrame1:AddMessage("Beginning session")
    SRAddonAoEBeginButton:Hide()
    SRAddonAoEEndButton:Show()
end

function AoEEndButton_OnClick()
    PlaySound("GAMEGENERICBUTTONPRESS")
    ChatFrame1:AddMessage("Ending session")
    SRAddonAoEEndButton:Hide()
    SRAddonAoEBeginButton:Show()
end

function ShowFrames()
    SRAddonBaseFrame:Show()
end

function HideFrames()
    SRAddonBaseFrame:Hide()
end

function StartMoving()
    this:StartMoving()
end

function StopMovingOrSizing()
    this:StopMovingOrSizing()
end



--drop down menu

    --[[
    --Create drop down menu
    local LevelSelect = CreateFrame("Frame", "LevelSelectDropDownMenu", SRAddonFrame, "UIDropDownMenuTemplate")
    LevelSelect:SetFrameStrata("DIALOG")
    LevelSelect:SetPoint("TOP",SRAddonFrame, "TOP", 0, 0)
    LevelSelect:SetScript("OnShow", LevelSelect_OnShow)
    UIDropDownMenu_Initialize(evelSelectDropDownMenu, LevelSelect_Init);
    UIDropDownMenu_SetWidth(75, LevelSelectDropDownMenu)

function LevelSelect_Init()
    --Populate drop down menu. Can only contain 32 elements.
    local info;
	for i = 1, 30 do
		info = {
			text = "Level "..i;
			func = LevelSelect_OnClick;
		};
		UIDropDownMenu_AddButton(info);
	end
end

function LevelSelect_OnShow()
    UIDropDownMenu_Initialize(LevelSelectDropDownMenu, LevelSelect_Init);
    if ( not SRAddonVariables["selectedLevel"] ) then
        UIDropDownMenu_SetSelectedID(LevelSelectDropDownMenu, 1);
    else
        UIDropDownMenu_SetSelectedID(LevelSelectDropDownMenu, SRAddonVariables["selectedLevel"]);
    end
end

function LevelSelect_OnClick()
    i = this:GetID();
    UIDropDownMenu_SetSelectedID(LevelSelectDropDownMenu, i);
    SRAddonVariables["selectedLevel"] = i;

    LevelSelect_OnShow();
end
]]--
