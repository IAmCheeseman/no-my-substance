local module = {
    amount = 0,
    max = 100,
    active = false,
    time = 7,
    unlocked = false,
}

function module.give_substance(amount)
    if module.active then
        return
    end
    module.amount = math.clamp(module.amount + amount, 0, module.max)
end

function module.is_unlocked()
    return module.unlocked or Objects.grab("WaveManager")
end

return module