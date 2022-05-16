"Return the position and velocity of a `Moon` on a given dimension"
dim(moon::Moon, d::Int) = (moon.position[d], moon.velocity[d])

"""
    part2(input) -> BigInt

Given a list of `Moon`s, determine how many cycles it would take for the moons to
return to their starting positions/velocities and return that number.
"""
function part2(input)
    moons = deepcopy(input)

    # Turns out, the x/y/z positions/velocities each cycle independently on
    # much smaller cycles than the system as a whole, so by determining
    # the cycle size of each dimensions, we can calculate the total
    # number of steps to cycle the whole system.
    x_start = map(m -> dim(m, 1), moons)
    y_start = map(m -> dim(m, 2), moons)
    z_start = map(m -> dim(m, 3), moons)
    x_cycle = y_cycle = z_cycle = nothing
    steps = 0

    # Keep checking until a cycle is found for all three dimensions...
    while any(isnothing, (x_cycle, y_cycle, z_cycle))
        steps += 1
        take_step!(moons)
        isnothing(x_cycle) && map(m -> dim(m, 1), moons) == x_start && (x_cycle = steps)
        isnothing(y_cycle) && map(m -> dim(m, 2), moons) == y_start && (y_cycle = steps)
        isnothing(z_cycle) && map(m -> dim(m, 3), moons) == z_start && (z_cycle = steps)
    end

    # The least common multiple of each dimension cycle is the
    # size of the overall cycle.
    return lcm(x_cycle, y_cycle, z_cycle)
end

