"""
    part1(input)

Calculate and return the total fuel cost for all modules, based on mass.
"""
function part1(input)
    fuel_cost(m) = (m ÷ 3) - 2
    return sum(fuel_cost(m) for m in input)
end
