--------------------------------------
--   Generating the AddOn's frame   --
--------------------------------------

function InitFrame()
    InitVars()
    SRBaseFrame = CreateFrame("Frame", "SRAddonBaseFrame")
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
    SRTitleTileFrame = CreateFrame("Frame", "SRAddonTitleTileFrame",SRBaseFrame)
    SRTitleTileFrame:SetHeight(32)
    SRTitleTileFrame:SetWidth(200)
    SRTitleTileFrame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 8, edgeSize = 16, insets = {left = 3, right = 3, top = 3, bottom = 3}})
    SRTitleTileFrame:SetBackdropColor(0.18,0.27,0.5)
    SRTitleTileFrame:SetBackdropBorderColor(0.6, 0.6, 0.6)
    SRTitleTileFrame:SetPoint("TOPLEFT", SRBaseFrame, "TOPLEFT", 0, 0)
    SRTitleTileFrame:SetFrameLevel(SRBaseFrame:GetFrameLevel()+1)
    SRTitleTileFrame:CreateFontString("SRAddonTitle",this:GetFrameLevel()+1,"GameFontNormal")
    SRAddonTitle:SetPoint("LEFT", SRAddonTitleTileFrame, "LEFT", 20, 0)
    SRAddonTitle:SetText("Speed Runners' Addon")


    --close button
    SRBaseFrame.CloseButton = CreateFrame("Button", "SRAddonBaseFrameCloseButton", SRBaseFrame,"UIPanelCloseButton")
    SRBaseFrame.CloseButton:SetPoint("TOPRIGHT", SRAddonBaseFrame, "TOPRIGHT", 0, 0)
    SRBaseFrame.CloseButton:SetBackdrop({
        bgFile = nil,
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
    })
    SRBaseFrame.CloseButton:SetBackdropBorderColor(0.6, 0.6, 0.6)
    SRAddonBaseFrameCloseButton:SetScript("OnClick",HideFrames)
    SRAddonBaseFrameCloseButton:SetFrameLevel(10)

    --guide tile
    SRGuideTileFrame = CreateFrame("Frame", "SRAddonGuideTileFrame",SRBaseFrame)
    SRGuideTileFrame:SetHeight(100)
    SRGuideTileFrame:SetWidth(200)
    SRGuideTileFrame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 8, edgeSize = 16, insets = {left = 3, right = 3, top = 3, bottom = 3}})
    SRGuideTileFrame:SetBackdropColor(0.18,0.27,0.5)
    SRGuideTileFrame:SetBackdropBorderColor(0.6, 0.6, 0.6)
    SRGuideTileFrame:SetPoint("TOP", SRTitleTileFrame, "BOTTOM", 0, 8)
    SRGuideTileFrame:SetFrameLevel(SRBaseFrame:GetFrameLevel()+1)
    parentFrame = SRAddonGuideTileFrame;

    local buttonName = "GuideOpenButton";
    SRCreateChildButton(buttonName, parentFrame, SRGuideOpenButton_OnClick)
    buttons["SRAddon"..buttonName]:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    buttons["SRAddon"..buttonName]:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    buttons["SRAddon"..buttonName]:SetPoint("LEFT", parentFrame, "LEFT", 8, 0)

    local buttonName = "GuideCloseButton";
    SRCreateChildButton(buttonName, parentFrame, SRGuideCloseButton_OnClick)
    buttons["SRAddon"..buttonName]:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    buttons["SRAddon"..buttonName]:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
    buttons["SRAddon"..buttonName]:SetPoint("LEFT", parentFrame, "LEFT", 8, 0)

    --log tile
    SRLogTileFrame = CreateFrame("Frame", "SRAddonLogTileFrame",SRBaseFrame)
    SRLogTileFrame:SetHeight(100)
    SRLogTileFrame:SetWidth(200)
    SRLogTileFrame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 8, edgeSize = 16, insets = {left = 3, right = 3, top = 3, bottom = 3}})
    SRLogTileFrame:SetBackdropColor(0.18,0.27,0.5)
    SRLogTileFrame:SetBackdropBorderColor(0.6, 0.6, 0.6)
    SRLogTileFrame:SetPoint("TOP", SRGuideTileFrame, "BOTTOM", 0, 8)
    SRLogTileFrame:SetFrameLevel(SRBaseFrame:GetFrameLevel()+1)
    parentFrame = SRAddonLogTileFrame;

    local buttonName = "LogOpenButton";
    SRCreateChildButton(buttonName, parentFrame, SRLogOpenButton_OnClick)
    buttons["SRAddon"..buttonName]:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    buttons["SRAddon"..buttonName]:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    buttons["SRAddon"..buttonName]:SetPoint("LEFT", parentFrame, "LEFT", 8, 0)

    local buttonName = "LogCloseButton";
    SRCreateChildButton(buttonName, parentFrame, SRLogCloseButton_OnClick)
    buttons["SRAddon"..buttonName]:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    buttons["SRAddon"..buttonName]:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
    buttons["SRAddon"..buttonName]:SetPoint("LEFT", parentFrame, "LEFT", 8, 0)

    --summary tile
    SRSummaryTileFrame = CreateFrame("Frame", "SRAddonSummaryTileFrame",SRBaseFrame)
    SRSummaryTileFrame:SetHeight(100)
    SRSummaryTileFrame:SetWidth(200)
    SRSummaryTileFrame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 8, edgeSize = 16, insets = {left = 3, right = 3, top = 3, bottom = 3}})
    SRSummaryTileFrame:SetBackdropColor(0.18,0.27,0.5)
    SRSummaryTileFrame:SetBackdropBorderColor(0.6, 0.6, 0.6)
    SRSummaryTileFrame:SetPoint("TOP", SRLogTileFrame, "BOTTOM", 0, 8)
    SRSummaryTileFrame:SetFrameLevel(SRBaseFrame:GetFrameLevel()+1)
    parentFrame = SRAddonSummaryTileFrame;

    local buttonName = "SummaryOpenButton";
    SRCreateChildButton(buttonName, parentFrame, SRSummaryOpenButton_OnClick)
    buttons["SRAddon"..buttonName]:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    buttons["SRAddon"..buttonName]:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    buttons["SRAddon"..buttonName]:SetPoint("LEFT", parentFrame, "LEFT", 8, 0)

    local buttonName = "SummaryCloseButton";
    SRCreateChildButton(buttonName, parentFrame, SRSummaryCloseButton_OnClick)
    buttons["SRAddon"..buttonName]:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    buttons["SRAddon"..buttonName]:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
    buttons["SRAddon"..buttonName]:SetPoint("LEFT", parentFrame, "LEFT", 8, 0)

    -- <NormalTexture file="Interface\Buttons\UI-SpellbookIcon-NextPage-Up"/>
    -- <PushedTexture file="Interface\Buttons\UI-SpellbookIcon-NextPage-Down"/>

    --Create a button that begins an aoe farming session log
    SRAddonAoEBeginButton = CreateFrame("Button", "SRAddonFrameAoEBeginButton", SRAddonLogTileFrame,"UIPanelButtonTemplate")
    SRAddonFrameAoEBeginButton:SetPoint("CENTER", SRAddonLogTileFrame, "CENTER", 0, 0)
    SRAddonFrameAoEBeginButton:SetFrameStrata("DIALOG")
    SRAddonFrameAoEBeginButton:SetScript("OnClick",AoEBeginButton_OnClick)
    SRAddonFrameAoEBeginButton:SetText("Begin session")
    local width = SRAddonFrameAoEBeginButton:GetTextWidth();
    local height = SRAddonFrameAoEBeginButton:GetTextHeight();
    SRAddonFrameAoEBeginButton:SetWidth(width+16);
    SRAddonFrameAoEBeginButton:SetHeight(height+8);

    --Button to end the aoe farming session
    SRAddonAoEEndButton = CreateFrame("Button", "SRAddonFrameAoEEndButton", SRAddonLogTileFrame,"UIPanelButtonTemplate")
    SRAddonFrameAoEEndButton:SetPoint("CENTER", SRAddonLogTileFrame, "CENTER", 0, 0)
    SRAddonFrameAoEEndButton:SetFrameStrata("DIALOG")
    SRAddonFrameAoEEndButton:SetScript("OnClick",AoEEndButton_OnClick)
    SRAddonFrameAoEEndButton:SetText("End session")
    SRAddonFrameAoEEndButton:SetWidth(width+16);
    SRAddonFrameAoEEndButton:SetHeight(height+8);

    --[[
    --Create drop down menu
    local LevelSelect = CreateFrame("Frame", "LevelSelectDropDownMenu", SRAddonFrame, "UIDropDownMenuTemplate")
    LevelSelect:SetFrameStrata("DIALOG")
    LevelSelect:SetPoint("TOP",SRAddonFrame, "TOP", 0, 0)
    LevelSelect:SetScript("OnShow", LevelSelect_OnShow)
    UIDropDownMenu_Initialize(evelSelectDropDownMenu, LevelSelect_Init);
    UIDropDownMenu_SetWidth(75, LevelSelectDropDownMenu)
    ]]--

    --Creates text area
    --SRBaseFrame:CreateFontString("Option1TextFontString","DIALOG","GameFontNormal")
    --Option1TextFontString:SetPoint("TOP", SRAddonBaseFrame, "TOP", 0, -10)
    --Option1TextFontString:SetText("Speed Runners' Addon")

    --Hide all frames
    HideFrames()
    SRBaseFrameRegisterVisibility()
