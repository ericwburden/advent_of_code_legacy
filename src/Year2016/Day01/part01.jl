abstract type AbstractDirection end
struct North <: AbstractDirection end
struct East  <: AbstractDirection end
struct South <: AbstractDirection end
struct West  <: AbstractDirection end

const Location = Tuple{Int,Int}

turn(::Type{North}, ::Right) = East
turn(::Type{East},  ::Right) = South
turn(::Type{South}, ::Right) = West
turn(::Type{West},  ::Right) = North

turn(::Type{North}, ::Left) = West
turn(::Type{East},  ::Left) = North
turn(::Type{South}, ::Left) = East
turn(::Type{West},  ::Left) = South

move(::Type{North}, distance::Int, location::Location) = location .+ (distance, 0)
move(::Type{East},  distance::Int, location::Location) = location .+ (0, distance)
move(::Type{South}, distance::Int, location::Location) = location .- (distance, 0)
move(::Type{West},  distance::Int, location::Location) = location .- (0, distance)

distance(location::Location) = sum(abs.(location))

function part1(input)
    heading  = North
    location = (0, 0)
    for direction in input
        heading  = turn(heading, direction)
        location = move(heading, direction.distance, location)
    end
    return distance(location)
end
