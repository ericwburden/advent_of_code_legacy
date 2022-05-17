"""
    find_cycle(dancers, moves)

Given a list of dancers (characters) and moves, identify a cycle in the
dancer configurations after performing all the moves, assuming there is
one. Return a tuple containing the first round the repeated configuration
is seen and the number of rounds it takes to repeat it.
"""
function find_cycle(dancers, moves)
    seen = Dict()
    rounds = 0
    move!(move) = execute!(dancers, move)

    while dancers ∉ keys(seen)
        rounds += 1
        seen[[dancers...]] = rounds
        foreach(move!, moves)
    end

    return (seen[dancers], rounds)
end


"""
    part2(moves)

Given a list of moves, identify the final configuration of dancers if the 
moves were to be performed 1 billion times, total. This solution depends
on there being a cycle in the dancer configurations, such that not all
1 billion rounds need to be performed.
"""
function part2(moves)
    dancers = collect("abcdefghijklmnop")
    cycle_start, cycle_length = find_cycle([dancers...], moves)
    total_dances = 1_000_000_000
    move!(move) = execute!(dancers, move)

    # Need to get the dancers to the state where the cycling starts
    for _ = 1:(cycle_start-1)
        foreach(move!, moves)
    end

    # Determine how many rounds of dance would be left if as many 
    # full cycles were performed without passing `total_dances`.
    total_dances -= (cycle_start - 1)
    dances_left = total_dances % cycle_length

    # Perform the remaining rounds
    for _ = 1:dances_left
        foreach(move!, moves)
    end

    return join(dancers)
end
