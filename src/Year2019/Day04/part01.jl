"""
A `Digits` represents the digits of a password and a pointer to
the digit that is currently increasing.
"""
struct Digits{N}
    inner::NTuple{N,Int}
    pointer::Int
end

"""
Construct a `Digits` from an integer.
"""
function Digits(value::Int)
    inner   = (reverse ∘ digits)(value) |> Tuple
    pointer = length(inner)
    return Digits(inner, pointer)
end

Base.isless(a::Digits, b::Digits) = a.inner < b.inner

"""
Fast forward a `Digits` to a value where no subsequent digits are
decreasing.
"""
function skip_to_start((; inner, pointer)::Digits)
    inner = accumulate(max, inner)
    return Digits(inner, pointer)
end

"""
    next(digits::Digits)

Produces the next set of `Digits` in sequence where each digit is greater than
or equal to the previous digit. For example, 189 -> 199 -> 222 -> 223.
"""
function next((; inner, pointer)::Digits)
    all(d -> d >= 9, inner) && return Digits(inner, pointer)

    inner = set_value(inner, inner[pointer] + 1, pointer)
    if inner[pointer] > 9
        pointer = findlast(d -> d < 9, inner)
        inner = set_value(inner, inner[pointer] + 1, pointer)
        inner = set_value(inner, inner[pointer], (pointer+1):length(inner))
        pointer = length(inner)
    end
    
    return Digits(inner, pointer)
end

"""
    set_value(digits::Tuple, value::Int, idx::Int)
    set_value(digits::Tuple, value::Int, idx::UnitRange)

Set one or more digits (indicated by `idx`) to the given `value`.
"""
function set_value(digits::Tuple, value::Int, idx::Int)
    return Tuple(i == idx ? value : v for (i, v) in enumerate(digits))
end
function set_value(digits::Tuple, value::Int, idx::UnitRange)
    return Tuple(i ∈ idx ? value : v for (i, v) in enumerate(digits))
end

"""
    count_valid(input::Tuple{Int,Int}, validate::Function)

Iterate over all the `Digit`s in the range given by `input`, and 
return the number that are valid according to the `validate` function.
"""
function count_valid(input::Tuple{Int,Int}, validate::Function)
    start, stop = Digits.(input)
    current = skip_to_start(start)
    valid_values = 0
    while current < stop
        validate(current) && (valid_values += 1)
        current = next(current)
    end
    return valid_values
end

"""
    part_one_valid((; inner)::Digits)

Determine whether or not a `Digits` is valid according to part one instructions.
"""
function part_one_valid((; inner)::Digits)
    found_double = false
    for (current, next) in zip(inner, inner[2:end])
        current == next && (found_double = true)
        current  > next && return false
    end
    return found_double
end

part1(input) = count_valid(input, part_one_valid)
