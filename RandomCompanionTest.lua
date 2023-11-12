function RandomCompanion.GetAllUnusableMounts()
	local unusableMounts = {};
	for index,mountID in pairs(C_MountJournal.GetMountIDs()) do
		local name, _, _, _, isUsable, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID);

        if name and not isUsable and isCollected then
            table.insert(unusableMounts, name);
        end
    end

    return unusableMounts;
end

function RandomCompanion.GetAllMapInfo()
	local mapInfo = C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player"));
	local instanceInfo = {GetInstanceInfo()};

	mapInfo.instanceName = instanceInfo[1];
	mapInfo.instanceType = instanceInfo[2];
	mapInfo.instanceMapID = instanceInfo[8];
	mapInfo.flyable = IsFlyableArea();
	mapInfo.scenarioType = select(10, C_Scenario.GetInfo());
	mapInfo.inScenario = C_Scenario.IsInScenario();

	return mapInfo;
end