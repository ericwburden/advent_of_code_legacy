"""
    part1(input) -> Int

Given the input as a directed adjacency list of objects and the objects
orbiting them, count and return the total number of direct and indirect
orbits represented.
"""
function part1(input)
    stack = [(0, "COM")]
    count = 0

    while !isempty(stack)
        depth, object = pop!(stack)
        count += depth

        for orbiting in get(input, object, [])
            push!(stack, (depth + 1, orbiting))
        end
    end
    return count
end
