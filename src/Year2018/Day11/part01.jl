"Get the hundreds digit of a number"
hundreds_digit(n::Int) = (n ÷ 100) % 10

"""
    power(serial_number::Int, idx::CartesianIndex)

Calculate the power level of a particular fuel cell based on its index
and the serial number of the grid of fuel cells.
"""
function power(serial_number::Int, idx::CartesianIndex)
    x, y = Tuple(idx)
    rack_id = x + 10
    power_level = rack_id * y
    power_level += serial_number
    power_level *= rack_id
    power_level = hundreds_digit(power_level)
    power_level -= 5
    return power_level
end

"""
A `FuelBank` represents the grid of fuel cells, including the power level
of each fuel cell and a summed area table for calculating the power level
of a group (or segment) of fuel cells.
"""
struct FuelBank
    cells::Matrix{Int}
    area_sums::Matrix{Int}
end

"Constructor for a `FuelBank` based on serial number and grid size."
function FuelBank(serial_number::Int, size::Int)
    cells = zeros(Int, size, size)
    power!(idx) = setindex!(cells, power(serial_number, idx), idx)
    foreach(power!, CartesianIndices(cells))

    (area_sums = cells |> (x -> cumsum(x, dims = 1)) |> (x -> cumsum(x, dims = 2)))

    return FuelBank(cells, area_sums)
end

"""
    segment_power((; area_sums)::FuelBank, idx::CartesianIndex, size::Int=3)

Calculate the power of a group (or segment) of fuel cells whose top left
corner is at `idx` of size `size`. For example, a size of 3 calculates the
total power of a 3x3 group of fuel cells with the fuel cell at `idx` in the
top left corner of that square.
"""
function segment_power((; area_sums)::FuelBank, idx::CartesianIndex, size::Int = 3)
    lower_right = get(area_sums, idx + CartesianIndex(size - 1, size - 1), 0)
    upper_right = get(area_sums, idx + CartesianIndex(-1, size - 1), 0)
    lower_left = get(area_sums, idx + CartesianIndex(size - 1, -1), 0)
    upper_left = get(area_sums, idx + CartesianIndex(-1, -1), 0)

    return lower_right + upper_left - upper_right - lower_left
end

"""
    part1(input)

Given the input as an integer representing the serial number of the fuel cell grid, 
identify the fuel cell at the top left of a 3x3 segment that has the largest
total power output, and return a string indicating the location of that
fuel cell.
"""
function part1(input)
    # Fill a grid with the power of each fuel cell
    fuel_bank = FuelBank(input, 300)

    # For each 3x3 block, fill a grid with the aggregate power of each
    # block, in what would be the top-left coordinate for each.
    grouped_power = zeros(Int, 298, 298)
    segment!(idx) = setindex!(grouped_power, segment_power(fuel_bank, idx), idx)
    foreach(segment!, CartesianIndices(grouped_power))

    # Format the output.
    _, max_idx = findmax(grouped_power)
    x, y = Tuple(max_idx)
    return "$x,$y"
end
