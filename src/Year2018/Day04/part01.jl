"Represents the kind of activity during an ActivityPeriod"
abstract type AbstractActivityKind end
struct Sleeping <: AbstractActivityKind end
struct Awake <: AbstractActivityKind end

"Represents a period of guard activity, with start/stop timestamps"
struct ActivityPeriod{T<:AbstractActivityKind}
    kind::Type{T}
    start::DateTime
    stop::DateTime
end

"List of activity periods per guard"
const ActivityPeriods = Dict{Int,Vector{ActivityPeriod}}

Dates.Minute((; start, stop)::ActivityPeriod) = Minute(stop - start)

"""
    convert(::Type{UnitRange}, (; start, stop)::ActivityPeriod)
    convert(::Type{ActivityPeriod}, moments::Tuple{Moment,Moment})
    convert(::Type{ActivityPeriods}, moments::Vector{Moment})

Type conversions from and for `ActivityPeriod`s
"""
function Base.convert(::Type{UnitRange}, (; start, stop)::ActivityPeriod)
    start_minute = Minute(start).value
    stop_minute = Minute(stop).value - 1  # Exclusive range
    return start_minute:stop_minute
end

function Base.convert(::Type{ActivityPeriod}, moments::Tuple{Moment,Moment})
    (start, event), (stop, _) = moments
    event isa OnDuty && return ActivityPeriod(Awake, start, stop)
    event isa Sleep && return ActivityPeriod(Sleeping, start, stop)
    event isa WakeUp && return ActivityPeriod(Awake, start, stop)
end

function Base.convert(::Type{ActivityPeriods}, moments::Vector{Moment})
    activity_periods = ActivityPeriods()
    current_guard = nothing
    for moment_pair in zip(moments, moments[2:end])
        (_, event), (_, _) = moment_pair
        if (event isa OnDuty)
            current_guard = event.guard
        end
        guard_activities = get!(activity_periods, current_guard, [])
        push!(guard_activities, convert(ActivityPeriod, moment_pair))
    end
    return activity_periods
end

"""
    get_heaviest_sleeper(activity_periods::ActivityPeriods)

Given a dictionary of activity periods by guard, identify the guard who spent
the largest total number of minutes asleep.
"""
function get_heaviest_sleeper(activity_periods::ActivityPeriods)
    rip_van_winkle = nothing
    maximum_sleep = Minute(0)
    for (guard, activities) in activity_periods
        (
            minutes_slept =
                activities |>
                (x -> Iterators.filter(a -> a.kind == Sleeping, x)) |>
                (x -> mapfoldl(Minute, +, x, init = Minute(0)))
        )
        if minutes_slept > maximum_sleep
            rip_van_winkle = guard
            maximum_sleep = minutes_slept
        end
    end
    return rip_van_winkle
end

"""
    get_sleepiest_minute(activities::Vector{ActivityPeriod})

Given a list of activity periods, identify the minute across all days where the
guard was asleep most often.
"""
function get_sleepiest_minute(activities::Vector{ActivityPeriod})
    minutes_slept = Dict()
    max_minutes = 0
    for activity in activities
        activity.kind == Sleeping || continue
        for minute in convert(UnitRange, activity)
            current = get!(minutes_slept, minute, 0)
            minutes_slept[minute] = current + 1
            max_minutes = max(max_minutes, current + 1)
        end
    end

    for (key, value) in minutes_slept
        value == max_minutes && return (key, value)
    end
    return (nothing, 0)
end


"""
    part1(input)

Given the input as a sorted list of `Moment`s, convert `Moment`s to 
`AsctivityPeriods`, identify the guard who slept the most and the minute during
which he was most likely to be asleep, and return the product of the guard's ID
and the minute.
"""
function part1(input)
    activity_periods = convert(ActivityPeriods, input)
    sleepiest_guard = get_heaviest_sleeper(activity_periods)
    sleepiest_minute, _ = get_sleepiest_minute(activity_periods[sleepiest_guard])
    return sleepiest_guard * sleepiest_minute
end
