function boost!((; groups)::Battlefield, amt::Int)
    for group in values(groups)
        group.team == ImmuneSystem || continue
        group.attack += amt
    end
end

function identify_winner((; groups)::Battlefield)
    immune_system = 0
    infection     = 0
    for group in values(groups)
        group.units > 0 || continue
        group.team == ImmuneSystem && (immune_system += 1)
        group.team == Infection    && (infection     += 1)
    end
    immune_system > 0 && infection > 0 && return nothing
    infection > 0 && return Infection
    return ImmuneSystem
end

"""
    part2(input)

Repeatedly simulate the battle, boosting the immune system increasingly until
an Immune System victory is achieved. Return the number of remaining Immune
System units at the end of the slimmest victory.
"""
function part2(input)
    boost_amt  = 1
    winner     = nothing
    units_left = 0

    while winner != ImmuneSystem
        battlefield = Battlefield(input)
        boost!(battlefield, boost_amt)

        # Sometimes, the battle can deadlock if two units are left that are immune
        # to each others' damage. This 'safety switch' of keeping track of rounds
        # lets the simulate end if a stalemate is reached. There are better ways
        # of detecting and responding to stalemates, but I'm so close to Day 25!
        rounds = 0
        while fight!(battlefield) 
            rounds += 1
            rounds > 10_000 && break
        end

        winner     = identify_winner(battlefield)
        units_left = total_units(battlefield)
        boost_amt += 1
    end

    return units_left
end
