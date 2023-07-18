local TIME_SCALE_FACTOR = .1 -- Increase in time speed
local SMSG_LOGIN_SETTIMESPEED = 66

local function ConvertUnixToPackedTime(acceleratedUnixTime)
    local timeTable = os.date("*t", acceleratedUnixTime)
    local packedTime = ((timeTable.year - 100) % 2^8) * 2^24
                    + (timeTable.month % 2^4) * 2^20
                    + ((timeTable.day - 1) % 2^5) * 2^14
                    + (timeTable.wday % 2^3) * 2^11
                    + (timeTable.hour % 2^6) * 2^6
                    + (timeTable.min % 2^6)
    return packedTime
end


local function CalculateAcceleratedTime(event, player)
   local serverTime = os.date("*t") -- Retrieve the current server time
local hour = serverTime.hour
local minute = serverTime.min
local second = serverTime.sec

-- Print the initial values
print("Initial Time: " .. hour .. ":" .. minute .. ":" .. second)


-- Step 2: Separate into hours and minutes
local h = hour
local m = minute

-- Print the separated hours and minutes
print("Separated Hours: " .. h)
print("Separated Minutes: " .. m)

-- Step 3: Calculate the starting point
local initialStartingPoint = h * 100
local adjustedStartingPoint = initialStartingPoint * 6

-- Print the starting points
print("Initial Starting Point: " .. initialStartingPoint)
print("Adjusted Starting Point: " .. adjustedStartingPoint)

while adjustedStartingPoint >= 2400 do
        adjustedStartingPoint = adjustedStartingPoint - 2400
    end

    -- Print the adjusted starting point
    print("Adjusted Starting Point 2: " .. string.format("%04d", adjustedStartingPoint))


-- Print the adjusted starting point
print("Adjusted Starting Point: " .. adjustedStartingPoint)

-- Step 4: Calculate the minutes part
local t = math.floor(m / 10)
local o = m % 10
local initialMinutes = (t * 100) + (o * 6)

-- Print the initial minutes
print("Initial Minutes: " .. initialMinutes)

-- Step 5: Calculate the accelerated time
local acceleratedTime = adjustedStartingPoint + initialMinutes

-- Print the accelerated time
print("Accelerated Time: " .. acceleratedTime)

    -- Step 6: Adjust if the accelerated time is greater than or equal to 2400
    while acceleratedTime >= 2400 do
        acceleratedTime = acceleratedTime - 2400
    end

    -- Print the final accelerated time
    print("Final Accelerated Time: " .. string.format("%04d", acceleratedTime))

    -- Calculate the dayUnixTime
    local dayUnixTime = os.time({year = serverTime.year, month = serverTime.month, day = serverTime.day, hour = 0, min = 0, sec = 0})

    -- Calculate the time passed in seconds for the accelerated time
    local acceleratedHours = math.floor(acceleratedTime / 100)
    local acceleratedMinutes = acceleratedTime % 100
    local acceleratedTimePassedSeconds = (acceleratedHours * 60 + acceleratedMinutes) * 60

    -- Calculate the acceleratedUnixTime
    local acceleratedUnixTime = dayUnixTime + acceleratedTimePassedSeconds
    -- Print the acceleratedUnixTime
    print("Accelerated Unix Time: " .. acceleratedUnixTime)

    -- Create the time packet
    local packedTime = ConvertUnixToPackedTime(acceleratedUnixTime)
    local setTimePacket = CreatePacket(SMSG_LOGIN_SETTIMESPEED, 4 + 4 + 4)
    setTimePacket:WriteULong(packedTime)
    setTimePacket:WriteFloat(TIME_SCALE_FACTOR)
    setTimePacket:WriteULong(0)

    -- Send the time packet to the player
    player:SendPacket(setTimePacket)
    -- Print the notification message
    print("Time set for the player")

    return false -- Prevent default command handling


end

local function CalculateAcceleratedTimeTeleport(event, player)
    CalculateAcceleratedTime(event, player)
end

RegisterPlayerEvent(3, CalculateAcceleratedTime)
RegisterPlayerEvent(28, CalculateAcceleratedTimeTeleport)
