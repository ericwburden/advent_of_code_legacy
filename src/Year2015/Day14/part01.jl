"""
    runseconds(reindeer::Reindeer, seconds::Int)

Given a `Reindeer`, calculate how many secounds out of `seconds` the reindeer
will spend running, assuming the reindeer runs, then rests, then repeats.
"""
function runseconds(reindeer::Reindeer, seconds::Int)
    cycletime = reindeer.runtime + reindeer.resttime
    (cycles, remaining) = divrem(seconds, cycletime)
    partial = min(remaining, reindeer.runtime)

    return (cycles * reindeer.runtime) + partial
end

"""
    traveled(r::Reindeer, s::Int)

Given a `Reindeer` and a number of seconds spent running, return the 
distance traveled during that time.
"""
traveled(r::Reindeer, s::Int) = r.speed * runseconds(r, s)


"""
    part1(input)

Given a list of `Reindeer` as input, determines which reindeer has traveled
the furthest in 2503 seconds (from the puzzle description) and return the 
maximum distance traveled.
"""
function part1(input, time = 2503)
    distance(r) = traveled(r, time)
    mapreduce(distance, max, input)
end
