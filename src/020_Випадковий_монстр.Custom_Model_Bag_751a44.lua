-- Bag script: accept only cards with nickname "М n" (Cyrillic capital M and space), reject others, shuffle after accept.

-- === Settings ===
local MIN_SHUFFLE_ITEMS = 2      -- shuffle only if bag has at least this many items
local EJECT_OFFSET      = {4, 2, 0} -- where to eject rejected items (relative to bag)
local NAME_PATTERN      = "^М%s+(%d+)$"  -- captures number after "М "

-- Utility: safe shuffle for Bag
local function shuffleBag(bag)
    local ok = pcall(function() bag.shuffle() end)
    if not ok then
        pcall(function() bag.randomize() end)
    end
end

-- Returns true if the object's nickname matches "М n"
local function isAllowedObject(obj)
    local objData = obj.getData()
    local nick = tostring(objData.Nickname and objData.Nickname or "")
    return nick:match(NAME_PATTERN) ~= nil
end

-- Eject a specific contained item by GUID back out of the bag
local function ejectByGuid(bag, guid)
    Wait.frames(function()
        bag.takeObject({
            guid = guid,
            position = bag.getPosition() + Vector(EJECT_OFFSET[1], EJECT_OFFSET[2], EJECT_OFFSET[3]),
            smooth = false
        })
    end, 1)
end

-- Main hook: fires when something enters this bag/container
function onObjectEnterContainer(container, object)
    if container ~= self then return end

    local guid = object.getGUID and object:getGUID()

    if not isAllowedObject(object) then
        if guid then ejectByGuid(self, guid) end
        broadcastToAll("❌ У мішок можна класти лише карти з префіксом 'М' та номером.", {1,0,0})
        return
    end

    Wait.frames(function()
        local items = self.getObjects() or {}
        if #items >= MIN_SHUFFLE_ITEMS then
            shuffleBag(self)
        end
    end, 1)
end