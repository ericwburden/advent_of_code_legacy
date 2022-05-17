using Dates

"Represents each of the three events recorded in the nap log"
abstract type AbstractEvent end
struct OnDuty <: AbstractEvent
    guard::Int
end
struct Sleep <: AbstractEvent end
struct WakeUp <: AbstractEvent end

function Base.parse(::Type{AbstractEvent}, s::AbstractString)
    m = match(r"Guard #(\d+)|(wakes up)|(falls asleep)", s)
    guard, wake, sleep = m.captures
    isnothing(guard) || return OnDuty(parse(Int, guard))
    isnothing(wake) || return WakeUp()
    isnothing(sleep) || return Sleep()
    error("Could not parse \"$s\" into an `AbstractEvent`!")
end

"A `Moment` is an alias for a tuple of timestamp and event."
const Moment = Tuple{DateTime,AbstractEvent}

function Base.parse(::Type{Moment}, s::AbstractString)
    timestamp_str, event_str = match(r"\[([\d\-\s:]+)\] ([\w#\s\d]+)", s).captures
    timestamp = DateTime(timestamp_str, DateFormat("y-m-d H:M"))
    event = parse(AbstractEvent, event_str)
    return (timestamp, event)
end

"Needed for sorting"
Base.isless(a::Moment, b::Moment) = a[1] < b[1]

"Read each line from the input file, parse as a `Moment` and return sorted list"
ingest(path) = sort!([parse(Moment, l) for l in readlines(path)])
