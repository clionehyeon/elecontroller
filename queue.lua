Queue = {}

function Queue:new()
    local instance = setmetatable({}, self)
    self.__index = self

    instance.head = 0
    instance.table = {}
    instance.tail = 0

    return instance
end

function Queue:getHead()
    if (self.head == self.tail) then
        return nil
    end
    local headPoint = self.head
    local retValue = self.table[headPoint]
    return retValue
end

function Queue:enqueue(value)
    local tailPoint = self.tail
    self.table[tailPoint] = value
    self.tail = tailPoint + 1
end

function Queue:dequeue()
    if (self.head == self.tail) then
        return nil
    end
    local headPoint = self.head
    local retValue = self.table[headPoint]
    self.table[headPoint] = nil
    self.head = headPoint + 1
    return retValue
end