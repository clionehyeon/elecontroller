Task = {}

TaskState = { WAITING = 0, PROCESSING = 1, END = 2}

-- @param processingTime number
-- @param action function
-- @return Task
function Task:new(processingTime, action)
    local instance = setmetatable({}, self)
    self.__index = self
    
    instance.action = action
    instance.processingTime = processingTime

    instance.State = TaskState.WAITING
    instance.lastTime = 0
    instance.deltaTime = 0
    instance.isStart = true

    return instance
end

function Task:clear()
    self.State = TaskState.WAITING
    self.lastTime = 0
    self.deltaTime = 0
    self.isStart = true
end

-- @return TaskState
function Task:run()
    if self.State == TaskState.WAITING and self.isStart == true then
        self.State = TaskState.PROCESSING
        self.lastTime = os.clock()
        self.isStart = false
    end

    self.action()
    
    local currentTime = os.clock()
    self.deltaTime = currentTime - self.lastTime
    if self.deltaTime > self.processingTime then
        self.State = TaskState.END
    end

    return self.State
end

return Task