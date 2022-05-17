"Just gets the magnitude of a 3-tuple"
magnitude(x::NTuple{3,Int}) = sum(abs.(x))

"""
    accelerate_away_rounds(p::Particle)

Determine how many rounds it takes for a given particle to begin accelerating
away from the origin in all dimensions. This is accomplished by comparing
the signs of the acceleration vector to the signs of the velocity vector, and,
where the two do not match, determining how many rounds the acceleration would
need to be applied to make them match (meaning the particle is moving in the
direction of its acceleration). The largest among all three dimensions indicates
how many 'rounds' it would take for the particle to be moving in the direction
of its acceleration in all three dimensions.
"""
function accelerate_away_rounds(p::Particle)
    vel_accel_pairs = collect(zip(p.velocity, p.acceleration))
    accel_gt_zero = filter(x -> x[2] != 0, vel_accel_pairs)
    diff_signs = filter(x -> (x[1] ⊻ x[2]) < 0, accel_gt_zero)
    rounds_to_correct = map(x -> abs(ceil(Int, x[1] / x[2])), diff_signs)
    return maximum(rounds_to_correct, init = 0)
end

"""
    part1(input)

CAUTION: This solution may not work for all inputs.

Given a set of particles, first filter the particles to those with the smallest
absolute acceleration across all three dimensions. In the long run. the particle
closest to the origin must be one of these.

Then, determine how many rounds it will take for the velocity vector of each
particle to match the direction of its acceleration vector (all three dimensions
have the same sign). In my case, there was one particle that took longer to do 
this than any other, which was the correct answer.

If multiple particles matched in the number of round it took for velocity to 
match signs with acceleration, then you could repeat with position and velocity,
to determine which particle took the longest to have their position vector signs
match their velocity vector signs. 

Finally, if two particles took the same amount of time to match positon and 
velocity signs, then the particle closest to the origin after that many rounds
would be the right answer.
"""
function part1(input)
    min_acceleration = minimum(p -> magnitude(p.acceleration), input)
    has_min_acceleration(p) = magnitude(p.acceleration) == min_acceleration
    min_accel_points = filter(has_min_acceleration, input)

    rounds_to_match_accel = map(accelerate_away_rounds, min_accel_points)
    max_rounds_to_cross = maximum(rounds_to_match_accel)
    last_to_cross = min_accel_points[rounds_to_cross_origin.==max_rounds_to_cross]

    # For my input, stopping here works.

    return last_to_cross.index
end
