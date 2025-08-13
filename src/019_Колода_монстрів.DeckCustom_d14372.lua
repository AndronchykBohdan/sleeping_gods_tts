-- === Settings ===
GUIDcontainer = self.getGUID()   -- deck to take cards from (defaults to self)
prefix = "М "
minNumber = 1
maxNumber = 94

-- Bag GUID (must be set)
BAG_GUID = "751a44"

-- Input params (placement same as your current)
local inputParams = {
    position = { 0, -0.28, 0 },
    rotation = { 180, 180, 0 },
    scale = { 1, 1, 1 },
    width = 1000,
    height = 500,
    font_size = 150,
    label = "ВВЕДІТЬ\nНОМЕР МОНСТРА",
    alignment = 3,
    color = { 1, 1, 1 },
    font_color = { 0, 0, 0 },
    value = ""
}

function onLoad()
    createInputField()
end

function createInputField()
    self.createInput({
        input_function = "handleInput",
        function_owner = self,
        label = inputParams.label,
        alignment = inputParams.alignment,
        position = inputParams.position,
        rotation = inputParams.rotation,
        scale = inputParams.scale,
        width = inputParams.width,
        height = inputParams.height,
        font_size = inputParams.font_size,
        color = inputParams.color,
        font_color = inputParams.font_color,
        value = inputParams.value,
    })
end

function showMessage(text, color)
    broadcastToAll(text, color)
    self.clearInputs()
    createInputField()
end

function handleInput(_, _, value, selected)
    if selected then
        return
    end

    if (value == '') then
        return
    end

    if self.tag ~= "Deck" then
        return showMessage("❌ Скрипт має бути на колоді.", { 1, 0, 0 })
    end

    local number = tonumber(value)
    if not number then
        return showMessage("⚠️ Введено некоректне число.", { 1, 0.4, 0.4 })
    end
    if number < minNumber or number > maxNumber then
        return showMessage("❌ Номер має бути від " .. minNumber .. " до " .. maxNumber .. ".", { 1, 0.3, 0.3 })
    end

    local container = getObjectFromGUID(GUIDcontainer) or self
    local bag = getObjectFromGUID(BAG_GUID)
    if not bag then
        return showMessage("❌ Мішок не знайдено. Перевір BAG_GUID.", { 1, 0, 0 })
    end
    if bag.tag ~= "Bag" and bag.tag ~= "Infinite" then
        return showMessage("❌ Об'єкт має бути мішком (Bag).", { 1, 0, 0 })
    end

    local nameA = (prefix .. number):lower()
    local nameB = tostring(number):lower()
    local idx = nil
    for _, obj in ipairs(container.getObjects()) do
        local cand = (obj.nickname or obj.name or ""):lower()
        if cand == nameA or cand == nameB then
            idx = obj.index
            break
        end
    end
    if not idx then
        return showMessage("❌ Карту монстра '" .. number .. "' не знайдено в колоді.", { 1, 0, 0 })
    end

    container.takeObject({
        index = idx,
        position = self.getPosition() + Vector(0, 3, 0),
        rotation = { 0, 180, 0 },
        smooth = true,
        callback_function = function(card)
            if not card then
                return showMessage("❌ Сталася помилка при витягуванні карти.", { 1, 0, 0 })
            end
            local ok = bag.putObject(card)
            if not ok then
                card.setPositionSmooth(bag.getPosition() + Vector(0, 1.5, 0), false, false)
                return showMessage("⚠️ Карту покладено на мішок (putObject не спрацював).", { 1, 0.6, 0.2 })
            end
            showMessage("✅ Монстра '" .. number .. "' покладено у мішок.", { 0.5, 1, 0.5 })
        end
    })
end