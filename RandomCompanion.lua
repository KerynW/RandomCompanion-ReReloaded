
local VERSION = GetAddOnMetadata("RandomCompanion", "Version");

RandomCompanion = {
    mounts = {};
    pets = {};
};

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
        DEFAULT_CHAT_FRAME:AddMessage("RC[" .. debuglevel .. "]: " .. msg);
    end
end

local function OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        RandomCompanion.EventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        RandomCompanion.Initialize(not RandomCompanion_Settings.Quiet);
    elseif event == "MOUNT_JOURNAL_USABILITY_CHANGED" or event == "NEW_MOUNT_ADDED" then
        RC_REQUIRE_LOAD_MOUNTS = true;
    elseif event == "NEW_PET_ADDED" or event == "PET_JOURNAL_LIST_UPDATE" or event == "PET_JOURNAL_PET_DELETED" then
        debugmsg("Reload required due to event: " .. event, 3);
        RC_REQUIRE_LOAD_PETS = true;
    else
        debugmsg("Unknown event triggered.", 10);
    end
end

function RandomCompanion.Initialize(showstatus)
    RC_REQUIRE_RELOAD = false;
    
    if not RandomCompanion_Settings then
        RandomCompanion_Settings = {};
    end
    
    if not RandomCompanion_Settings[GetRealmName()] then
        RandomCompanion_Settings[GetRealmName()] = {};
    end
    
    if not RandomCompanion_Settings[GetRealmName()][UnitName("player")] then
        RandomCompanion_Settings[GetRealmName()][UnitName("player")] = {};
    end
    
    if not RandomCompanion_Settings.DEBUG then
        RandomCompanion_Settings.DEBUG = false;
    end
    
    if RandomCompanion_Settings.DEBUGLevel == nil then
        RandomCompanion_Settings.DEBUGLevel = 1;
    end
    
    if RandomCompanion_Settings.AccountWideWeights == nil then
        RandomCompanion.AccountWideWeights = true;
    end
    
    if RandomCompanion_Settings.AutoRecall == nil then
        RandomCompanion_Settings.AutoRecall = false;
    end
    
    if RandomCompanion_Settings.AutoDismiss == nil then
        RandomCompanion_Settings.AutoDismiss = true;
    end
    
    if RandomCompanion_Settings.AllFlyingOnGround == nil then
        RandomCompanion_Settings.AllFlyingOnGround = false;
    end
    
    if RandomCompanion_Settings.RaidDismiss == nil then
        RandomCompanion_Settings.RaidDismiss = false;
    end
    
    if RandomCompanion_Settings.RandomRecall == nil then
        RandomCompanion_Settings.RandomRecall = true;
    end
    
    if RandomCompanion_Settings.RandomChange == nil then
        RandomCompanion_Settings.RandomChange = true;
    end
    
    if RandomCompanion_Settings.RandomChangeTime == nil then
        RandomCompanion_Settings.RandomChangeTime = 15;
    end
    
    if RandomCompanion_Settings.Cloning == nil then
        RandomCompanion_Settings.Cloning = true;
    end
    
    if not RandomCompanion_Settings.accountwide then
        RandomCompanion_Settings.accountwide = {};
    end
    
    if not RandomCompanion_Settings.accountwide.weights then
        RandomCompanion_Settings.accountwide.weights = {};
    end

    if not RandomCompanion_Settings.accountwide.FlyingOnGroundMounts then
        RandomCompanion_Settings.accountwide.FlyingOnGroundMounts = {};
    end
    
    if not RandomCompanion_Settings[GetRealmName()] then
        RandomCompanion_Settings[GetRealmName()] = {};
    end
    
    if not RandomCompanion_Settings[GetRealmName()][UnitName("player")] then
        RandomCompanion_Settings[GetRealmName()][UnitName("player")] = {};
    end
    
    if not RandomCompanion_Settings[GetRealmName()][UnitName("player")].weights then
        RandomCompanion_Settings[GetRealmName()][UnitName("player")].weights = {};
    end

    if not RandomCompanion_Settings[GetRealmName()][UnitName("player")].FlyingOnGroundMounts then
        RandomCompanion_Settings[GetRealmName()][UnitName("player")].FlyingOnGroundMounts = {};
    end
    
    if RandomCompanion_Settings.Quiet == nil then
        RandomCompanion_Settings.Quiet = false;
    end

    RandomCompanion.LoadMounts();
    RandomCompanion.LoadPets();
    
    RandomCompanion.ConfigurePetTick();
    
    if showstatus then
        RandomCompanion.Status();
    end
end

