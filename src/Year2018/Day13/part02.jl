"""
    part2(input)

Given the input in the form of the railway map and a list of the carts, simulate
cart movement over the tracks, crashing and removing carts until only one cart
remains. Return the position of the last cart at the end of the tick that leaves
it as the lone remaining cart.
"""
function part2(input)
    rail_map, carts = deepcopy(input)
    cart_map = Dict([c.location => c.id for c in carts])

    while true
        # Need to sort each time, since cart movement is based on cart
        # sort order.
        sort!(carts)

        # Each 'tick', identify the set of carts that
        # crash during that tick
        crashed_carts = Set()

        for (idx, cart) in enumerate(carts)
            # Remove `cart`'s old location from the map and
            # update the cart in the list with its new location
            delete!(cart_map, cart.location)
            carts[idx] = tick(cart, rail_map[cart.location])
            location = carts[idx].location

            # If `cart` got moved into a space with a cart already
            # there, remove that location from the map of cart locations
            # and add both cart ids to the set of carts to be cleaned up
            if location ∈ keys(cart_map)
                push!(crashed_carts, cart.id)
                push!(crashed_carts, cart_map[location])
                delete!(cart_map, location)
            else
                cart_map[location] = cart.id
            end
        end # cart in carts

        filter!(c -> c.id ∉ crashed_carts, carts) # Removed crashed carts

        # When there is only one cart left, return a string representing
        # its location, in 0-indexed, x,y coordinates.
        if length(carts) == 1
            location = first(carts).location
            row, col = Tuple(location + CartesianIndex(-1, -1))
            return "$col,$row"
        end
    end # Infinite Loop
end
