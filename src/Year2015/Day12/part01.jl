"""
    extract_numbers(json, numbers = [])

Recursively search a JSON input, adding each number found to `numbers` and 
returning the result. Employs function overloading to dispatch on the type
of the input.
"""
function extract_numbers(number::Int, numbers=[])
    push!(numbers, number)
    return numbers
end

function extract_numbers(vector::Vector, numbers=[])
    foreach(x -> extract_numbers(x, numbers), vector)
    return numbers
end

function extract_numbers(dict::Dict, numbers=[])
    foreach(x -> extract_numbers(x, numbers), values(dict))
    return numbers
end

extract_numbers(::String, ::Vector) = nothing

"Extract and sum all the numbers from `input`"
part1(input) = extract_numbers(input) |> sum