function RandomCompanion.LoadMounts()
    RC_REQUIRE_LOAD_MOUNTS = false;

    RandomCompanion.mounts = {
        ground = {};
        flying = {};
        flyingonground = {};
        passengerground = {};
        passengerflying = {};
        passengerflyingonground = {};
        aquatic = {};
        aquaticslow = {};
        vashjir = {};
        qiraji = {};
        lowlevel = {};
		advflying = {};

        bySpellID = {};
        all = {};
    };

    RandomCompanion.FlyingTrained = IsSpellKnown(RC_SPELLID_EXPERT_RIDING) or IsSpellKnown(RC_SPELLID_ARTISAN_RIDING) or IsSpellKnown(RC_SPELLID_MASTER_RIDING);
    RandomCompanion.BfAPathfinderCompleted = IsSpellKnown(RC_SPELLID_BFA_PATHFINDER);

    for index,mountID in pairs(C_MountJournal.GetMountIDs()) do
        local name, spellid, _, _, isUsable, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID);
        
        if name and isUsable and isCollected then
            
            local companionID = "mount." .. name .. "." .. spellid;
            
            local weight = RandomCompanion.GetWeight(companionID);
            
            local mountdata = {
                name = name;
                spellid = spellid;
                mountID = mountID;
                weight = weight;
            }

            RandomCompanion.mounts.bySpellID[spellid] = mountdata;
			table.insert(RandomCompanion.mounts.all, mountdata);

            --[[https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetMountInfoExtra
                230 for most ground mounts
                231 for  [Riding Turtle] and  [Sea Turtle]
                232 for  [Vashj'ir Seahorse] (was named Abyssal Seahorse prior to Warlords of Draenor)
                241 for Blue, Green, Red, and Yellow Qiraji Battle Tank (restricted to use inside Temple of Ahn'Qiraj)
                242 for Spectral mounts (hidden in the mount journal, used while dead in certain zones)
                247 for Red Flying Cloud
                248 for most flying mounts, including those that change capability based on riding skill
                284 for Chauffeured Mekgineer's Chopper and Chauffeured Mechano-Hog ("LowLevel")
				398 for Kuafon, which starts as ground-only and then learns to fly. Handled as flying
				402 for Advanced Flying (Dragonriding) mounts.
				407 for mounts that are both aquatic and flying ("Aquafly") including Aurelids, Ottuk Carrier, and Wavewhisker
				408 for very slow helicid mount useable by low levels ("Slowsnail")
				412 for Ottuks and other mounts that are both aquatic and ground mounts. ("Ottuk")
				424 for the other category of flying mounts  ("Drake")  These may be slated for advanced flying
				
            ]]

            local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID);
            local flyingOnGround = RandomCompanion.GetFlyingOnGround(companionID);
            local passenger = RC_MOUNT_IDS.passenger[spellid];

--			print("loading ".. companionID);
--			if name == RC_TEMPNAME then
--				print("located mount ".. mountType .. " " .. name);
--			end
            
			-- advanced flying (dragonriding) mounts
				
			if mountType == RC_MOUNTTYPE_ADVFLYING then 
				table.insert(RandomCompanion.mounts.advflying, mountdata);

            -- flying mounts
            elseif mountType == RC_MOUNTTYPE_FLYING or mountType == RC_MOUNTTYPE_FLYINGCLOUD or mountType == RC_MOUNTTYPE_DRAKE or mountType == RC_MOUNTTYPE_KUAFON or mountType == RC_MOUNTTYPE_AQUAFLY then
                -- flying passenger mounts
                if passenger then
                    if (flyingOnGround or RandomCompanion_Settings.AllFlyingOnGround) then
                        table.insert(RandomCompanion.mounts.passengerflyingonground, mountdata);
                    else
                        table.insert(RandomCompanion.mounts.passengerflying, mountdata);
                    end
                -- flying mounts
                else
                    if (flyingOnGround or RandomCompanion_Settings.AllFlyingOnGround) then
                        table.insert(RandomCompanion.mounts.flyingonground, mountdata);
                    else
                        table.insert(RandomCompanion.mounts.flying, mountdata);
						if mountType == RC_MOUNTTYPE_AQUAFLY then
	                        table.insert(RandomCompanion.mounts.aquatic, mountdata);
						end
                    end
                end

            -- slow aquatic (sea turtle)
            elseif RC_MOUNT_IDS.aquaticslow[spellid] then
                table.insert(RandomCompanion.mounts.aquaticslow, mountdata);

            -- aquatic mounts
            elseif mountType == RC_MOUNTTYPE_AQUATIC or mountType == RC_MOUNTTYPE_TURTLE then
                table.insert(RandomCompanion.mounts.aquatic, mountdata);

            -- Vashj'ir Seahorse
            elseif mountType == RC_MOUNTTYPE_VASHJIR then
                table.insert(RandomCompanion.mounts.vashjir, mountdata);

            -- Qiraji Battle Tanks
            elseif mountType == RC_MOUNTTYPE_QIRAJI then
                table.insert(RandomCompanion.mounts.qiraji, mountdata);

            -- Chauffeured heirloom mounts
            elseif mountType == RC_MOUNTTYPE_LOWLEVEL or mountType == RC_MOUNTTYPE_SLOWSNAIL then
                table.insert(RandomCompanion.mounts.lowlevel, mountdata);

            -- default: ground mounts
            else -- if mountType == RC_MOUNTTYPE_GROUND then
                -- passengerground
                if passenger then
                    table.insert(RandomCompanion.mounts.passengerground, mountdata);
                -- ground	
				else
                    table.insert(RandomCompanion.mounts.ground, mountdata);
					if mountType == RC_MOUNTTYPE_OTTUK then
                        table.insert(RandomCompanion.mounts.aquatic, mountdata);
					end
                end
            end
        end
    end
end

function RandomCompanion.LoadPets()
	RC_REQUIRE_LOAD_PETS = false;

	RandomCompanion.pets = {
        weighted = {};
        bySpeciesID = {}; -- for cloning
        byName = {}; -- for adding weights
        all = {};
    };

    C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, true);
    C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, false);
    C_PetJournal.SetAllPetTypesChecked(true);
    C_PetJournal.SetAllPetSourcesChecked(true);
    C_PetJournal.ClearSearchFilter();

    local numPets, numOwned = C_PetJournal.GetNumPets();
    
    for i = 1, numOwned do
        local petID, speciesID, isOwned, customName, _, _, _, name = C_PetJournal.GetPetInfoByIndex(i);
        local companionID = "pet." .. name .. "." .. speciesID .. "." .. (customName and customName or name)

        if not name then
            --This seems to happen when the companion is not in the cache
            RC_REQUIRE_LOAD_PETS = true;
            debugmsg(petID .. " petID critter has no name?", 1);
        end

        if isOwned then
        	if RC_DEFAULT_DISABLED_PET_SPECIESIDS[speciesID] then
            	if not RandomCompanion_Settings[GetRealmName()][UnitName("player")].weights[companionID] then --Set default weight
                    RandomCompanion_Settings[GetRealmName()][UnitName("player")].weights[companionID] = 0;
            	end
            
            	if not RandomCompanion_Settings.accountwide.weights[companionID] then --Set accountwide default weight
                    RandomCompanion_Settings.accountwide.weights[companionID] = 0;
            	end
            end

            local petdata = {
            	name = name;
                petID = petID;
                customName = customName;
                speciesID = speciesID;
            }

            table.insert(RandomCompanion.pets.all, petdata);

            -- perfer pet with custom name while cloning
            if not RandomCompanion.pets.bySpeciesID[speciesID] or RandomCompanion.pets.bySpeciesID[speciesID].customName == nil then
            	RandomCompanion.pets.bySpeciesID[speciesID] = petdata
            end

            local petName = customName and customName or name

            -- If two same species pet has same name, only count as 1 pet
            if RandomCompanion.pets.byName[petName] == nil then
                local weight = RandomCompanion.GetWeight(companionID);

                RandomCompanion.pets.byName[petName] = petdata
                
                if weight > 0 then
                    for counter = 1, weight do
                    	table.insert(RandomCompanion.pets.weighted, petdata)
                    end
                end
            end
        end
    end
