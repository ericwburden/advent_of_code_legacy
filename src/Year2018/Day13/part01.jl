"Given an index, return the next index in a given direction"
move_north(idx::CartesianIndex) = idx + CartesianIndex(-1, 0)
move_east(idx::CartesianIndex) = idx + CartesianIndex(0, 1)
move_south(idx::CartesianIndex) = idx + CartesianIndex(1, 0)
move_west(idx::CartesianIndex) = idx + CartesianIndex(0, -1)

"Given a type of turn, return the next type of turn"
next_turn(::Type{TurnLeft}) = Straight
next_turn(::Type{Straight}) = TurnRight
next_turn(::Type{TurnRight}) = TurnLeft

"Given a type of direction and a type of turn, return the next type of direction"
turn_heading(::Type{North}, ::Type{TurnLeft}) = West
turn_heading(::Type{North}, ::Type{Straight}) = North
turn_heading(::Type{North}, ::Type{TurnRight}) = East
turn_heading(::Type{East}, ::Type{TurnLeft}) = North
turn_heading(::Type{East}, ::Type{Straight}) = East
turn_heading(::Type{East}, ::Type{TurnRight}) = South
turn_heading(::Type{South}, ::Type{TurnLeft}) = East
turn_heading(::Type{South}, ::Type{Straight}) = South
turn_heading(::Type{South}, ::Type{TurnRight}) = West
turn_heading(::Type{West}, ::Type{TurnLeft}) = South
turn_heading(::Type{West}, ::Type{Straight}) = West
turn_heading(::Type{West}, ::Type{TurnRight}) = North

"""
    tick(cart::Cart, rail::StraightRail)

Move a cart one space forward, starting on a StraightRail.
"""
function tick(
    (; id, heading, location, turn)::Cart,
    rail::StraightRail{VerticalOrientation},
)
    heading == North && return Cart(id, heading, move_north(location), turn)
    heading == South && return Cart(id, heading, move_south(location), turn)
    error("Cart $id entered $rail moving $(heading)!")
end

function tick(
    (; id, heading, location, turn)::Cart,
    rail::StraightRail{HorizontalOrientation},
)
    heading == East && return Cart(id, heading, move_east(location), turn)
    heading == West && return Cart(id, heading, move_west(location), turn)
    error("Cart $id entered $rail moving $(heading)!")
end


"""
    tick(cart::Cart, rail::Intersection)

Move a cart one space forward, starting on an Intersection. Turn the cart
according to its next turn type before moving it.
"""
function tick((; id, heading, location, turn)::Cart, rail::Intersection)
    new_heading = turn_heading(heading, turn)
    new_heading == North && return Cart(id, North, move_north(location), next_turn(turn))
    new_heading == East && return Cart(id, East, move_east(location), next_turn(turn))
    new_heading == South && return Cart(id, South, move_south(location), next_turn(turn))
    new_heading == West && return Cart(id, West, move_west(location), next_turn(turn))
end

"""
    tick(cart::Cart, rail::CurvedRail)

Move a cart one space forward, starting on a CurvedRail. Turns the cart
according to the current heading of the cart and the type of curve before
moving it.
"""
function tick((; id, heading, location, turn)::Cart, rail::CurvedRail{North,West})
    heading == East && return Cart(id, North, move_north(location), turn)
    heading == South && return Cart(id, West, move_west(location), turn)
    error("Cart $id entered $rail moving $(heading)!")
end

function tick((; id, heading, location, turn)::Cart, rail::CurvedRail{North,East})
    heading == West && return Cart(id, North, move_north(location), turn)
    heading == South && return Cart(id, East, move_east(location), turn)
    error("Cart $id entered $rail moving $(heading)!")
end

function tick((; id, heading, location, turn)::Cart, rail::CurvedRail{South,West})
    heading == East && return Cart(id, South, move_south(location), turn)
    heading == North && return Cart(id, West, move_west(location), turn)
    error("Cart $id entered $rail moving $(heading)!")
end

function tick((; id, heading, location, turn)::Cart, rail::CurvedRail{South,East})
    heading == West && return Cart(id, South, move_south(location), turn)
    heading == North && return Cart(id, East, move_east(location), turn)
    error("Cart $id entered $rail moving $(heading)!")
end


"""
    part1(input)

Given the input in the form of the railway map and a list of the carts, simulate
cart movement over the tracks until a crash occurs, then return a string 
representing the location of the crash.
"""
function part1(input)
    rail_map, carts = input
    cart_locations = Set([c.location for c in carts])

    while true
        # Need to sort each time, since cart movement is based on cart
        # sort order.
        sort!(carts)

        for (idx, cart) in enumerate(carts)
            # Remove `cart`'s old location from the map and
            # update the cart in the list with its new location
            delete!(cart_locations, cart.location)
            carts[idx] = tick(cart, rail_map[cart.location])
            location = carts[idx].location

            # If the cart enters a location where a cart already is,
            # that's a crash. Return the location in zero-indexed, 
            # x-y coordinates.
            if location ∈ cart_locations
                row, col = Tuple(location + CartesianIndex(-1, -1))
                return "$col,$row"
            end

            # If there's no crash, add the cart's new location back
            # to the set of tracked locations.
            push!(cart_locations, location)
        end # cart in carts

    end # Infinite Loop
end
