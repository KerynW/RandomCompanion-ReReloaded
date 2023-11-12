RandomCompanionOptions = {};

local function debugmsg(msg, debuglevel)
	if debuglevel == nil then
		debuglevel = 1;
	end
	if tonumber(debuglevel) then
		local debuglevel = tonumber(debuglevel);
	else	
		local debuglevel = 1;
	end
	if RandomCompanion_Settings.DEBUG and (debuglevel >= tonumber(RandomCompanion_Settings.DEBUGLevel)) then
		DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion Debug[" .. debuglevel .. "]: " .. msg);
	end
end

function RandomCompanionOptions.Initialize()
	if RandomCompanionOptions.Initialized ~= true then
		debugmsg("Initializing RandomCompanionOptions", 10);
		
		--Set up the weight slider interface
		RandomCompanionOptions.WeightSlider = CreateFrame("Slider", nil, CollectionsJournal, "OptionsSliderTemplate");
		RandomCompanionOptions.WeightSlider:SetWidth(100);
		RandomCompanionOptions.WeightSlider:SetHeight(20);
		RandomCompanionOptions.WeightSlider:SetOrientation("HORIZONTAL");
		RandomCompanionOptions.WeightSlider:SetPoint("BOTTOM", CollectionsJournal, "BOTTOM", -30, 8);
		RandomCompanionOptions.WeightSlider:SetMinMaxValues(0, 50);
		RandomCompanionOptions.WeightSlider.tooltipText = "RandomCompanion Weight\n\n|cFFFFFFFFSet the value higher to make RandomCompanion use this companion more often.";
		RandomCompanionOptions.WeightSlider:SetValueStep(1);
		RandomCompanionOptions.WeightSlider:SetObeyStepOnDrag(true);
		RandomCompanionOptions.WeightSlider:EnableMouseWheel(true);
		RandomCompanionOptions.WeightSlider:Show();

		--Hide stock "Low/High" labels
		RandomCompanionOptions.WeightSlider.Low:Hide();
		RandomCompanionOptions.WeightSlider.High:Hide();
		
		local text = RandomCompanionOptions.WeightSlider:CreateFontString(nil, "BACKGROUND");
		text:SetFontObject("GameFontHighlightSmall");
		text:SetPoint("LEFT", RandomCompanionOptions.WeightSlider, "RIGHT", 10, 0);
		RandomCompanionOptions.WeightSlider.valText = text;
		
		RandomCompanionOptions.WeightSlider:SetScript("OnMouseWheel", function (self, arg1)
			local step = self:GetValueStep() * arg1
			local value = self:GetValue()
			local minVal, maxVal = self:GetMinMaxValues()
		
			if step > 0 then
				self:SetValue(min(value+step, maxVal))
			else
				self:SetValue(max(value+step, minVal))
			end
		end);
		
		RandomCompanionOptions.WeightSlider:SetScript("OnValueChanged", function(self, value)
			local companionID = RandomCompanionOptions.GetSelectedCompanionID();
			
			if (companionID ~= nil) then
				value = RandomCompanionOptions.WeightSlider:GetValue();
				if (value == 0) then
					RandomCompanionOptions.WeightSlider.valText:SetText("Disabled");
				else
					RandomCompanionOptions.WeightSlider.valText:SetText(value);
				end
				RandomCompanion.SetWeight(companionID, value);
				
				if MountJournal:IsVisible() then
    				RC_REQUIRE_LOAD_MOUNTS = true;
    			end
			end
		end);

		--Add a checkbox for flying mounts to be summoned in no fly zones
		RandomCompanionOptions.FlyingOnGroundCheckbox = CreateFrame("CheckButton", nil, MountJournal, "InterfaceOptionsCheckButtonTemplate");
		RandomCompanionOptions.FlyingOnGroundCheckbox = CreateFrame("CheckButton", nil, MountJournal, "InterfaceOptionsCheckButtonTemplate");
		RandomCompanionOptions.FlyingOnGroundCheckbox.Text:SetText("Use in no-fly zones.")
		RandomCompanionOptions.FlyingOnGroundCheckbox:SetPoint("BOTTOMRIGHT", MountJournal, "BOTTOMRIGHT", -RandomCompanionOptions.FlyingOnGroundCheckbox.Text:GetWidth()-15, 1);
		RandomCompanionOptions.FlyingOnGroundCheckbox:SetScript("OnClick", function ()
			local companionID = RandomCompanionOptions.GetSelectedCompanionID();
			if (companionID ~= nil) then
				value = RandomCompanionOptions.FlyingOnGroundCheckbox:GetChecked();
				RandomCompanion.SetFlyingOnGround(companionID, value);
				RC_REQUIRE_LOAD_MOUNTS = true;
			end
		end);
		
		--Set up the Interface Options screen
		local RandomCompanionOptionsFrame = CreateFrame("FRAME", "RandomCompanionOptions");
		RandomCompanionOptionsFrame.name = GetAddOnMetadata("RandomCompanion", "Title");
		RandomCompanionOptionsFrame.default = function (self) RandomCompanionOptions_ResetConfig() end;
		RandomCompanionOptionsFrame.refresh = function (self) RandomCompanionOptions_RefreshConfig() end;
		InterfaceOptions_AddCategory(RandomCompanionOptionsFrame);
		
		local RandomCompanionOptionsHeader = RandomCompanionOptionsFrame:CreateFontString(nil, "ARTWORK");
		RandomCompanionOptionsHeader:SetFontObject(GameFontNormalLarge);
		RandomCompanionOptionsHeader:SetPoint("TOPLEFT", 16, -16);
		RandomCompanionOptionsHeader:SetText(GetAddOnMetadata("RandomCompanion", "Title") .. " " .. GetAddOnMetadata("RandomCompanion", "Version"));
		
		RandomCompanionOptionsCB_AccountWideWeights = CreateFrame("CheckButton", "RandomCompanionOptionsCB_AccountWideWeights", RandomCompanionOptionsFrame, "SettingsCheckBoxControlTemplate");
		RandomCompanionOptionsCB_AccountWideWeights:SetPoint("TOPLEFT", RandomCompanionOptionsHeader, "BOTTOMLEFT", 2, 0);
		RandomCompanionOptionsCB_AccountWideWeights:SetScript("OnClick", function(self)
			RandomCompanion_Settings.AccountWideWeights = (not RandomCompanion_Settings.AccountWideWeights);
			RC_REQUIRE_RELOAD = true;
			end);
		RandomCompanionOptionsCB_AccountWideWeightsText:SetText(L["Account-Wide mount and pet weights"]);
		RandomCompanionOptionsCB_AccountWideWeights:SetChecked(RandomCompanion_Settings.AccountWideWeights);
		
		RandomCompanionOptionsCB_AutoRecall = CreateFrame("CheckButton", "RandomCompanionOptionsCB_AutoRecall", RandomCompanionOptionsFrame, "SettingsCheckBoxControlTemplate");
		RandomCompanionOptionsCB_AutoRecall:SetPoint("TOPLEFT", RandomCompanionOptionsCB_AccountWideWeights, "BOTTOMLEFT", 0, -2);
		RandomCompanionOptionsCB_AutoRecall:SetScript("OnClick", function(self)
			RandomCompanion_Settings.AutoRecall = (not RandomCompanion_Settings.AutoRecall);
			RandomCompanion_Settings.RandomRecall = false;
			RandomCompanionOptionsCB_RandomRecall:SetChecked(false);
			RandomCompanion.ConfigurePetTick()
			end);
		RandomCompanionOptionsCB_AutoRecallText:SetText("Auto-recall vanity pets");
		RandomCompanionOptionsCB_AutoRecall:SetChecked(RandomCompanion_Settings.AutoRecall);
		
		RandomCompanionOptionsCB_RandomRecall = CreateFrame("CheckButton", "RandomCompanionOptionsCB_RandomRecall", RandomCompanionOptionsFrame, "SettingsCheckBoxControlTemplate");
		RandomCompanionOptionsCB_RandomRecall:SetPoint("TOPLEFT", RandomCompanionOptionsCB_AutoRecall, "BOTTOMLEFT", 0, -2);
		RandomCompanionOptionsCB_RandomRecall:SetScript("OnClick", function(self)
			RandomCompanion_Settings.RandomRecall = (not RandomCompanion_Settings.RandomRecall);
			RandomCompanion_Settings.AutoRecall = false;
			RandomCompanionOptionsCB_AutoRecall:SetChecked(false);
			RandomCompanion.ConfigurePetTick()
			end);
		RandomCompanionOptionsCB_RandomRecallText:SetText("Auto-recall a random vanity pet");
		RandomCompanionOptionsCB_RandomRecall:SetChecked(RandomCompanion_Settings.RandomRecall);
		
		RandomCompanionOptionsCB_AutoDismiss = CreateFrame("CheckButton", "RandomCompanionOptionsCB_AutoDismiss", RandomCompanionOptionsFrame, "SettingsCheckBoxControlTemplate");
		RandomCompanionOptionsCB_AutoDismiss:SetPoint("TOPLEFT", RandomCompanionOptionsCB_RandomRecall, "BOTTOMLEFT", 0, -2);
		RandomCompanionOptionsCB_AutoDismiss:SetScript("OnClick", function(self)
			RandomCompanion_Settings.AutoDismiss = (not RandomCompanion_Settings.AutoDismiss);
			RandomCompanion.ConfigurePetTick()
			end);
		RandomCompanionOptionsCB_AutoDismissText:SetText("Auto-dismiss vanity pets when hiding during PVP");
		RandomCompanionOptionsCB_AutoDismiss:SetChecked(RandomCompanion_Settings.AutoDismiss);
		
		RandomCompanionOptionsCB_RaidDismiss = CreateFrame("CheckButton", "RandomCompanionOptionsCB_RaidDismiss", RandomCompanionOptionsFrame, "SettingsCheckBoxControlTemplate");
		RandomCompanionOptionsCB_RaidDismiss:SetPoint("TOPLEFT", RandomCompanionOptionsCB_AutoDismiss, "BOTTOMLEFT", 0, -2);
		RandomCompanionOptionsCB_RaidDismiss:SetScript("OnClick", function(self)
			RandomCompanion_Settings.RaidDismiss = (not RandomCompanion_Settings.RaidDismiss);
			RandomCompanion.ConfigurePetTick()
			end);
		RandomCompanionOptionsCB_RaidDismissText:SetText("Auto-dismiss vanity pets when in a raid");
		RandomCompanionOptionsCB_RaidDismiss:SetChecked(RandomCompanion_Settings.RaidDismiss);
		
		RandomCompanionOptionsCB_AllFlyingOnGround = CreateFrame("CheckButton", "RandomCompanionOptionsCB_AllFlyingOnGround", RandomCompanionOptionsFrame, "SettingsCheckBoxControlTemplate");
		RandomCompanionOptionsCB_AllFlyingOnGround:SetPoint("TOPLEFT", RandomCompanionOptionsCB_RaidDismiss, "BOTTOMLEFT", 0, -2);
		RandomCompanionOptionsCB_AllFlyingOnGround:SetScript("OnClick", function(self)
			RandomCompanion_Settings.AllFlyingOnGround = (not RandomCompanion_Settings.AllFlyingOnGround);
			RC_REQUIRE_LOAD_MOUNTS = true;
			end);
		RandomCompanionOptionsCB_AllFlyingOnGroundText:SetText("Use all flying mounts in ground areas");
		RandomCompanionOptionsCB_AllFlyingOnGround:SetChecked(RandomCompanion_Settings.AllFlyingOnGround);
		
		RandomCompanionOptionsCB_RandomChange = CreateFrame("CheckButton", "RandomCompanionOptionsCB_RandomChange", RandomCompanionOptionsFrame, "SettingsCheckBoxControlTemplate");
		RandomCompanionOptionsCB_RandomChange:SetPoint("TOPLEFT", RandomCompanionOptionsCB_AllFlyingOnGround, "BOTTOMLEFT", 0, -2);
		RandomCompanionOptionsCB_RandomChange:SetScript("OnClick", function(self)
				RandomCompanion_Settings.RandomChange = (not RandomCompanion_Settings.RandomChange);
				RandomCompanion.ConfigurePetTick()
				if RandomCompanion_Settings.RandomChange then
					RandomCompanionOptions.RandomChangeSlider:SetAlpha(1);
				else
					RandomCompanionOptions.RandomChangeSlider:SetAlpha(0.3);
				end
			end);
		RandomCompanionOptionsCB_RandomChangeText:SetText("Randomly change vanity pets");
		RandomCompanionOptionsCB_RandomChange:SetChecked(RandomCompanion_Settings.RandomChange);
		
		RandomCompanionOptions.RandomChangeSlider = CreateFrame("Slider", "RandomCompanionOptionsSlider_RandomChange", RandomCompanionOptionsFrame, "OptionsSliderTemplate");
		RandomCompanionOptions.RandomChangeSlider:SetWidth(100);
		RandomCompanionOptions.RandomChangeSlider:SetHeight(20);
		RandomCompanionOptions.RandomChangeSlider:SetOrientation("HORIZONTAL");
		RandomCompanionOptions.RandomChangeSlider:SetPoint("TOPLEFT", RandomCompanionOptionsCB_RandomChange, "BOTTOMLEFT", 27, -7);
		RandomCompanionOptions.RandomChangeSlider:SetMinMaxValues(1, 60);
		RandomCompanionOptions.RandomChangeSlider:SetValueStep(1);
		RandomCompanionOptions.RandomChangeSlider:SetObeyStepOnDrag(true);
		RandomCompanionOptions.RandomChangeSlider:EnableMouseWheel(true);
		RandomCompanionOptions.RandomChangeSlider:Show();
		
		RandomCompanionOptionsCB_Cloning = CreateFrame("CheckButton", "RandomCompanionOptionsCB_Cloning", RandomCompanionOptionsFrame, "SettingsCheckBoxControlTemplate");
		RandomCompanionOptionsCB_Cloning:SetPoint("TOPLEFT", RandomCompanionOptions.RandomChangeSlider, "BOTTOMLEFT", -27, -7);
		RandomCompanionOptionsCB_Cloning:SetScript("OnClick", function(self)
			RandomCompanion_Settings.Cloning = (not RandomCompanion_Settings.Cloning);
			end);
		RandomCompanionOptionsCB_CloningText:SetText("Clone pets and mounts");
		RandomCompanionOptionsCB_Cloning:SetChecked(RandomCompanion_Settings.Cloning);
		
		local text = RandomCompanionOptions.RandomChangeSlider:CreateFontString(nil, "BACKGROUND");
		text:SetFontObject("GameFontNormal");
		text:SetPoint("LEFT", RandomCompanionOptions.RandomChangeSlider, "TOPLEFT", 0, 3);
		RandomCompanionOptions.RandomChangeSlider.valText = text;
		
		if RandomCompanion_Settings.RandomChange then
			RandomCompanionOptions.RandomChangeSlider:SetAlpha(1);
		else
			RandomCompanionOptions.RandomChangeSlider:SetAlpha(0.3);
		end
		
		RandomCompanionOptions.RandomChangeSlider:SetScript("OnMouseWheel", function (self, arg1)
			local step = self:GetValueStep() * arg1
			local value = self:GetValue()
			local minVal, maxVal = self:GetMinMaxValues()
		
			if step > 0 then
				self:SetValue(min(value+step, maxVal))
			else
				self:SetValue(max(value+step, minVal))
			end
		end);
		
		RandomCompanionOptions.RandomChangeSlider:SetScript("OnValueChanged", function(self, value)
			value = RandomCompanionOptions.RandomChangeSlider:GetValue();
			if (value == 1) then
				RandomCompanionOptions.RandomChangeSlider.valText:SetText("Change vanity pet every " .. value .. " minute");
			else
				RandomCompanionOptions.RandomChangeSlider.valText:SetText("Change vanity pet every " .. value .. " minutes");
			end
			RandomCompanion_Settings.RandomChangeTime = value;
		end);
		
		if (RandomCompanion_Settings.RandomChangeTime == 1) then
			RandomCompanionOptions.RandomChangeSlider.valText:SetText("Change vanity pet every " .. RandomCompanion_Settings.RandomChangeTime .. " minute");
		else
			RandomCompanionOptions.RandomChangeSlider.valText:SetText("Change vanity pet every " .. RandomCompanion_Settings.RandomChangeTime .. " minutes");
		end
		RandomCompanionOptions.RandomChangeSlider:SetValue(RandomCompanion_Settings.RandomChangeTime);
		
		RandomCompanionOptions.Initialized = true;
	end
