Base.length(bridge::Bridge) = length(bridge.component_ids)

"""
    part2(components)

Given a list of components, search all the possible bridges that can be made 
(via DFS) for the longest bridges. Return the maximum strength of a bridge that
is as long as possible.
"""
function part2(components)
    start   = Bridge()
    stack   = [start]
    longest = [start]
    longest_length = length(start)

    while !isempty(stack)
        current = pop!(stack)
        length(current) == longest_length && push!(longest, current)
        if length(current) > longest_length
            longest = [current]
            longest_length = length(current)
        end

        for bridge in possible_bridges(current, components)
            push!(stack, bridge)
        end
    end

    return maximum(b -> b.strength, longest)
end