end

function InitVars()
    buttons = {};
    frames = {};
    visibility = {};
    beginBool = true;
    endBool = false;
end

function SRCreateChildButton(buttonName, parentFrame, OnClickFunction)
    local longName = "SRAddon"..buttonName;
    buttons[longName] = CreateFrame("Button", longName, parentFrame,"UIPanelCloseButton")
    buttons[longName]:SetFrameLevel(parentFrame:GetFrameLevel()+1)
    buttons[longName]:SetScript("OnClick", OnClickFunction)
end

function SRBaseFrameRegisterVisibility()
    for i, childFrame in {this:GetChildren()} do
        SRRegisterVisibility(childFrame)
    end
    visibility[this:GetName()] = this:IsVisible();
end

function SRRegisterVisibility(frame)
    for i, childFrame in {frame:GetChildren()} do
        SRRegisterVisibility(childFrame)
    end
    if ( frame:IsShown()) then
        visibility[frame:GetName()] = frame:IsShown();
    else
        visibility[frame:GetName()] = 0;
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
    beginBool = not beginBool;
    endBool = not endBool;
    SRAddonAoEBeginButton:Hide()
    SRAddonAoEEndButton:Show()
end

function AoEEndButton_OnClick()
    PlaySound("GAMEGENERICBUTTONPRESS")
    ChatFrame1:AddMessage("Ending session")
    beginBool = not beginBool;
    endBool = not endBool;
    SRAddonAoEEndButton:Hide()
    SRAddonAoEBeginButton:Show()
end

function ShowFrames()
    SRAddonBaseFrame:Show()
    SRAddonGuideCloseButton:Hide()
    SRAddonLogCloseButton:Hide()
    SRAddonSummaryCloseButton:Hide()
    if ( beginBool ) then
        SRAddonFrameAoEEndButton:Hide()
    elseif ( endBool ) then
        SRAddonFrameAoEBeginButton:Hide()
    end
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