end

function RandomCompanionOptions.GetSelectedCompanionID()
    local companionID;
    local isFlyingMount = false;
    local panel = PanelTemplates_GetSelectedTab(CollectionsJournal); --1 for mounts, 2 for pets
    if panel == 1 then
		if ( MountJournal.selectedMountID ) then
			local creatureName, spellID = C_MountJournal.GetMountInfoByID(MountJournal.selectedMountID);
			local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(MountJournal.selectedMountID);
			companionID = 'mount.' .. creatureName .. '.' .. spellID;
			if mountType == RC_MOUNTTYPE_FLYING or mountType == RC_MOUNTTYPE_FLYINGCLOUD then
				isFlyingMount = true;
			end
		end
    else
        local petID = PetJournalPetCard.petID;
        if petID ~= nil then
            local speciesID, customName, level, xp, maxXp, displayID, discard, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique = C_PetJournal.GetPetInfoByPetID(petID);
            companionID = "pet." .. name .. "." .. speciesID .. "." .. (customName and customName or name)
        end
    end
    
    return companionID, isFlyingMount;
end

function RandomCompanionOptions.UpdateSliders(self, elapsedTime)
    local companionID, isFlyingMount = RandomCompanionOptions.GetSelectedCompanionID();

    if companionID then
        RandomCompanionOptions.WeightSlider:Show();
    else
        RandomCompanionOptions.WeightSlider:Hide();
    end

    if isFlyingMount then
    	RandomCompanionOptions.FlyingOnGroundCheckbox:Show();
    else
    	RandomCompanionOptions.FlyingOnGroundCheckbox:Hide();
    end
    
	if companionID ~= nil and companionID ~= RandomCompanionOptions.LastSelected then
        debugmsg("companionID: " .. companionID, 5);
		debugmsg("Updating Weight slider", 1);
		RandomCompanionOptions.LastSelected = companionID;
		RandomCompanionOptions.WeightSlider:SetValue(RandomCompanion.GetWeight(companionID));
		if isFlyingMount then
			RandomCompanionOptions.FlyingOnGroundCheckbox:SetChecked(RandomCompanion.GetFlyingOnGround(companionID));
		end
	end
end

function RandomCompanionOptions.Event(self, event, ...)
	if event == "PLAYER_LOGIN" then
		if ( not CollectionsJournal ) then
			UIParentLoadAddOn("Blizzard_Collections");
		end
		PetJournal:SetScript("OnUpdate", RandomCompanionOptions.UpdateSliders);
		MountJournal:SetScript("OnUpdate", RandomCompanionOptions.UpdateSliders);
	end
	if event == "PLAYER_ENTERING_WORLD" then
		RandomCompanionOptions.Initialize();
	end
end

RandomCompanionOptions.EventFrame = CreateFrame("Frame", "RandomCompanionOptionsFrame");
RandomCompanionOptions.EventFrame:SetScript("OnEvent", RandomCompanionOptions.Event);
RandomCompanionOptions.EventFrame:RegisterEvent("PLAYER_LOGIN");
RandomCompanionOptions.EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");