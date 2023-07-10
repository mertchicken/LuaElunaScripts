local function getPlayerCharacterGUID(player)
    -- Retrieve the GUID of the player's character from the database
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

-- Table to store the saved locations
    local savedLocations = {}

-- List of teleport locations
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

-- List of aura IDs
    local auraIDs = {
	458, 459, 468, 470, 471, 472, 578, 580, 581, 3363, 5784, 6648, 6653, 6654, 
	6777, 6896, 6897, 6898, 6899, 8394, 8395, 8396, 8980, 10787, 10788, 10789, 
	10790, 10792, 10793, 10795, 10796, 10798, 10799, 10800, 10801, 10802, 10803, 
	10804, 10873, 10969, 13819, 15779, 15780, 15781, 16055, 16056, 16058, 16059, 
	16060, 16080, 16081, 16082, 16083, 16084, 17229, 17450, 17453, 17454, 17455, 
	17456, 17458, 17459, 17460, 17461, 17462, 17463, 17464, 17465, 17481, 18363, 
	18989, 18990, 18991, 18992, 22717, 2718, 22719, 22720, 22721, 22722, 22723, 
	22724, 23161, 23214, 23219, 23220, 23221, 23222, 23223, 23225, 23227, 23228, 
	23229, 23238, 23239, 23240, 23241, 23242, 23243, 23246, 23247, 223248, 23249, 
	23250, 23251, 23252, 23338, 23509, 23510, 24242, 24252, 24576, 25675, 25858, 
	25859, 25863, 25953, 26054, 26055, 26056, 26332, 26655, 26656, 28828, 29059, 
	30174, 30829, 30837, 31700, 31973, 32235, 32239, 32240, 32242, 32243, 32244, 
	32245, 32246, 32289, 32290, 32282, 32295, 32296, 32297, 32345, 32420, 33630, 
	34068, 34406, 34407, 34767, 34769, 34790, 34795, 34896, 34897, 34898, 34899, 
	35018, 35020, 35022, 35025, 35027, 35028, 35710, 35711, 35712, 35713, 35714, 
	36702, 37015, 39315, 39316, 39317, 39318, 39319, 39450, 39798, 39800, 39801, 
	39802, 39803, 39910, 39949, 40192, 40212, 21252, 41513, 41514, 41515, 41516, 
	41517, 41518, 42363, 42387, 42667, 42668, 42680, 42683, 42692, 42776, 42777, 
	42929, 43688, 43810, 43880, 43883, 43899, 43900, 43927, 44151, 44153, 44317, 
	44655, 44744, 44824, 44825, 45177, 46197, 46199, 46628, 46980, 47037, 47977, 
	48023, 48024, 48025, 48027, 48778, 48954, 49193, 49322, 49378, 49379, 49908, 
	50281, 50869, 50870, 51412, 51617, 51621, 51960, 54726, 54727, 54729, 54753, 
	55164, 55293, 55531, 58615, 58819, 58983, 58997, 58999, 59567, 59568, 59569, 
	59570, 59571, 59572, 59573, 59650, 59785, 59788, 59791, 59793, 59797, 59799, 
	59802, 59804, 59961, 59976, 59996, 60002, 60021, 60024, 60025, 60114, 60116, 
	60118, 60119, 60120, 60136, 60140, 60424, 61229, 61230, 61289, 61294, 61309, 
	61425, 61442, 61444, 61446, 61447, 61451, 61465, 61467, 614469, 61470, 61983, 
	61996, 61997, 62048, 63232, 63635, 63636, 63637, 63638, 63639, 63640, 63641, 
	63642, 63643, 63796, 63844, 63956, 63963, 64656, 64657, 64658, 64659, 64681, 
	64731, 64761, 64927, 64992, 64993, 65439, 65637, 65638, 65639, 65640, 65641, 
	65642, 65643, 65644, 65645, 65646, 65917, 66087, 66088, 66090, 66091, 66122, 
	66123, 66124, 66846, 66847, 66906, 66907, 67336, 67466, 68056, 68057, 68187, 
	68188, 68768, 68769, 69395, 71342, 71343, 71344, 71345, 71346, 71347, 71810, 
	72281, 72282, 72283, 72284, 72286, 72808, 73313, 74854, 74855, 74856, 74918, 
	75387, 75596, 75614, 75617, 75618, 75619, 75620, 75957, 75972, 75973, 76153, 
	76154, 81505, 88331, 88335, 88718, 88741, 88742, 88744, 88746, 88748, 88749, 
	88750, 88990, 90619, 90621, 93644, 96491, 96503, 97359, 97493, 97501, 97560, 
	98204, 98727, 100332, 100333, 101542, 101827, 102488, 102514, 103195, 103196, 
	103197, 103198, 103199, 103200, 103201, 107203, 107842, 107844, 107845, 113120, 
	113121, 113122, 113123, 113124, 113125, 121820
	}

