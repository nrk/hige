package.path = package.path .. ';../?.lua'

require 'luarocks.require'
require 'telescope'
require 'lfs'
require 'hige'

local function readfile(directory, example, extension)
    return (io.open(directory..'/'..example..'.'..extension, 'r')):read('*a')
end

local function examples_iterator(directory)
    return coroutine.wrap(function() 
        for name in lfs.dir(directory) do
            for example in name:gmatch('([%w_]+).lua$') do
                coroutine.yield(example, {
                    lua    = readfile(directory, example, 'lua'), 
                    html   = readfile(directory, example, 'html'), 
                    output = readfile(directory, example, 'txt'), 
                })
            end
        end
    end)
end

local function load_examples()
    local examples = {}
    for name, data in examples_iterator('../examples') do 
        examples[name] = data 
    end
    return examples
end

local function setup_env()
    local example_env = {}
    for k, v in pairs(_G) do example_env[k] = v end
    return example_env
end

local function do_example(example, fun, env)
    env = env or _G
    local mt = setmetatable(setup_env(), { __index = env })
    local compiled = loadstring(example.lua)

    setfenv(compiled, mt)()
    setfenv(fun, mt)

    return fun(example)
end

local examples = load_examples()

context('Hige', function()
    it('handles arrays [array_of_strings.lua]', function()
        local example = examples.array_of_strings

        local rendered = do_example(example, function()
            return hige.render(example.html, array_of_strings)
        end)

        assert_equal(example.output, rendered)
    end)

    it('handles comments [comments.lua]', function()
        local example = examples.comments

        local rendered = do_example(example, function()
            return hige.render(example.html, comments)
        end)

        assert_equal(example.output, rendered)
    end)

    it('handles switching delimiter on-the-fly [delimiters.lua]', function()
        local example = examples.delimiters

        local rendered = do_example(example, function()
            return hige.render(example.html, delimiters)
        end)

        assert_equal(example.output, rendered)
    end)

    it('handles complex templates [complex.lua]', function()
        local example = examples.complex

        local rendered = do_example(example, function()
            return hige.render(example.html, complex)
        end)

        assert_equal(example.output, rendered)
    end)

    it('handles escaped sequences [escaped.lua]', function()
        local example = examples.escaped

        local rendered = do_example(example, function()
            return hige.render(example.html, escaped)
        end)

        assert_equal(example.output, rendered)
    end)

    it('handles recursion with same names [recursion_with_same_names.lua]', function()
        local example = examples.recursion_with_same_names

        local rendered = do_example(example, function()
            return hige.render(example.html, recursion_with_same_names)
        end)

        assert_equal(example.output, rendered)
    end)

    it('handles simple templates [simple.lua]', function()
        local example = examples.simple

        local rendered = do_example(example, function()
            return hige.render(example.html, simple)
        end)

        assert_equal(example.output, rendered)
    end)

    it('handles template partials [template_partial.lua]', function()
        local example = examples.template_partial

        local rendered = do_example(example, function()
            return hige.render(example.html, template_partial, getfenv())
        end)

        assert_equal(example.output, rendered)
    end)

    it('handles two hige in a row [two_in_a_row.lua]', function()
        local example = examples.two_in_a_row

        local rendered = do_example(example, function()
            return hige.render(example.html, two_in_a_row)
        end)

        assert_equal(example.output, rendered)
    end)

    it('handles view partials [view_partial.lua]', function()
        local example = examples.view_partial

        local rendered = do_example(example, function()
            return hige.render(example.html, view_partial, getfenv())
        end)

        assert_equal(example.output, rendered)
    end)
end)
