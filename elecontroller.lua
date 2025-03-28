local sequence = require("sequence")
local task = require("task")
local basalt = require("basalt")

-- 장치 초기화

print("Initializing ...")
    
local monitor = peripheral.find("monitor")
-- front: none
-- right: ele shift
-- top: ele clutch
-- left: ele shaft
-- back: door shift
local redstoneRelay = peripheral.find("redstone_relay")

local TOP_DOOR_SHIFT = false
local ELE_SHIFT = false
local ELE_CLUTCH = false
local ELE_SHAFT = false
local DOOR_SHIFT = false

local defaultTextColor = term.getTextColor()
if monitor == nil then
    term.setTextColor(colors.red)
    print("Error: Monitor not detected. Exiting program.")
    term.setTextColor(defaultTextColor)
    os.exit()
else
    print("Monitor connected, name: " .. peripheral.getName(monitor) .. ", size:" .. monitor.getSize())
    monitor.clear()
end

if redstoneRelay == nil then
    term.setTextColor(colors.red)
    print("Error: Redstone relay not detected. Exiting program")
    term.setTextColor(defaultTextColor)
    os.exit()
else
    print("Redstone relay connected, name:" .. peripheral.getName(redstoneRelay))
end

print("Initializing complete.")

local monitorFrame = basalt.createFrame():setTerm(monitor):setBackground(colors.black)

local currentSequence = nil

local isElevatorCalled = false;
local isElevatorAscended = false;


local function callElevatorSequence()
    if currentSequence ~= nil then
        return
    end
    if isElevatorCalled == true then
        currentSequence = Sequence:new("The elevator has already been called")
        currentSequence:append(Task:new(2, function()
        end))
    else
        currentSequence = Sequence:new("Call Elevator")
        currentSequence:append(Task:new(4, function()
            DOOR_SHIFT = true
        end))
        currentSequence:append(Task:new(13, function()
            TOP_DOOR_SHIFT = true
            ELE_SHIFT = true
        end))
        currentSequence:append(Task:new(0, function()
            ELE_SHAFT = true
            isElevatorCalled = true
        end))
    end
end

local function storeElevatorSequence()
    if currentSequence ~= nil then
        return
    end

    if isElevatorCalled == false then
        currentSequence = Sequence:new("The elevator has already been stored")
        currentSequence:append(Task:new(2, function()
        end))
    elseif isElevatorAscended == true then
        currentSequence = Sequence:new("Store Elevator")
        currentSequence:append(Task:new(0, function()
            ELE_CLUTCH = false
            ELE_SHAFT = false
        end))
        currentSequence:append(Task:new(13, function()
            TOP_DOOR_SHIFT = false
            ELE_SHIFT = false
        end))
        currentSequence:append(Task:new(4, function()
            DOOR_SHIFT = false
            isElevatorCalled = false
        end))
        currentSequence:append(Task:new(12, function()
            ELE_SHAFT = true
            ELE_SHIFT = true
        end))
        currentSequence:append(Task:new(0, function()
            ELE_SHAFT = false
            ELE_SHIFT = false
            isElevatorAscended = false
        end))
    else
        currentSequence = Sequence:new("Store Elevator")
        currentSequence:append(Task:new(0, function()
            ELE_SHAFT = false
        end))
        currentSequence:append(Task:new(13, function()
            TOP_DOOR_SHIFT = false
            ELE_SHIFT = false
        end))
        currentSequence:append(Task:new(4, function()
            DOOR_SHIFT = false
            isElevatorCalled = false
        end))
    end
end

local function elevetorAscentSequnce()
    if currentSequence ~= nil then
        return
    end

    if isElevatorCalled == false then
        currentSequence = Sequence:new("Call the elevator first")
        currentSequence:append(Task:new(2, function()
        end))
    elseif isElevatorAscended == true then
        currentSequence = Sequence:new("The elevator has already ascended")
        currentSequence:append(Task:new(2, function()
        end))
    else
        currentSequence = Sequence:new("Ascent elevator")
        currentSequence:append(Task:new(10, function()
            ELE_CLUTCH = false
            ELE_SHIFT = false
        end))
        currentSequence:append(Task:new(0, function()
            ELE_CLUTCH = true
            isElevatorAscended = true
        end))
    end
end