end


function RandomCompanion.Status()
    local loadmessage = "";
    
    if #RandomCompanion.mounts.all > 0 then
        loadmessage = loadmessage .. "\rUsable Mounts: " .. #RandomCompanion.mounts.all;
    end

    if #RandomCompanion.pets.all > 0 then
        loadmessage = loadmessage .. "\rUsable Pets: " .. #RandomCompanion.pets.all .. " Total Weight: " .. #RandomCompanion.pets.weighted;
    end
 

 	loadmessage = loadmessage .. "\rAuto Pet Summon: " .. (RandomCompanion.PetTickHandle and "ON" or "OFF")

 	if RandomCompanion.LastCritterChange == nil then
        RandomCompanion.LastCritterChange = GetTime();
    end
 	local nextchange = RandomCompanion.LastCritterChange - (GetTime() - (RandomCompanion_Settings.RandomChangeTime * 60));
 	if RandomCompanion.PetTickHandle and nextchange > 0 then

 		loadmessage = loadmessage .. "\rNext Pet Change: " .. ((nextchange > 0) and (floor(nextchange / 60) .. ":" .. floor(nextchange % 60)) or "SOON");
 	end

    DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion status:" .. loadmessage);
end

local function AddToWeightedTable(t1, t2)
    for k,v in pairs(t2) do
        if v.weight and v.mountID then
            for i = 1, v.weight do
                table.insert(t1, v.mountID);
            end
        end
    end 
 
   return t1
end

