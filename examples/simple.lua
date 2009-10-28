simple = {
    name = "Chris",
    value = 10000,
    taxed_value = function()
        return value - (value * 0.4)
    end,
    in_ca = true
}