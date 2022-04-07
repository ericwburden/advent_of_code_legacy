"""
    part2(input)

Given the input as a sorted list of `Moment`s, convert `Moment`s to 
`AsctivityPeriods`, identify the guard who most regularly slept on the same
minute, and return the product of that guard's ID and the identified minute.
"""
function part2(input)
    activity_periods = convert(ActivityPeriods, input)
    max_sleep_times  = 0
    max_sleep_minute = 0
    max_sleep_guard  = nothing
    for (guard, activities) in activity_periods
        minute, times_slept = get_sleepiest_minute(activities)
        if times_slept > max_sleep_times
            max_sleep_times = times_slept
            max_sleep_minute = minute
            max_sleep_guard = guard
        end
    end
    return max_sleep_guard * max_sleep_minute
end
