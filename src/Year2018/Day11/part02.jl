"""
    max_segment_power(fuel_bank::FuelBank, idx::CartesianIndex)

Given a fuel bank and the index of a fuel cell within that fuel bank, identify
the maximum power level of a square of any size anchored at that index and 
return that maximum power level and size of the square.
"""
function max_segment_power(fuel_bank::FuelBank, idx::CartesianIndex)
    size_range = 1:minimum(size(fuel_bank.cells) .- Tuple(idx))
    max_size = 1
    max_value = fuel_bank.area_sums[idx]
    for size in size_range
        value = segment_power(fuel_bank, idx, size)
        if value > max_value
            max_size  = size
            max_value = value
        end
    end
    return (max_value, max_size)
end

"""
    part2(input)

Given the input as an integer representing the serial number of the fuel cell grid, 
identify the fuel cell at the top left of a segment that has the largest
total power output, and return a string indicating the location of that
fuel cell and the size of the maximal power segment.
"""
function part2(input)
    # Fill a grid with the power of each fuel cell
    fuel_bank = FuelBank(input, 300)

    # For part two, we need to find the maximum value achievable for a square
    # with a top left at each index, for any size square. Create and fill a 
    # 300x300 grid with (<power>, <size>) values at each index.
    grouped_power = fill((0, 0), 300, 300)
    segment!(idx) = setindex!(grouped_power, max_segment_power(fuel_bank, idx), idx)
    foreach(segment!, CartesianIndices(grouped_power))

    ((_, size), max_idx) = findmax(grouped_power)
    x, y = Tuple(max_idx)
    return "$x,$y,$size"
end
