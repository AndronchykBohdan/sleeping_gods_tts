GUIDcontainer = self.getGUID()  -- GUID of the container holding this deck's cards
prefix = "З "             -- Prefix used in card nicknames (e.g., "З 1", "З 2", ...)
minNumber = 1             -- Minimum allowed number
maxNumber = 218           -- Maximum allowed number
inputIndex = 0

-- Input field configuration
inputParams = {
    position    = {0, 0.2, 2.5},
    rotation    = {180, 180, 0},
    width       = 3300,
    height      = 824,
    font_size   = 400,
    label       = "ВВЕДІТЬ\nНОМЕР ЗАВДАННЯ",
    alignment   = 3,
    color       = {1, 1, 1},
    font_color  = {0, 0, 0},
    scale       = {0.3, 1, 0.8},
    value       = ""
}

-- Initializes the input field when the object loads
function onLoad()
    createInputField()
end

-- Creates a single input field on the object
function createInputField()
    self.createInput({
        input_function = "handleInput",
        function_owner = self,
        label          = inputParams.label,
        alignment      = inputParams.alignment,
        position       = inputParams.position,
        rotation       = inputParams.rotation,
        scale          = inputParams.scale,
        width          = inputParams.width,
        height         = inputParams.height,
        font_size      = inputParams.font_size,
        color          = inputParams.color,
        font_color     = inputParams.font_color,
        value          = inputParams.value,
    })
end

-- Handles input value once Enter is pressed
function handleInput(_, _, value, selected)
    if selected then return end

    local number = tonumber(value)
    if not number then
        showMessage("⚠️ Введено некоректне число.", {1, 0.4, 0.4})
        return
    end

    if number < minNumber or number > maxNumber then
        showMessage("❌ Номер має бути від " .. minNumber .. " до " .. maxNumber .. ".", {1, 0.3, 0.3})
        return
    end

    local name = prefix .. number          -- Full card nickname (e.g., "З 17")
    local shortName = tostring(number)     -- Number only (e.g., "17")

    local container = getObjectFromGUID(GUIDcontainer)
    if not container then
        showMessage("❌ Колоду не знайдено.", {1, 0, 0})
        return
    end

    local targetParams = {
        position = self.getPosition() + Vector(5.2, 3, -1.5),
        rotation = {0, 180, 0}
    }

    for _, obj in ipairs(container.getObjects()) do
        if obj.nickname == name then
            targetParams.index = obj.index
            container.takeObject(targetParams)
            showMessage("✅ Взято завдання '" .. shortName .. "'", {0.5, 1, 0.5})
            return
        end
    end

    showMessage("❌ Карту завдання '" .. shortName .. "' не знайдено в колоді.", {1, 0, 0})
end

-- Displays message in chat, on screen, and in console (without prefix if given)
function showMessage(text, color)
    broadcastToAll(text, color)
    self.clearInputs()
    createInputField()
end