-- Function called when the player uses the command "dfjoin"
local function OnJoin(event, player, command)
    if command == "dfjoin" then
        local playerGUID = getPlayerCharacterGUID(player)

        if not player:GetMap():IsDungeon() then 
            local currentMapId = player:GetMapId()
            local currentX, currentY, currentZ, currentO = player:GetLocation()
            local isMounted = player:IsMounted()
            local auraId = nil

            if isMounted then  --If the player is currently mounted determine the mount spell and save it
                for _, id in ipairs(auraIDs) do
                    if player:HasAura(id) then
                        auraId = id
                        break
                    end
                end
            end

-- The player's location prior to the dungeon teleport.  Location to be returned to when OnLeave is called.  Doesn't persist through server restart
            local currentLocation = {
                mapId = currentMapId,
                x = currentX,
                y = currentY,
                z = currentZ,
                o = currentO,
                isMounted = isMounted,
                auraId = auraId
            }
            savedLocations[playerGUID] = currentLocation
        end

-- Check which of the Dungeon Finder quests have been completed today
        local completedQuests = {}
        local queryCompletedQuests = CharDBQuery(string.format("SELECT quest FROM character_queststatus_daily WHERE guid = %d", playerGUID))
        if queryCompletedQuests then
            repeat
                local row = queryCompletedQuests:GetRow()
                local questId = tonumber(row["quest"])
                table.insert(completedQuests, questId)
            until not queryCompletedQuests:NextRow()
        end

-- Check which dungeons are still available to do
        local eligibleLocations = {}
        for _, location in ipairs(teleportLocations) do
            local isInProgress = player:HasQuest(location.questId) -- Don't include any where the quest is already in progress
            local isCompleted = tableContains(completedQuests, location.questId) -- Don't include any where the quest has been completed

            if not isInProgress and not isCompleted then
                table.insert(eligibleLocations, location)
            end
        end

-- Tell the player if there are no more dungeons, otherwise teleport to a random one
        if #eligibleLocations == 0 then
            player:SendNotification("There are no more dungeons you can do today.")
        else
            local teleportLocation = eligibleLocations[math.random(1, #eligibleLocations)]
            player:Teleport(teleportLocation.mapId, teleportLocation.x, teleportLocation.y, teleportLocation.z, teleportLocation.o)
            player:AddQuest(teleportLocation.questId)
            player:SendNotification("You have begun the quest associated with this location.")
        end

        return false -- Add this line to prevent further command processing so no "command doesn't exist" error
    end
end

-- Function called when player uses the command "dfleave"
local function OnLeave(event, player, command)
    if command == "dfleave" then
        if player:GetMap():IsDungeon() then  --Only works if the player is currently in a dungeon, otherwise they will have already "left"
            local playerGUID = getPlayerCharacterGUID(player)
            local savedLocation = savedLocations[playerGUID]
            if savedLocation then
                local questsToRemove = {27027, 27028, 27029, 27030, 27031, 27032, 27033, 27034, 27035, 27036, 27037, 27038, 27039, 27040, 27041}

                -- Iterate through the quests to be removed 
                for _, questId in ipairs(questsToRemove) do
                    local questStatus = player:GetQuestStatus(questId)
                    if questStatus == 3 then -- Quest not yet completed
                        player:RemoveQuest(questId)
                    end
                end

                player:Teleport(savedLocation.mapId, savedLocation.x, savedLocation.y, savedLocation.z, savedLocation.o)
                if savedLocation.auraId then
                    player:AddAura(savedLocation.auraId, player) -- If the player had a mount prior to OnJoin the aura will be added back
                end
                savedLocations[playerGUID] = nil -- Reset savedLocations
                player:SendNotification("Unfinished Dungeon Finder Quests Removed")
            else
                player:SendNotification("There is no saved location to teleport to.")
            end
	        return false -- Add this line to prevent further command processing so no "command doesn't exist" error
        end
    end
end


RegisterPlayerEvent(42, OnJoin) -- Command event for dfjoin
RegisterPlayerEvent(42, OnLeave) -- Command event for dfleave