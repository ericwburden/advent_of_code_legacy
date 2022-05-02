const BotGraph = Dict{NanoBot,Vector{NanoBot}}

"""
    build_bot_graph(all_bots::Vector{NanoBot})

Create an adjacency list (Dict) from the list of `NanoBot`s, where each
entry indicates the bots that are mutually in range of the key.
"""
function build_bot_graph(all_bots::Vector{NanoBot})
    bot_graph = BotGraph()
    for bot in all_bots
        bot_graph[bot] = get_neighbors(bot, all_bots)
    end
    return bot_graph
end

"""
    get_neighbors(bot::NanoBot, all_bots::Vector{NanoBot})

Given a list of `NanoBot`s, return a sub-list of all the bots that are mutually
in range of `bot`.
"""
function get_neighbors(bot::NanoBot, all_bots::Vector{NanoBot})
    neighbors = []
    for other_bot in all_bots
        bot == other_bot            && continue
        in_range_of(bot, other_bot) || continue
        in_range_of(other_bot, bot) || continue
        push!(neighbors, other_bot)
    end
    return neighbors
end

"""
    largest_clique(all_bots::Vector{NanoBot}, bot_graph::BotGraph)

Identify the largest `clique` in the `bot_graph`, the set of `NanoBot`s that are
mutually in range of one another.
"""
function largest_clique(all_bots::Vector{NanoBot}, bot_graph::BotGraph)
    bot_set   = Set(all_bots)
    clique    = Set{NanoBot}()

    while !isempty(bot_set)
        next_clique = build_clique(first(bot_set), bot_graph)
        bot_set     = setdiff!(bot_set, next_clique)
        length(next_clique) > length(clique) || continue
        clique = next_clique
    end

    return clique
end

"""
    build_clique(bot::NanoBot, bot_graph::BotGraph)

Given a `bot_graph`, identify and return a set of bots that are mutually in
range of the given `bot`.
"""
function build_clique(bot::NanoBot, bot_graph::BotGraph)
    stack  = [bot]
    clique = Set{NanoBot}()
    while !isempty(stack)
        current = pop!(stack)
        current ∈ clique && continue
        push!(clique, current)

        for neighbor in get(bot_graph, bot, [])
            neighbor ∈ clique && continue
            push!(stack, neighbor)
        end
    end
    return clique
end

"""
    distance_from_origin((; position, range)::NanoBot)

Return the minimum distance of a given `NanoBot`s sensor range from the
origin.
"""
function distance_from_origin((; position, range)::NanoBot)
    return distance(position, (0, 0, 0)) - range
end

"""
    part2(input)

Begin by identifying the largest 'clique' of `NanoBot`s, that is, a group of
bots who are all mutually in range of one another. This cluster of bots will
contain the region where most sensor ranges overlap. Then, calculate and
return the minimum sensor range of the furthest bot from the origin, which
represents the distance to the closest point contained in the maximal sensor
overlap.
"""
function part2(input)
    bot_graph = build_bot_graph(input)
    clique    = largest_clique(input, bot_graph)
    return maximum(distance_from_origin, clique)
end
