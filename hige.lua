module('hige', package.seeall)

local tags = { open = '{{', close = '}}' }
local lookup_environment = _G

local function merge_environment(...)
    local numargs, out = select('#', ...), {}
    for i = 1, numargs do
        local t = select(i, ...)
        if type(t) == 'table' then
            for k, v in pairs(t) do 
                if (type(v) == 'function') then
                    out[k] = setfenv(v, setmetatable(out, { 
                        __index = getmetatable(getfenv()).__index 
                    }))
                else
                    out[k] = v 
                end
            end
        end
    end
    return out
end

local function escape(str)
    return str:gsub('[&"<>\]', function(c) 
        if c == '&' then return '&amp;'
        elseif c == '"' then return '\"'
        elseif c == '\\' then return '\\\\'
        elseif c == '<' then return '&lt;'
        elseif c == '>' then return '&gt;'
        else return c end
    end)
end

local function find(name, context)
    local value = context[name]
    if value == nil then 
        return ''
    elseif type(value) == 'function' then 
        return merge_environment(context, value)[name]()
    else 
        return value
    end
end

local function render_partial(name, context)
    local target_mt  = setmetatable(context, { __index = lookup_environment })
    local target_name = setfenv(loadstring('return ' .. name), target_mt)()
    local target_type = type(target_name)

    if target_type == 'string' then
        return render(target_name, context)
    elseif target_type == 'table' then
        local target_template = setfenv(loadstring('return '..name..'_template'), target_mt)()
        return render(target_template, merge_environment(target_name, context))
    else
        error('unknown partial type "' .. tostring(name) .. '"')
    end
end

local operators = {
    -- comments 
    ['!'] = function(op, name, context) 
        return tags.open .. op .. name .. tags.close 
    end, 
    -- the triple hige is unescaped
    ['{'] = function(op, name, context) 
        return find(name, context) 
    end, 
    -- render partial
    ['<'] = function(op, name, context) 
        return render_partial(name, context)
    end, 
    -- set new delimiters
    ['='] = function(op, name, context)
        -- FIXME!
        error('setting new delimiters in the template is currently broken')
        --[[
        return name:gsub('^(.-)%s+(.-)$', function(open, close)
            tags.open, tags.close = open, close
            return ''
        end)
        ]]
    end, 
}

local function render_tags(template, context)
    return template:gsub(tags.open..'([=!<{]?)%s*([^#/]-)%s*[=}]?%s*'..tags.close, function(op, name)
        if operators[op] ~= nil then
            return tostring(operators[op](op, name, context))
        else
            return escape(tostring((function() 
                if name ~= '.' then return find(name, context) else return context end
            end)()))
        end
    end)
end

local function render_section(template, context)
    for section_name in template:gmatch(tags.open..'#%s*([^#/]-)%s*'..tags.close) do 
        local found, value = context[section_name] ~= nil, find(section_name, context)
        local section_path = '('..tags.open..'#'..section_name..tags.close..'%s*(.*)'..tags.open..'/'..section_name..tags.close..')%s*'

        template = template:gsub(section_path, function(outer, inner)
            if found == false then return '' end

            if value == true then 
                return render(inner, context)
            elseif type(value) == 'table' then 
                local output = {}
                for _, row in pairs(value) do 
                    if type(row) == 'table' then 
                        table.insert(output, (render(inner, merge_environment(context, row))))
                    else
                        table.insert(output, (render(inner, row)))
                    end
                end
                return table.concat(output)
            else 
                return ''
            end
        end)
    end

    return template
end

function render(template, context, env)
    lookup_environment = env or _G
    if template:find(tags.open) == nil then return template end
    return render_tags(render_section(template, context or {}), context)
end
