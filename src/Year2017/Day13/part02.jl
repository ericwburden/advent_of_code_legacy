"""
    can_sneak_through_at_time(firewall, start_time=0)

Assuming you start across the firewall at `start_time`, return true if
you are able to make it all the way across without encountering a sensor. 
Short-circuits whenever a sensor is encountered, returning false.
"""
function can_sneak_through_at_time(firewall, start_time=0)
    for (index, range) in enumerate(firewall)
        isnothing(range) && continue
        depth = index - 1
        is_sensor_active(depth, range, start_time) && return false
    end

    return true
end

"""
    part2(input)

Starting at time `0`, check to see if you can safely traverse the firewall. 
Keep sequentially checking start times until a safe time to cross is found,
and return that time.
"""
function part2(input)
    start_time = 0
    while !can_sneak_through_at_time(input, start_time) 
        start_time += 1
    end
    return start_time
end
