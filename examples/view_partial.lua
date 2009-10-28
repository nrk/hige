view_partial = {
    greeting = function()
        return "Welcome"
    end,
    farewell = function()
        return "Fair enough, right?"
    end,
}

simple = {
    name = "Chris",
    value = 10000,
    taxed_value = function() 
        return value - (value * 0.4)
    end,
    in_ca = true, 
}

simple_template = "Hello {{name}}\n" ..
"You have just won ${{value}}!\n" ..
"{{#in_ca}}\n" ..
"Well, ${{ taxed_value }}, after taxes.\n" ..
"{{/in_ca}}\n"