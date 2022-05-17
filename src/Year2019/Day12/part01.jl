"""
    apply_gravity(a::Moon, b::Moon) -> (Moon, Moon)
    
Given two `Moon`s, apply the gravity from each moon to the other's velocity,
then return the two moons with adjusted velocities. Returns moons in the same
order they were received.
"""
function apply_gravity(a::Moon, b::Moon)
    a_velocity = a.velocity .+ sign.(b.position .- a.position)
    b_velocity = b.velocity .+ sign.(a.position .- b.position)
    a_moon = Moon(a.position, a_velocity)
    b_moon = Moon(b.position, b_velocity)
    return (a_moon, b_moon)
end

"""
    apply_gravity!(moons::Vector{Moon})
    
Modify the velocity of each `Moon` based on its pairwise interactions
with every other moon on the list.
"""
function apply_gravity!(moons::Vector{Moon})
    for a = 1:length(moons), b = a:length(moons)
        moons[a], moons[b] = apply_gravity(moons[a], moons[b])
    end
end

"""
    apply_velocity((; position, velocity)::Moon) -> Moon

Produce a `Moon` that results from moving the input moon according to
its velocity.
"""
function apply_velocity((; position, velocity)::Moon)
    return Moon(position .+ velocity, velocity)
end

"""
    apply_velocity!(moons::Vector{Moon})

Modify the position of each `Moon` based on its velocity.
"""
function apply_velocity!(moons::Vector{Moon})
    for idx = 1:length(moons)
        moons[idx] = apply_velocity(moons[idx])
    end
end

"""
    take_step!(moons::Vector{Moon})

Modify each moon's velocity and position one step forward in time.
"""
function take_step!(moons::Vector{Moon})
    apply_gravity!(moons)
    apply_velocity!(moons)
end

"""
    total_energy((; position, velocity)::Moon) -> Int
    
Return the product of potential and kinetic energy contained in a Moon.
"""
function total_energy((; position, velocity)::Moon)
    return sum(abs.(position)) * sum(abs.(velocity))
end

"""
    part1(input, itrs=1000)

Given a list of `Moon`s as input, take `itrs` steps through time and 
return the total energy of all moonts after `itrs` steps.
"""
function part1(input, itrs = 1000)
    moons = deepcopy(input)
    foreach(_ -> take_step!(moons), 1:itrs)
    return mapreduce(total_energy, +, moons)
end
