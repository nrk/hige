complex = {
    header = function()
        return 'Colors'
    end,
    item = {
        { name = 'red',   current = true,  url = '#Red'   }, 
        { name = 'green', current = false, url = '#Green' }, 
        { name = 'blue',  current = false, url = '#Blue'  }, 
    },
    link = function()
        return current ~= true
    end,
    list = function()
        return #item ~= 0
    end,
    empty = function() 
        return #item == 0
    end,
}
