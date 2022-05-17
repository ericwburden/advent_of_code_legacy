"""
    is_sensor_active(depth, range, start_time)

Given a layer depth, the range of its sensor, and the time you started
across the firewall, indicates whether the sensor is active at position
`0` in the sensor's range. 
"""
function is_sensor_active(depth, range, start_time)
    return (depth + start_time) % (2 * range - 2) == 0
end

"""
    severity_at_time(firewall, start_time=0)

Assuming you start across the `firewall` at time `start_time`, returns a 
value indicating the 'severity' of the trip. Each layer whose sensor catches
you as you traverse the firewall contributes to severity its depth * range.
"""
function severity_at_time(firewall, start_time = 0)
    total_severity = 0

    for (index, range) in enumerate(firewall)
        isnothing(range) && continue
        depth = index - 1
        if is_sensor_active(depth, range, start_time)
            severity = depth * range
            println("Caught at $depth, adding severity $severity")
            total_severity += severity
        end
    end

    return total_severity
end

"Traverse the firewall, returning the severity of the trip"
part1(input) = severity_at_time(input)