local function elevetorDescentSequnce()
    if currentSequence ~= nil then
        return
    end

    if isElevatorCalled == false then
        currentSequence = Sequence:new("Call the elevator first")
        currentSequence:append(Task:new(2, function()
        end))
    elseif isElevatorAscended == false then
        currentSequence = Sequence:new("The elevator has already decended")
        currentSequence:append(Task:new(2, function()
        end))
    else
        currentSequence = Sequence:new("Descent elevator")
        currentSequence:append(Task:new(10, function()
            ELE_CLUTCH = false
            ELE_SHIFT = true
        end))
        currentSequence:append(Task:new(0, function()
            isElevatorAscended = false
        end))
    end
end

local callElevatorButton = monitorFrame:addButton()
    :setText("Call Elevator")
    :setPosition(1, 3)
    :setSize(monitorFrame:getWidth() / 2, 3)
    :setForeground(colors.white)
    :setBackground(colors.gray)
    :onClick(callElevatorSequence)

local storeElevatorButton = monitorFrame:addButton()
    :setText("Store Elevator")
    :setPosition(monitorFrame:getWidth() / 2 + 1, 3)
    :setSize(monitorFrame:getWidth() / 2, 3)
    :setForeground(colors.white)
    :setBackground(colors.gray)
    :onClick(storeElevatorSequence)

local elevetorAscentButton = monitorFrame:addButton()
    :setText("Elevator Ascent")
    :setPosition(1, 7)
    :setSize(monitorFrame:getWidth() / 2, 3)
    :setForeground(colors.white)
    :setBackground(colors.gray)
    :onClick(elevetorAscentSequnce)

local elevetorDescentButton = monitorFrame:addButton()
    :setText("Elevator Descent")
    :setPosition(monitorFrame:getWidth() / 2 + 1, 7)
    :setSize(monitorFrame:getWidth() / 2, 3)
    :setForeground(colors.white)
    :setBackground(colors.gray)
    :onClick(elevetorDescentSequnce)

local label = monitorFrame:addLabel()
    :setText("State: ")
    :setForeground(colors.white)
    :setPosition(1, 1)

local sequenceProgressBar = monitorFrame:addProgressBar()
    :setPosition(1, 2)
    :setSize(monitorFrame:getWidth(), 1)
    :setProgressColor(colors.yellow)
    :setBackground(colors.lightGray)
    :setProgress(0)

local function elevatorPhysicalButtonProcess()
    local input = redstone.getInput("left")
    if input == true then
        if currentSequence ~= nil then
            return
        end
    
        if isElevatorCalled == false then
            return
        elseif isElevatorAscended == true then
            currentSequence = Sequence:new("Descent elevator")
            currentSequence:append(Task:new(10, function()
                ELE_CLUTCH = false
                ELE_SHIFT = true
            end))
            currentSequence:append(Task:new(0, function()
                isElevatorAscended = false
            end))
        elseif isElevatorAscended == false then
            currentSequence = Sequence:new("Ascent elevator")
            currentSequence:append(Task:new(10, function()
                ELE_CLUTCH = false
                ELE_SHIFT = false
            end))
            currentSequence:append(Task:new(0, function()
                ELE_CLUTCH = true
                isElevatorAscended = true
            end))
        end
    end
end

local function main()
    while true do

        elevatorPhysicalButtonProcess()

        if currentSequence ~= nil then

            currentSequence:process()

            local current = currentSequence.deltaTime
            local total = currentSequence.processingTime
            local percentage = (current / total) * 100

            sequenceProgressBar:setProgress(percentage)
            local timeStr = string.format("%d", current) .. "/" .. string.format("%d", total) .. "s"
            label:setText("State: ".. currentSequence.name .. ", " .. timeStr)

            if currentSequence.isEnd == true then
                currentSequence = nil
            end
        else
            label:setText("State: ")
            sequenceProgressBar:setProgress(0)
        end
        redstone.setOutput("top", TOP_DOOR_SHIFT)
        redstoneRelay.setOutput("right", ELE_SHIFT)
        redstoneRelay.setOutput("top", ELE_CLUTCH)
        redstoneRelay.setOutput("left", ELE_SHAFT)
        redstoneRelay.setOutput("back", DOOR_SHIFT)
        
        sleep(0.1)
    end
end

basalt.schedule(main)
basalt.run()