function RandomCompanion.Mount(cmd)
    local targetUsableMountID;
    local playerInCombat = InCombatLockdown();
    local mountlist = {};

    if (cmd) then
        --Parse any macro conditionals such as [modifier:ctrl] or [combat]
        cmd = SecureCmdOptionParse(cmd);
    end



    -- no usable mount in combat, no use loading
    if not playerInCombat then
        if next(RandomCompanion.mounts.bySpellID) == nil  then
            RC_REQUIRE_LOAD_MOUNTS = true;
        end

        if RC_REQUIRE_LOAD_MOUNTS then
            RandomCompanion.LoadMounts();
        end

        if (not cmd or cmd == "") and RandomCompanion_Settings.Cloning then
            debugmsg("Checking for clone target", 3)
            targetUsableMountID = RandomCompanion.GetTargetUsableMountID();
        end
    end
    
    if IsMounted() then
        Dismount();
    elseif CanExitVehicle() then
        VehicleExit();
    elseif playerInCombat then
        -- TODO: Druid forms?
        UIErrorsFrame:AddMessage("You are in combat.", 1.0, 0.0, 0.0, 53, 5);
    elseif targetUsableMountID then
        C_MountJournal.SummonByID(targetUsableMountID);
    else
        local flyable = RandomCompanion.IsFlyable();
        mountlist = {};

		-- Advanced Flying Mounts
		if cmd == "advflying" then
            AddToWeightedTable(mountlist, RandomCompanion.mounts.advflying);
			
        -- Passenger mounts
        elseif cmd == "passenger" then
            AddToWeightedTable(mountlist, RandomCompanion.mounts.passengerflyingonground);
            if flyable then
                AddToWeightedTable(mountlist, RandomCompanion.mounts.passengerflying);
            end
            -- ground passenger mounts when in no fly area or in fly area but no flying passenger mounts
            if not flyable or #mountlist == 0 then
                AddToWeightedTable(mountlist, RandomCompanion.mounts.passengerground);
            end

        -- Flying mounts
        elseif cmd == "flying" then
            AddToWeightedTable(mountlist, RandomCompanion.mounts.flying);
            AddToWeightedTable(mountlist, RandomCompanion.mounts.flyingonground);
            AddToWeightedTable(mountlist, RandomCompanion.mounts.passengerflying);
            AddToWeightedTable(mountlist, RandomCompanion.mounts.passengerflyingonground);

        -- Ground mounts
        elseif cmd == "ground" then
            AddToWeightedTable(mountlist, RandomCompanion.mounts.ground);
            AddToWeightedTable(mountlist, RandomCompanion.mounts.passengerground);

        -- Aquatic mounts
        elseif IsSwimming() or IsSubmerged() or cmd == "aquatic" then
            if RandomCompanion.PlayerUnderMapID(RC_MAPID_VASHJIR) then
                AddToWeightedTable(mountlist, RandomCompanion.mounts.vashjir);
            end
            
            AddToWeightedTable(mountlist, RandomCompanion.mounts.aquatic);
            
            -- use slow aquatic mount only if no other available
            if #mountlist == 0 then
                AddToWeightedTable(mountlist, RandomCompanion.mounts.aquaticslow);
            end

        -- Qiraji Battle Tanks
        elseif #RandomCompanion.mounts.qiraji>0 then
            AddToWeightedTable(mountlist, RandomCompanion.mounts.qiraji);

        end

        -- Default mount command outside of water
        if #mountlist==0 then
            -- Flying mounts
            if flyable then
                AddToWeightedTable(mountlist, RandomCompanion.mounts.flying);
                AddToWeightedTable(mountlist, RandomCompanion.mounts.passengerflying);  
            end

            -- Flying on ground mounts used everywhere
            AddToWeightedTable(mountlist, RandomCompanion.mounts.flyingonground);
            AddToWeightedTable(mountlist, RandomCompanion.mounts.passengerflyingonground);

            -- In Nazjatar with Budding Deepcoral
            if C_Map.GetBestMapForUnit("player") == RC_MAPID_NAZJATAR and C_QuestLog.IsQuestFlaggedCompleted(RC_QUESTID_BUDDING_DEEPCORAL) then
                AddToWeightedTable(mountlist, RandomCompanion.mounts.aquatic);
            end

            -- Ground mounts when in no fly zone or no other mounts available
            if not flyable or #mountlist == 0 then
                AddToWeightedTable(mountlist, RandomCompanion.mounts.ground);
                AddToWeightedTable(mountlist, RandomCompanion.mounts.passengerground);
            end
        end

        -- No mounts usable, try low level mounts (Chauffeured)
        if #mountlist == 0 and #RandomCompanion.mounts.lowlevel > 0 then
            AddToWeightedTable(mountlist, RandomCompanion.mounts.lowlevel);
        end
        
        if #mountlist > 0 then
            C_MountJournal.SummonByID(mountlist[random(#mountlist)]);
        else
            UIErrorsFrame:AddMessage("No usable mounts.", 1.0, 0.0, 0.0, 53, 5);
        end
    end
end

local __continentID = {}

function RandomCompanion.IsFlyable()
    if not RandomCompanion.FlyingTrained then
        return false;
    end

    if GetRealZoneText() == RC_STRING_WINTERGRASP then
        for areaid = 1, GetNumWorldPVPAreas() do
            local pvpID, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(areaid);
            if localizedName == RC_STRING_WINTERGRASP then
                if isActive then
                    wg_inprogress = 1;
                else
                    wg_inprogress = 0;
                end
                break;
            end
        end
        
        debugmsg("Currently in Wintergrasp. In progress: " .. tonumber(wg_inprogress), 2);
        
        if IsFlyableArea() and wg_inprogress == 0 then
            return true;
        else
            return false;
        end
    end

    local mapID = C_Map.GetBestMapForUnit("player")
    if __continentID[mapID] == nil then
        local continentInfo = MapUtil.GetMapParentInfo(mapID, Enum.UIMapType.Continent, true)

        if continentInfo then 
            __continentID[mapID] = continentInfo.mapID;
        end
    end

    if IsFlyableArea() or __continentID[mapID] == RC_MAPID_DRAENOR or __continentID[mapID] == RC_MAPID_BROKEN_ISLES then
        -- No fly instances reporting can fly
        if RC_NOFLY_INSTANCE_IDS[(select(8,GetInstanceInfo()))] then
            return false;
        end

        -- Warfronts
        if C_Scenario.IsInScenario() then
            local scenarioType = select(10, C_Scenario.GetInfo())
            if scenarioType == LE_SCENARIO_TYPE_WARFRONT then
                return false
            end
        end 

        if __continentID[mapID] == RC_MAPID_ZANDALAR or __continentID[mapID] == RC_MAPID_KUL_TIRAS or mapID == RC_MAPID_NAZJATAR then
            return RandomCompanion.BfAPathfinderCompleted;
        end

        return true;
    else
        return false;
    end
end

function RandomCompanion.PlayerUnderMapID(mapID)
    local mapInfo = C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player"));

    while mapInfo do
        if mapInfo.mapID == mapID then
            return true;
        end
        mapInfo = C_Map.GetMapInfo(mapInfo.parentMapID);
    end

    return false;
end

function RandomCompanion.Pet()
    -- Uncomment the next few lines to force clearing the PetJournal filters before summoning pets. This will cause RandomCompanion to reload, and may cause a brief pause while this happens.
    --C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, true);
    --C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, false);
    --C_PetJournal.SetAllPetTypesChecked(true);
    --C_PetJournal.SetAllPetSourcesChecked(true);
    --C_PetJournal.ClearSearchFilter();

    --local numPets, numOwned = C_PetJournal.GetNumPets();
    
    if RC_REQUIRE_LOAD_PETS or (#RandomCompanion.pets.all == 0 and select(2, C_PetJournal.GetNumPets()) > 0) then
        --Re-initialize if one of the pet or mount names was not available in the initial load
        debugmsg("Reloading pet...", 2);
        RandomCompanion.LoadPets();
    end    
    
    if RandomCompanion_Settings.Cloning and UnitIsBattlePet("target") then

        local speciesID = UnitBattlePetSpeciesID("target")
        
        if RandomCompanion.pets.bySpeciesID[speciesID] then
            debugmsg("Found cloneable pet by species id " .. speciesID, 5);
            local clonetarget = RandomCompanion.pets.bySpeciesID[speciesID].petID;
            local currentPetID = C_PetJournal.GetSummonedPetGUID()

            C_PetJournal.SummonPetByGUID(clonetarget);
            -- if same pet, resummon again after gcd end
            if currentPetID and currentPetID == clonetarget then
                C_Timer.After(2, function() C_PetJournal.SummonPetByGUID(clonetarget); end)
            end
	    end        
    elseif #RandomCompanion.pets.weighted > 0 then
        local petdata = nil;
        
        petindex = random(#RandomCompanion.pets.weighted);
        
        if petindex ~= nil then

            -- Try 10 times to get a different pet than currently summoned
            local currentPetID = C_PetJournal.GetSummonedPetGUID()
            local attempts = 10
            while (currentPetID == RandomCompanion.pets.weighted[petindex].petID and attempts > 0) do
                petindex = random(#RandomCompanion.pets.weighted)
                attempts = attempts - 1
            end

            C_PetJournal.SummonPetByGUID(RandomCompanion.pets.weighted[petindex].petID);

            -- if same pet, resummon again after gcd end
            if currentPetID == RandomCompanion.pets.weighted[petindex].petID then
                C_Timer.After(2, function() C_PetJournal.SummonPetByGUID(RandomCompanion.pets.weighted[petindex].petID) end);
            end
            debugmsg("Summoning " .. RandomCompanion.pets.weighted[petindex].name .. ". petID is " .. RandomCompanion.pets.weighted[petindex].petID, 10);
        end
    else
        UIErrorsFrame:AddMessage("No pet to summon", 1.0, 0.0, 0.0, 53, 5);
    end

end

function RandomCompanion.SetWeight(companion, value)
    if not RandomCompanion_Settings then
        RandomCompanion_Settings = {};
    end  
    
    if RandomCompanion_Settings.AccountWideWeights then
    	if not RandomCompanion_Settings.accountwide then
	        RandomCompanion_Settings.accountwide = {};
	    end
	    
	    if not RandomCompanion_Settings.accountwide.weights then
	        RandomCompanion_Settings.accountwide.weights = {};
    	end

        RandomCompanion_Settings.accountwide.weights[companion] = value;
        debugmsg("RandomCompanion_Settings.accountwide.weights["..companion.."] = "..RandomCompanion_Settings.accountwide.weights[companion], 1);
    else
    	if not RandomCompanion_Settings[GetRealmName()] then
        RandomCompanion_Settings[GetRealmName()] = {};
	    end
	    
	    if not RandomCompanion_Settings[GetRealmName()][UnitName("player")] then
	        RandomCompanion_Settings[GetRealmName()][UnitName("player")] = {};
	    end
	    
	    if not RandomCompanion_Settings[GetRealmName()][UnitName("player")].weights then
	        RandomCompanion_Settings[GetRealmName()][UnitName("player")].weights = {};
	    end

        RandomCompanion_Settings[GetRealmName()][UnitName("player")].weights[companion] = value;
        debugmsg("RandomCompanion_Settings["..GetRealmName().."]["..UnitName("player").."].weights["..companion.."] = "..RandomCompanion_Settings[GetRealmName()][UnitName("player")].weights[companion], 1);
    end

    if string.find(companion, "mount.") == 1 then
    	RC_REQUIRE_LOAD_MOUNTS = true
    elseif string.find(companion, "pet.") == 1 then
    	RC_REQUIRE_LOAD_PETS = true
    else
    	print("RandomCompanion: Bad companionID ".. companionID)
    end

end

function RandomCompanion.GetWeight(companion)
    if RandomCompanion_Settings.AccountWideWeights then
        if RandomCompanion_Settings.accountwide.weights[companion] then
            return RandomCompanion_Settings.accountwide.weights[companion];
        else
            return 1;
        end
    else
        if RandomCompanion_Settings[GetRealmName()][UnitName("player")].weights[companion] then
            return RandomCompanion_Settings[GetRealmName()][UnitName("player")].weights[companion];
        else
            return 1;
        end
    end
end

function RandomCompanion.SetFlyingOnGround(companion, value)
    if RandomCompanion_Settings.AccountWideWeights then
        RandomCompanion_Settings.accountwide.FlyingOnGroundMounts[companion] = value;
    else
        RandomCompanion_Settings[GetRealmName()][UnitName("player")].FlyingOnGroundMounts[companion] = value;
    end
end

function RandomCompanion.GetFlyingOnGround(companion)
    if RandomCompanion_Settings.AccountWideWeights then
        if RandomCompanion_Settings.accountwide.FlyingOnGroundMounts[companion] then
            return RandomCompanion_Settings.accountwide.FlyingOnGroundMounts[companion];
        else
            return RC_MOUNT_IDS.flyingOnGround[tonumber(string.match(companion, "%.([0-9]+)$"))];
        end
    else
        if RandomCompanion_Settings[GetRealmName()][UnitName("player")].FlyingOnGroundMounts[companion] then
            return RandomCompanion_Settings[GetRealmName()][UnitName("player")].FlyingOnGroundMounts[companion];
        else
            return RC_MOUNT_IDS.flyingOnGround[tonumber(string.match(companion, "%.([0-9]+)$"))];
        end
    end
end

function RandomCompanion.Busy()
	local inInstance, instanceType = IsInInstance();

	if InCombatLockdown() or UnitIsDeadOrGhost("player") or UnitCastingInfo("player") or UnitChannelInfo("player") or SpellIsTargeting() or IsMounted() or IsFalling() or IsFlying() or IsStealthed() or GetNumLootItems()~= 0 or not HasFullControl() or UnitInVehicle("player") or 
        (instanceType == "raid" and RandomCompanion_Settings.RaidDismiss) or UnitIsAFK("player") or  C_PetBattles.IsInBattle() or (BarberShopFrame and not BarberShopFrame:IsVisible()) then
        	return true
    end

    local index = 1;

    local currentBuffName = UnitBuff("player", index);
    local hasBusyBuff = false;
    
    --Check to see if you're doing something that will break when recalling a critter
    while currentBuffName do
        if RC_BUSY_AURA[currentBuffName] then
            hasBusyBuff = true;
            break;
        end
        index = index + 1;
        currentBuffName = UnitBuff("player", index);
    end
    
    return hasBusyBuff;
end

function RandomCompanion.ConfigurePetTick()
	if (RandomCompanion_Settings.AutoRecall or RandomCompanion_Settings.RandomRecall or RandomCompanion_Settings.AutoDismiss or RandomCompanion_Settings.RaidDismiss or RandomCompanion_Settings.RandomChange) and RandomCompanion_Settings[GetRealmName()][UnitName("player")].ActiveCritter then
        RandomCompanion.StartPetTick()
    else
        RandomCompanion.StopPetTick()
    end
end

function RandomCompanion.StartPetTick()
	if not RandomCompanion.PetTickHandle then
		RandomCompanion.PetTickHandle = C_Timer.NewTicker(2, RandomCompanion.PetTick)
	end
end

function RandomCompanion.StopPetTick()
	if RandomCompanion.PetTickHandle then
		RandomCompanion.PetTickHandle:Cancel()
		RandomCompanion.PetTickHandle = nil
	end
end

function RandomCompanion.PetTick()
    if not ((RandomCompanion_Settings.AutoRecall or RandomCompanion_Settings.RandomRecall or RandomCompanion_Settings.AutoDismiss or RandomCompanion_Settings.RaidDismiss or RandomCompanion_Settings.RandomChange) and RandomCompanion_Settings[GetRealmName()][UnitName("player")].ActiveCritter) then
		RandomCompanion.StopPetTick()
    end
    
    if (RandomCompanion_Settings.AutoRecall or RandomCompanion_Settings.RandomRecall or RandomCompanion_Settings.RandomChange) and RandomCompanion_Settings[GetRealmName()][UnitName("player")].ActiveCritter then
        debugmsg("Checking to recall pets", 1);
        local active = C_PetJournal.GetSummonedPetGUID();
        
        if RandomCompanion.LastCritterChange == nil then
            RandomCompanion.LastCritterChange = GetTime();
        end
        
        if not active then
            if not RandomCompanion.Busy() then
                if RandomCompanion.NotBusyTime == nil then
                    --Start the timer to recall
                    debugmsg("Recalling critter in 5.5 seconds", 2);
                    RandomCompanion.NotBusyTime = GetTime();
                end
                if GetTime() > (RandomCompanion.NotBusyTime + 5.5) then 
                    --You haven't been busy for 5.5 seconds, so it should be safe to recall your critter
                    RandomCompanion.NotBusyTime = nil;
                    debugmsg("Recalling critter now", 4);
                    if RandomCompanion_Settings.RandomRecall or (RandomCompanion_Settings.RandomChange and RandomCompanion.LastCritterChange < (GetTime() - (RandomCompanion_Settings.RandomChangeTime * 60))) then
                        RandomCompanion.Pet();
                    else -- AutoRecall
                        C_PetJournal.SummonPetByGUID(RandomCompanion_Settings[GetRealmName()][UnitName("player")].ActiveCritter);
                        RandomCompanion.LastChangeTime = GetTime();
                    end
                end
            else
                RandomCompanion.NotBusyTime = nil;
                debugmsg("Not recalling critter because you are busy.", 2);
            end
        elseif RandomCompanion_Settings.RandomChange and RandomCompanion.LastCritterChange < (GetTime() - (RandomCompanion_Settings.RandomChangeTime * 60)) then
            if not RandomCompanion.Busy() then
                if RandomCompanion.NotBusyTime == nil then
                    --Start the timer to recall
                    debugmsg("Changing critter in 5.5 seconds", 2);
                    RandomCompanion.NotBusyTime = GetTime();
                end
                if GetTime() > (RandomCompanion.NotBusyTime + 5.5) then 
                    --You haven't been busy for 5.5 seconds, so it should be safe to recall your critter
                    RandomCompanion.NotBusyTime = nil;
                    debugmsg("Changing critter now", 4);
                    RandomCompanion.Pet();
                end
            else
                RandomCompanion.NotBusyTime = nil;
                debugmsg("Not changing critter because you are busy.", 1);
            end
        end
    end
    
    if RandomCompanion_Settings.AutoDismiss and RandomCompanion_Settings[GetRealmName()][UnitName("player")].ActiveCritter then
        debugmsg("Checking to dismiss pets while hiding", 1);
        local active = C_PetJournal.GetSummonedPetGUID();
        if active and UnitIsPVP("player") then
            local index = 1;
            local currentBuffName = UnitBuff("player", index);
            local isHidden = false;
            
            --Check to see if you're stealthed, prowling, or shadowmelded
            while currentBuffName do
                if  RC_BUSY_AURA[currentBuffName] then
                    isHidden = true;
                    break;
                end
                index = index + 1;
                currentBuffName = UnitBuff("player", index);
            end
            
            if isHidden then
                debugmsg("Auto-dismissing critter now because you are hiding", 4);
                local activecritter = RandomCompanion_Settings[GetRealmName()][UnitName("player")].ActiveCritter;
                RandomCompanion.PetDismiss()
                RandomCompanion.SetActiveCompanion(activecritter); -- so it can be summoned back later
            end
        end
    end
    
    if RandomCompanion_Settings.RaidDismiss and RandomCompanion_Settings[GetRealmName()][UnitName("player")].ActiveCritter then
        debugmsg("Checking to dismiss pets in raid", 1);
        local inInstance, instanceType;
        inInstance, instanceType = IsInInstance();
        local active = C_PetJournal.GetSummonedPetGUID();
        if active and inInstance and instanceType == "raid" then
            debugmsg("Auto-dismissing critter now because you are in a raid", 4);
            local activecritter = RandomCompanion_Settings[GetRealmName()][UnitName("player")].ActiveCritter;
            RandomCompanion.PetDismiss()
            RandomCompanion.SetActiveCompanion(activecritter); -- so it can be summoned back later
        end
    end
end

function RandomCompanion.GetTargetUsableMountID()
    if UnitIsPlayer("target") then

        local possibleMounts = {}
        local i = 1
        while true do
            local spellID, canApply = select(10, UnitBuff("target", i))
            if spellID and canApply then
                if RandomCompanion.mounts.bySpellID[spellID] then
                    return RandomCompanion.mounts.bySpellID[spellID].mountID;
                end
            else
                break;
            end
            i = i + 1;
        end
    end
end



local function OnSummonPetByGUID(...)
    debugmsg("OnSummonPetByGUID: " .. ..., 3)

    local petID = ...
    local currentPetID = C_PetJournal.GetSummonedPetGUID()
    debugmsg("  currentPetID: " .. (currentPetID and currentPetID or "nil"), 3)

    if petID == currentPetID then
        debugmsg("  Dismissing Pet.", 3);
        RandomCompanion.SetActiveCompanion("none");
    else
        RandomCompanion.SetActiveCompanion(petID);
    end
end

function RandomCompanion.SetActiveCompanion(petID)
    if not petID then
        petID = C_PetJournal.GetSummonedPetGUID();
    elseif petID == "none" then -- force set ActiveCritter to none for dismiss
        petID = nil
    end

    RandomCompanion_Settings[GetRealmName()][UnitName("player")].ActiveCritter = petID;
    debugmsg("Setting active critter to petID " .. (petID and petID or "nil"), 5);
    RandomCompanion.LastCritterChange = GetTime();


    RandomCompanion.ConfigurePetTick()
end

function RandomCompanion.PetDismiss()
    local currentPetID = C_PetJournal.GetSummonedPetGUID()
    if currentPetID then
        C_PetJournal.SummonPetByGUID(currentPetID)
    end
end

-- Doesn't work for newer characters, but keep just in case
local function OnDismissCompanion()
    C_Timer.After(3, function ()
        local currentPetID = C_PetJournal.GetSummonedPetGUID()
        if not currentPetID then
            RandomCompanion_Settings[GetRealmName()][UnitName("player")].ActiveCritter = nil;
            RandomCompanion.StopPetTick()
        end
    end)
    debugmsg("OnDismissCompanion", 3);
end

function RandomCompanion.Slash(...)
    local parsedcmd = ...;
    local cmd = "";
    local options = "";
    
    debugmsg("cmd: " .. parsedcmd, 3);
    
    if (...) then
        --Parse any macro conditionals such as [modifier:ctrl] or [combat]
        parsedcmd = SecureCmdOptionParse(...);
    end
    
    if parsedcmd == nil then
        parsedcmd = "";
    end
    
    debugmsg("parsed cmd: " .. parsedcmd, 3);
    
    if string.find(parsedcmd, " ") ~= nil then
        cmd = string.sub(parsedcmd, 0, string.find(parsedcmd, " ") - 1);
        options = string.sub(parsedcmd, string.find(parsedcmd, " ") + 1);
    elseif parsedcmd ~= nil then
        cmd = parsedcmd;
    end

    debugmsg("cmd: ".. cmd .. " / options: " .. options, 3)
    
    if string.lower(cmd) == "autorecall" then
        if (RandomCompanion_Settings.AutoRecall or options == "off") and string.lower(options) ~= "on" then
            RandomCompanion_Settings.AutoRecall = false;
            RandomCompanion_Settings.RandomRecall = false;
            DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion vanity pet recall disabled");
        else
            RandomCompanion_Settings.AutoRecall = true;
            RandomCompanion_Settings.RandomRecall = false;
            DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion vanity pet recall enabled");
        end
    elseif string.lower(cmd) == "autodismiss" then
        if (RandomCompanion_Settings.AutoDismiss or options == "off") and string.lower(options) ~= "on" then
            RandomCompanion_Settings.AutoDismiss = false;
            DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion vanity pet auto-dismiss disabled");
        else
            RandomCompanion_Settings.AutoDismiss = true;
            DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion vanity pet auto-dismiss enabled");
        end
    elseif string.lower(cmd) == "raiddismiss" then
        if (RandomCompanion_Settings.RaidDismiss or options == "off") and string.lower(options) ~= "on" then
            RandomCompanion_Settings.RaidDismiss = false;
            DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion vanity pet auto-dismiss disabled");
        else
            RandomCompanion_Settings.RaidDismiss = true;
            DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion vanity pet auto-dismiss enabled");
        end
    elseif string.lower(cmd) == "debug" then    
        if (options ~= "" and tonumber(options) == 0) or (RandomCompanion_Settings.DEBUG and (tonumber(options) == nil or options == "")) then
            if (tonumber(options) ~= nil) then
                RandomCompanion_Settings.DEBUGLevel = options;
            end
            RandomCompanion_Settings.DEBUG = false;
            DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion debug disabled");
        else
            if (tonumber(options) ~= nil) then
                RandomCompanion_Settings.DEBUGLevel = options;
            end
            if tonumber(RandomCompanion_Settings.DEBUGLevel) < 1 or tonumber(RandomCompanion_Settings.DEBUGLevel) == nil then
                RandomCompanion_Settings.DEBUGLevel = 1;
            end
            RandomCompanion_Settings.DEBUG = true;
            DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion debug enabled - Level " .. RandomCompanion_Settings.DEBUGLevel);
        end
    elseif string.lower(cmd) == "randomchange" then    
        if (options ~= "" and tonumber(options) == 0) or (RandomCompanion_Settings.RandomChange and (tonumber(options) == nil or options == "")) then
            RandomCompanion_Settings.RandomChange = false;
            DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion random vanity pet change disabled");
        else
            if (tonumber(options) ~= nil) then
                RandomCompanion_Settings.RandomChangeTime = options;
            end
            if tonumber(RandomCompanion_Settings.RandomChangeTime) < 1 or tonumber(RandomCompanion_Settings.RandomChangeTime) == nil then
                RandomCompanion_Settings.RandomChangeTime = 5;
            end
            RandomCompanion_Settings.RandomChange = true;
            DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion random vanity pet change every " .. RandomCompanion_Settings.RandomChangeTime .. " minutes");
        end
    elseif string.lower(cmd) == "mount" then
        RandomCompanion.Mount(options);
    elseif string.lower(cmd) == "pet" then
        RandomCompanion.Pet();
    elseif string.lower(cmd) == "petdismiss" or string.lower(cmd) == "dismiss" then
        RandomCompanion.PetDismiss();
    elseif string.lower(cmd) == "randomrecall" then
        if (RandomCompanion_Settings.RandomRecall or options == "off") and string.lower(options) ~= "on" then
            RandomCompanion_Settings.AutoRecall = false;
            RandomCompanion_Settings.RandomRecall = false;
            DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion random vanity pet recall disabled");
        else
            RandomCompanion_Settings.AutoRecall = false;
            RandomCompanion_Settings.RandomRecall = true;
            DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion random vanity pet recall enabled");
        end
    elseif string.lower(cmd) == "cloning" then
        if (RandomCompanion_Settings.Cloning or options == "off") and string.lower(options) ~= "on" then
            RandomCompanion_Settings.Cloning = false;
            DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion pet and mount cloning disabled");
        else
            RandomCompanion_Settings.Cloning = true;
            DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion pet and mount cloning enabled");
        end
    elseif string.lower(cmd) == "reload" then
        RandomCompanion.Initialize(true);
    elseif string.lower(cmd) == "status" then
        RandomCompanion.Status();
    elseif string.lower(cmd) == "quiet" then
        if (RandomCompanion_Settings.Quiet or options == "off") and string.lower(options) ~= "on" then
            RandomCompanion_Settings.Quiet = false;
            DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion quiet mode disabled");
        else
            RandomCompanion_Settings.Quiet = true;
            DEFAULT_CHAT_FRAME:AddMessage("RandomCompanion quiet mode enabled");
        end
    elseif parsedcmd == ... then --Show help
    
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00 RandomCompanion version " .. VERSION);
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00 \"/rcp mount\" to choose a random mount");
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00 \"/rcp mount ground\" to choose a random ground mount in a flyable zone");
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00 \"/rcp mount passenger\" or \"/rcp mount passengerground\" to choose a mount that can carry passengers");
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00 \"/rcp pet\" to choose a random vanity pet");
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00 \"/rcp autorecall\" to toggle automatically recalling your vanity pet after resurrecting, changing zones, or taking flight paths");
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00 \"/rcp randomrecall\" to toggle recalling a random vanity pet after resurrecting, changing zones, or taking flight paths");
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00 \"/rcp randomchange [number of minutes]\" to toggle randomly changing your vanity pet occasionally. Default is every 15 minutes");
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00 \"/rcp dismiss\" to dismiss your current vanity pet");
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00 \"/rcp autodismiss\" to toggle automatically dismissing your vanity pet when you are stealthed and flagged for PVP");
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00 \"/rcp raidautodismiss\" to toggle automatically dismissing your vanity pet when you are in a raid");
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00 \"/rcp cloning\" to toggle pet and mount cloning");
    end
    
    if (RandomCompanionOptionsCB_AutoRecall) then
        RandomCompanionOptionsCB_AutoRecall:SetChecked(RandomCompanion_Settings.AutoRecall);
    end
    if (RandomCompanionOptionsCB_AutoDismiss) then
        RandomCompanionOptionsCB_AutoDismiss:SetChecked(RandomCompanion_Settings.AutoDismiss);
    end
    if (RandomCompanionOptionsCB_RaidDismiss) then
        RandomCompanionOptionsCB_RaidDismiss:SetChecked(RandomCompanion_Settings.RaidDismiss);
    end
    if (RandomCompanionOptionsCB_RandomRecall) then
        RandomCompanionOptionsCB_RandomRecall:SetChecked(RandomCompanion_Settings.RandomRecall);
    end
    if (RandomCompanionOptionsCB_Cloning) then
        RandomCompanionOptionsCB_Cloning:SetChecked(RandomCompanion_Settings.Cloning);
    end
    --if (RandomCompanionOptionsCB_RandomChange) then
    --    RandomCompanionOptionsCB_RandomChange:SetChecked(RandomCompanion_Settings.RandomChange);
    --end

    RandomCompanion.ConfigurePetTick()
