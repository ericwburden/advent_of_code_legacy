#=------------------------------------------------------------------------------
| Now we need to individually track each Reindeer's position at every point in 
| time, since each second a point is awarded to the Reindeer in the lead. We'll
| use the `Racer` structs to wrap each Reindeer and attach additional data
| related to their current position and activity (running vs resting).
------------------------------------------------------------------------------=#

"Supertype from which the Reindeer in the race derive"
abstract type Racer end

"""
Represents a Reindeer in the race who is currently running, with the following
fields:
    - reindeer::Reindeer - The reindeer who is in the race
    - distance::Int - The distance the reindeer has traveled
    - timeleft::Int - The number of additional seconds this reindeer can
        run before it needs to rest again
"""
struct RunningDeer <: Racer
    reindeer::Reindeer
    distance::Int
    timeleft::Int
end
RunningDeer(r::Reindeer) = RunningDeer(r, 0, r.runtime)

"""
Represents a Reindeer in the race who is currently resting, with the following
fields:
    - reindeer::Reindeer - The reindeer who is in the race
    - distance::Int - The distance the reindeer has traveled
    - timeleft::Int - The number of additional seconds this reindeer needs
        to rest before it can run again.
"""
struct RestingDeer <: Racer
    reindeer::Reindeer
    distance::Int
    timeleft::Int
end
RestingDeer(r::Reindeer) = RestingDeer(r, 0, r.resttime)


#=------------------------------------------------------------------------------
| The `advance` function serves as a group of methods to move the entire 
| state of the race forward by one second. Methods exist for the state
| of the entire race, for a pair of Racer => score, and for each type
| of Racer
------------------------------------------------------------------------------=#

"""
    advance((; reindeer, distance, timeleft)::RunningDeer)

Given a `RunningDeer`, return its state one second in the future. If the 
`RunningDeer` had 0 seconds left of running time, returns a `RestingDeer`.
"""
function advance((; reindeer, distance, timeleft)::RunningDeer)
    distance += reindeer.speed
    timeleft -= 1
    timeleft > 0 && return RunningDeer(reindeer, distance, timeleft)

    return RestingDeer(
        reindeer,
        distance,
        reindeer.resttime
    )
end

"""
    advance((; reindeer, distance, timeleft)::RestingDeer)

Given a `RestingDeer`, return its state one second in the future. If the 
`RestingDeer` had 0 seconds left of resting time, returns a `RunningDeer`.
"""
function advance((; reindeer, distance, timeleft)::RestingDeer)
    timeleft -= 1
    timeleft > 0 && return RestingDeer(reindeer, distance, timeleft)

    return RunningDeer(
        reindeer,
        distance,
        reindeer.runtime
    )
end

"""
    advance(p::Pair{Racer,Int})

Given a pair of `Racer` => Int, return the pair with the Racer advanced to the
next state and the integer (the racer's current score) unchanged.
"""
advance(p::Pair{Racer,Int}) = advance(p[1]) => p[2]

"""
    advance(state::RaceState)

Given a `RaceState` (defined as a `Vector{Pair{Racer,Int}}`), iterate over
each pair of racer and score, advancing each racer by one second. Then the
racers in the lead are identified an awarded one point each. Returns the
new state of the race.
"""
const RaceState = Vector{Pair{Racer,Int}}
function advance(state::RaceState)
    racers = map(advance, state) |> RaceState
    leaders = findleaders(racers)

    for ((leader, score), idx) in leaders
        racers[idx] = leader => score + 1
    end

    return RaceState(racers)
end

"""
    findleaders(racestate::RaceState)

Given a `RaceState`, identify which racers have traveled the furthest and
return `Leaders` (defined as a `Vector{Tuple{Pair{Racer,Int},Int}`), a list
of the leading racer pairs and their indices in the `RaceState`.
"""
const Leaders = Vector{Tuple{Pair{Racer,Int},Int}}
function findleaders(racestate::RaceState)
    leaders = Leaders()
    max = typemin(Int)

    for (idx, (racer, score)) in enumerate(racestate)
        if racer.distance > max
            leaders = Leaders([(racer => score, idx)])
            max = racer.distance
        end
        if racer.distance == max
            push!(leaders, (racer => score, idx))
        end
    end
    return leaders
end


"""
    part2(input, time=2503)

Given the input as a list of `Reindeer`, conduct the race! Each second, award
one point to each reindeer in the lead and return the maximum score achieved
at the end of the race.
"""
function part2(input, time=2503)
    racestate = RaceState([RunningDeer(r) => 0 for r in input])
    for _ in 1:time
        racestate = advance(racestate)
    end
    
    getscores(rs) = map(x -> x.second, rs)
    winning_score = (maximum ∘ getscores)(racestate)

    return winning_score
end
