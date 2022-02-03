"""
    extract_numbers2(json, numbers = [])

Recursively search a JSON input, adding each number found to `numbers` and 
returning the result. Skip any `Dict` node (and its children) where any of 
the dictionary values is "red". Uses function overloading to dispatch based
on the input type.
"""
function extract_numbers2(number::Int, numbers=[])
    push!(numbers, number)
    return numbers
end

function extract_numbers2(vector::Vector, numbers=[])
    foreach(x -> extract_numbers2(x, numbers), vector)
    return numbers
end

function extract_numbers2(dict::Dict, numbers=[])
    "red" in values(dict) && return numbers
    foreach(x -> extract_numbers2(x, numbers), values(dict))
    return numbers
end

extract_numbers2(::String, ::Vector) = nothing

"Extract and sum all the numbers from `input`, excepting the 'red' ones"
part2(input) = extract_numbers2(input) |> sum