end

if not RandomCompanion_Settings then
    RandomCompanion_Settings = {};
end

SlashCmdList["RCRANDOMMOUNT"] = RandomCompanion.Mount;
SLASH_RCRANDOMMOUNT1 = "/rmount";

SlashCmdList["RCRANDOMPET"] = RandomCompanion.Pet;
SLASH_RCRANDOMPET1 = "/rpet";

SlashCmdList["RCPETDISMISS"] = RandomCompanion.PetDismiss;
SLASH_RCPETDISMISS1 = "/rpetdismiss";

SlashCmdList["RCSTATUS"] = RandomCompanion.Status;
SLASH_RCSTATUS1 = "/rcstatus";

SlashCmdList["RCRELOAD"] = RandomCompanion.Initialize;
SLASH_RCRELOAD1 = "/rcreload";

SlashCmdList["RC"] = RandomCompanion.Slash;
SLASH_RC1 = "/rcp";
SLASH_RC2 = "/randomcompanion";

RandomCompanion.EventFrame = CreateFrame("Frame", "RandomCompanionFrame");
RandomCompanion.EventFrame:SetScript("OnEvent", OnEvent);
RandomCompanion.EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
RandomCompanion.EventFrame:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED");
RandomCompanion.EventFrame:RegisterEvent("NEW_MOUNT_ADDED");
--RandomCompanion.EventFrame:RegisterEvent("PET_JOURNAL_LIST_UPDATE");
RandomCompanion.EventFrame:RegisterEvent("PET_JOURNAL_PET_DELETED");
RandomCompanion.EventFrame:RegisterEvent("NEW_PET_ADDED");

hooksecurefunc(C_PetJournal, "SummonPetByGUID", OnSummonPetByGUID)
hooksecurefunc("DismissCompanion", OnDismissCompanion)