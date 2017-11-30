--------------------------------------
--   Generating the AddOn's frame   --
--------------------------------------

function InitFrame()
    SRAddonFrame = CreateFrame("Frame", "SRAddonFrame")
    SRAddonFrame:SetHeight(400)
    SRAddonFrame:SetWidth(200)
    SRAddonFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",tile = true,tileSize = 16,insets = {left = -1.5, right = -1.5, top = -1.5, bottom = -1.5}})
    SRAddonFrame:SetBackdropColor(0.18,0.27,0.5)
    SRAddonFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    SRAddonFrame:SetFrameStrata("LOW")
    SRAddonFrame:EnableMouse(1)
    SRAddonFrame:SetMovable(1)
    SRAddonFrame:RegisterForDrag("LeftButton")
    SRAddonFrame:SetScript("OnDragStart", StartMoving)
    SRAddonFrame:SetScript("OnDragStop", StopMovingOrSizing)

    SRAddonFrame.CloseButton = CreateFrame("Button", "SRAddonCloseButton", SRAddonFrame,"UIPanelCloseButton")
    SRAddonFrame.CloseButton:SetPoint("TOPRIGHT", SRAddonFrame, "TOPRIGHT", 8, 8)
    SRAddonCloseButton:SetScript("OnClick",HideFrames)

    --Create a button that begins an aoe farming session log
    SRAddonAoEBeginButton = CreateFrame("Button", "SRAddonFrameAoEBeginButton", SRAddonFrame,"UIPanelButtonTemplate")
    SRAddonFrameAoEBeginButton:SetPoint("CENTER", SRAddonFrame, "CENTER", 0, 0)
    SRAddonFrameAoEBeginButton:SetFrameStrata("DIALOG")
    SRAddonFrameAoEBeginButton:SetScript("OnClick",AoEBeginButton_OnClick)
    SRAddonFrameAoEBeginButton:SetText("Begin session")
    local width = SRAddonFrameAoEBeginButton:GetTextWidth();
    local height = SRAddonFrameAoEBeginButton:GetTextHeight();
    SRAddonFrameAoEBeginButton:SetWidth(width+16);
    SRAddonFrameAoEBeginButton:SetHeight(height+8);

    --Button to end the aoe farming session
    SRAddonAoEEndButton = CreateFrame("Button", "SRAddonFrameAoEEndButton", SRAddonFrame,"UIPanelButtonTemplate")
    SRAddonFrameAoEEndButton:SetPoint("CENTER", SRAddonFrame, "CENTER", 0, 0)
    SRAddonFrameAoEEndButton:SetFrameStrata("DIALOG")
    SRAddonFrameAoEEndButton:SetScript("OnClick",AoEEndButton_OnClick)
    SRAddonFrameAoEEndButton:SetText("End session")
    SRAddonFrameAoEEndButton:SetWidth(width+16);
    SRAddonFrameAoEEndButton:SetHeight(height+8);

    --Create drop down menu
    local LevelSelect = CreateFrame("Frame", "LevelSelectDropDownMenu", SRAddonFrame, "UIDropDownMenuTemplate")
    LevelSelect:SetFrameStrata("DIALOG")
    LevelSelect:SetPoint("TOP",SRAddonFrame, "TOP", 0, 0)
    LevelSelect:SetScript("OnShow", LevelSelect_OnShow)
    UIDropDownMenu_Initialize(evelSelectDropDownMenu, LevelSelect_Init);
    UIDropDownMenu_SetWidth(75, LevelSelectDropDownMenu)

    --Creates text area
    SRAddonFrame:CreateFontString("Option1TextFontString","DIALOG","GameFontNormal")
    Option1TextFontString:SetPoint("TOPLEFT", SRAddonFrame, "TOPLEFT", 10, -85)
    Option1TextFontString:SetText("PLACEHOLDER")

    --Hide all frames
    HideFrames()
end

local beginBool = true;
local endBool = false;

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
    SRAddonFrame:Show()
    if ( beginBool ) then
        SRAddonFrameAoEEndButton:Hide()
    elseif ( endBool ) then
        SRAddonFrameAoEBeginButton:Hide()
    end
end

function HideFrames()
    SRAddonFrame:Hide()
end

function StartMoving()
    this:StartMoving()
end

function StopMovingOrSizing()
    this:StopMovingOrSizing()
end

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

function AddOptionButton(text, optionVal)

end

