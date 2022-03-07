"""
    longest_path(code::String, start::CartesianIndex, goal::CartesianIndex)

Given the initial passcode, a start index, and an goal index, determine the
longest possible path (list of steps) from `start` to `goal`. Uses a
breadth-first search.
"""
function longest_path(code::String, start::CartesianIndex, goal::CartesianIndex)
    queue = Queue{Tuple{String,CartesianIndex}}()
    enqueue!(queue, ("", start))
    longest = ""

    while !isempty(queue)
        path, current = dequeue!(queue)
        if current == goal 
            if (length(path) > length(longest)) longest = path end
            continue
        end

        for (step, neighbor) in neighbors(current, code * path)
            enqueue!(queue, (path * step, neighbor))
        end
    end
    return longest
end

"""
    part2(input)

Given the input as a string representing the passcode, return the number of 
steps in the longest possible path from the start to the vault.
"""
function part2(input)
    longest = longest_path(input, CartesianIndex(1, 1), CartesianIndex(4, 4))
    return length(longest)
end
