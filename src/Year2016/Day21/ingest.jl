#=------------------------------------------------------------------------------
| Today's puzzle involves reading in a list of function descriptions and 
| transforming a string according to the parameters in the description. I 
| considered creating `struct`s with the parameters and using function
| overloading to apply the correct transformation, but decided to go with
| closures instead, creating the functions directly. Each of the functions
| ending with `_fn` do just that: given a line from the input they parse
| out the parameters and return a function (closure) that performs the 
| correct transformation.
------------------------------------------------------------------------------=#

"""
    swap_position_fn(s::AbstractString)
    swap_letter_fn(s::AbstractString)
    rotate_steps_fn(s::AbstractString)
    rotate_position_fn(s::AbstractString)
    reverse_positions_fn(s::AbstractString)
    move_positions_fn(s::AbstractString)

Given a line from the input as a string `s`, parse the string to identify the
appropriate function parameters and return a closure that applies one of the
transformations described in the puzzle input.
"""
function swap_position_fn(s::AbstractString)
    m = match(r"(?<pos1>\d+).*(?<pos2>\d+)", s)
    pos1, pos2 = parse.(Int, m.captures) .+ 1 # 1-indexing

    function swap_position!(chars::Vector{Char})
        chars[pos1], chars[pos2] = chars[pos2], chars[pos1]
    end
end

function swap_letter_fn(s::AbstractString)
    m = match(r"(?>letter (?<char1>\w)).*(?>letter (?<char2>\w))", s)
    char1, char2 = only.(m.captures)

    function swap_letter!(chars::Vector{Char})
        pos1 = findfirst(x -> x == char1, chars)
        pos2 = findfirst(x -> x == char2, chars)
        chars[pos1], chars[pos2] = chars[pos2], chars[pos1]
    end
end

function rotate_steps_fn(s::AbstractString)
    m = match(r"(?<dir>left|right) (?<steps>\d+)", s)
    steps = parse(Int, m["steps"])

    if m["dir"] == "left"
        function rotate_left!(chars::Vector{Char})
            circshift!(chars, [chars...], -steps)
        end
    else
        function rotate_right!(chars::Vector{Char})
            circshift!(chars, [chars...], steps)
        end
    end
end

function rotate_position_fn(s::AbstractString)
    m = match(r"letter (?<char>\w)", s)
    char = only(m["char"])

    # The numbers are a bit off from the puzzle description here to account
    # for Julia being 1-indexed instead of 0-indexed.
    function rotate_position!(chars::Vector{Char})
        pos = findfirst(x -> x == char, chars)
        steps = pos > 4 ? pos + 1 : pos
        circshift!(chars, [chars...], steps)
    end
end

function reverse_positions_fn(s::AbstractString)
    m = match(r"(?<pos1>\d+).*(?<pos2>\d+)", s)
    pos1, pos2 = parse.(Int, m.captures) .+ 1 # 1-indexing

    function reverse_positions!(chars::Vector{Char})
        reverse!(chars, pos1, pos2)
    end
end

function move_positions_fn(s::AbstractString)
    m = match(r"(?<pos1>\d+).*(?<pos2>\d+)", s)
    pos1, pos2 = parse.(Int, m.captures) .+ 1 # 1-indexing

    function move_positions!(chars::Vector{Char})
        char = popat!(chars, pos1)
        insert!(chars, pos2, char)
    end
end

"""
    to_function(s::AbstractString)

Given a line from the input file, identify which transformation is described
and return the appropriate closure to apply that transformation.
"""
function to_function(s::AbstractString)
    contains(s, "swap position") && return swap_position_fn(s)
    contains(s, "swap letter") && return swap_letter_fn(s)
    contains(s, "rotate based") && return rotate_position_fn(s)
    contains(s, "rotate") && return rotate_steps_fn(s)
    contains(s, "reverse") && return reverse_positions_fn(s)
    contains(s, "move") && return move_positions_fn(s)
    error("Don't know how to parse $s")
end

"Parse each line of the input file and return a map over the results"
ingest(path) = Iterators.map(to_function, readlines(path))
