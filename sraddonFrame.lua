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

    textfield = CreateFrame("Frame")
    SRAddonFrame.CloseButton = CreateFrame("Button", "SRAddonCloseButton", SRAddonFrame,"UIPanelCloseButton")
    SRAddonFrame.CloseButton:SetPoint("TOPRIGHT", SRAddonFrame, "TOPRIGHT", 8, 8)
    SRAddonCloseButton:SetScript("OnClick",HideFrames)

    --Create drop down menu
    local LevelSelect = CreateFrame("Frame", "LevelSelectDropDownMenu", UIParent, "UIDropDownMenuTemplate")
    LevelSelect:SetFrameStrata("DIALOG")
    LevelSelect:SetPoint("TOPLEFT", SRAddonFrame, "TOPLEFT", 0, 0)
    LevelSelect:SetScript("OnShow", LevelSelect_OnShow)
    UIDropDownMenu_Initialize(evelSelectDropDownMenu, LevelSelect_Init);
    UIDropDownMenu_SetWidth(75, LevelSelectDropDownMenu)
    LevelSelect:SetParent(SRAddonFrame)

    --Creates text area
    SRAddonFrame:CreateFontString("Option1TextFontString","DIALOG","GameFontNormal")
    Option1TextFontString:SetPoint("TOPLEFT", SRAddonFrame, "TOPLEFT", 10, -35)
    Option1TextFontString:SetText("AoE mode:")

    --Hide all frames
    HideFrames()
end

function ShowFrames()
    SRAddonFrame:Show()
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

