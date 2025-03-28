local task = require("task")
local queue = require("queue")

Sequence = {}

-- @param name string
function Sequence:new(name)
    local instance = setmetatable({}, self)
    self.__index = self

    instance.name = name or ("Unknown")

    local taskTimes

    instance.taskQueue = Queue:new()
    instance.isStart = true
    instance.isEnd = false
    instance.currentTask = nil
    instance.lastTime = 0
    instance.deltaTime = 0
    instance.processingTime = 0

    return instance
end

function Sequence:process()
    if self.isStart == true then
        for index, value in pairs(self.taskQueue.table) do
            self.processingTime = self.processingTime + value.processingTime
        end

        self.lastTime = os.clock()
        self.isStart = false
    end

    self.currentTask = self.taskQueue:getHead()

    if self.currentTask == nil then
        self.isEnd = true
        return
    end

    local state = self.currentTask:run()

    if state == TaskState.END then
        self.currentTask:clear()
        self.taskQueue:dequeue()
    end

    local currentTime = os.clock()
    self.deltaTime = currentTime - self.lastTime
end

-- @param task Task
function Sequence:append(task)
    self.taskQueue:enqueue(task)
end

return Sequence