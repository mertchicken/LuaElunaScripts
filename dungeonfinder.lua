local function getPlayerCharacterGUID(player)
    local query = CharDBQuery(string.format("SELECT guid FROM characters WHERE name='%s'", player:GetName()))

    if query then 
        local row = query:GetRow()
        return tonumber(row["guid"])
    end

    return nil
end

-- Helper function to check if a value exists in a table
local function tableContains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

    local teleportLocations = {
	{mapId = 595, x = 1431.47, y = 555.04, z = 36.27, o = 1, questId = 27027},
	{mapId = 619, x = 335.74, y = -1108.36, z = 68.51, o = 1, questId = 27028},
	{mapId = 601, x = 411.37, y = 794.95, z = 831.32, o = 5.64, questId = 27029},
	{mapId = 600, x = -517.15, y = -489.2, z = 11.01, o = 1, questId = 27030},
	{mapId = 604, x = 1882.32, y = 631.02, z = 176.7, o = 1, questId = 27031},
	{mapId = 574, x = 157.88, y = -84.7, z = 12.55, o = .26, questId = 27032},
	{mapId = 576, x = 152.21, y = -5.5, z = -16.64, o = 6.28, questId = 27033},
	{mapId = 608, x = 1806.37, y = 803.37, z = 44.36, o = 0, questId = 27034},
	{mapId = 599, x = 1153.95, y = 809.89, z = 195.84, o = 4.71, questId = 27035},
	{mapId = 602, x = 1331.41, y = 241.9, z = 52.5, o = 4.71, questId = 27036},
	{mapId = 578, x = 1056.96, y = 986.42, z = 361.07, o = 5.9, questId = 27037},
	{mapId = 575, x = 580.7, y = -327.8, z = 110.14, o = 3.14, questId = 27038},
	{mapId = 632, x = 4921.31, y = 2177.36, z = 638.73, o = 2.06, questId = 27039},
	{mapId = 658, x = 432.57, y = 212.34, z = 528.71, o = 0, questId = 27040},
	{mapId = 668, x = 5239.46, y = 1932.99, z = 707.7, o = .79, questId = 27041}
        }

local function OnLeave(event, player, msg, Type, lang)
	if msg == "#df leave" then
		if player:GetMap():IsDungeon() then
			local savedLocation = player:GetData("savedLocation")
			if savedLocation then
				local questsToRemove = {27027, 27028, 27029, 27030, 27031, 27032, 27033, 27034, 27035, 27036, 27037, 27038, 27039, 27040, 27041}
				
				-- Iterate through the quests to be removed
				for _, questId in ipairs(questsToRemove) do
					local questStatus = player:GetQuestStatus(questId)
					if questStatus == 3 then
						player:RemoveQuest(questId)
					end
				end
				
				player:Teleport(savedLocation.mapId, savedLocation.x, savedLocation.y, savedLocation.z, savedLocation.o)
				player:SetData("savedLocation", nil)
				player:SendNotification("Unfinished Dungeon Finder Quests Removed")
			else
				player:SendNotification("There is no saved location to teleport to.")
			end
			return
		end
	end
end

local function OnJoin(event, player, msg, Type, lang)
    if (msg == "#df join") then
        local playerGUID = getPlayerCharacterGUID(player)

        if not player:GetMap():IsDungeon() then
            local currentMapId = player:GetMapId()
            local currentX, currentY, currentZ, currentO = player:GetLocation()
            local currentLocation = {mapId = currentMapId, x = currentX, y = currentY, z = currentZ, o = currentO}
            player:SetData("savedLocation", currentLocation)
        end

        local completedQuests = {}
        local queryCompletedQuests = CharDBQuery(string.format("SELECT quest FROM character_queststatus_daily WHERE guid = %d", playerGUID))
        if queryCompletedQuests then
            repeat
                local row = queryCompletedQuests:GetRow()
                local questId = tonumber(row["quest"])
                table.insert(completedQuests, questId)
                until not queryCompletedQuests:NextRow()
        end

        local eligibleLocations = {}
        for _, location in ipairs(teleportLocations) do
            local isInProgress = player:HasQuest(location.questId)
            local isCompleted = tableContains(completedQuests, location.questId)

            if not isInProgress and not isCompleted then
                table.insert(eligibleLocations, location)
            end
        end

	

        if #eligibleLocations == 0 then
            player:SendNotification("There are no more dungeons you can do today.")
        else
            local teleportLocation = eligibleLocations[math.random(1, #eligibleLocations)]
            player:Teleport(teleportLocation.mapId, teleportLocation.x, teleportLocation.y, teleportLocation.z, teleportLocation.o)
            player:AddQuest(teleportLocation.questId)
            player:SendNotification("You have begun the quest associated with this location.")
        end

    end
end

RegisterPlayerEvent(18, OnJoin)
RegisterPlayerEvent(18, OnLeave)