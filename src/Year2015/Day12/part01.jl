"""
    extract_numbers(json, numbers = [])

Recursively search a JSON input, adding each number found to `numbers` and 
returning the result.
"""
function extract_numbers(json, numbers = [])
    json isa Int && push!(numbers, json)

    if json isa Vector
        for value in json
            extract_numbers(value, numbers)
        end
    end

    if json isa Dict
        for value in values(json)
            extract_numbers(value, numbers)
        end
    end

    return numbers
end

"Extract and sum all the numbers from `input`"
part1(input) = extract_numbers(x) |> sum
