"""
    groupby(T::Type, f::Function, a::AbstractVector)

Groups the input `a` according to the result of the function `f`, producing
an iterator over groups of type Vector{T}.
"""
function groupby(T::Type, f::Function, a::AbstractVector)
    groups = Dict{Any,Vector{T}}()
    for value in a
        group = get!(groups, f(value), similar(a, 0))
        push!(group, value)
    end
    return values(groups)
end

"""
    increment(p::Particle)

Move a particle forward by one time unit.
"""
function increment((; index, position, velocity, acceleration)::Particle)
    velocity = velocity .+ acceleration
    position = position .+ velocity
    return Particle(index, position, velocity, acceleration)
end


"""
    part2(input)

Simulate particle movement, removing all colliding particles, until the number
of particles stabilizes, then return the number of remaining particles.

Currently using a count of 20 rounds to detect stability, any collisions within
that 20-round buffer will reset the buffer. If the system goes 20 rounds without
a collision, it's considered stable. For my input, it takes 59 rounds for all
collisions to occur.
"""
function part2(input)
    particles  = input
    num_rounds = 20   # Magic Number
    remaining  = num_rounds

    while remaining > 0
        particle_count = length(particles)
        (particles 
            =  particles
            |> (x -> map(increment, x)) 
            |> (x -> groupby(Particle, p -> p.position, x)) 
            |> (x -> Iterators.filter(g -> length(g) == 1, x)) 
            |> (x -> map(first, x)))
        remaining -= 1
        if particle_count > length(particles)
            remaining = num_rounds
        end
    end
    println(total)
    return length(particles)
end
