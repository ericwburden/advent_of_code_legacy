"""
    extract_numbers2(json, numbers = [])

Recursively search a JSON input, adding each number found to `numbers` and 
returning the result. Skip any `Dict` node (and its children) where any of 
the dictionary values is "red".
"""
function extract_numbers2(json, numbers = [])
    json isa Int && push!(numbers, json)
    
    if json isa Vector
        for value in json
            extract_numbers2(value, numbers)
        end
    end

    if json isa Dict
        "red" in values(json) && return numbers
        for value in values(json)
            extract_numbers2(value, numbers)
        end
    end

    return numbers
end

"Extract and sum all the numbers from `input`, excepting the 'red' ones"
part2(input) = extract_numbers2(x) |> sum