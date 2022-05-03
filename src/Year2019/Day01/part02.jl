"""
    recursive_fuel_cost(mass)

Recursively calculate fuel cost, taking into account the extra mass of the
fuel added per module mass. 
"""
function recursive_fuel_cost(mass)
    fuel = (mass ÷ 3) - 2
    fuel > 0 || return 0
    return fuel + recursive_fuel_cost(fuel)
end

"Return the sum of recursive fuel costs"
part2(input) = sum(recursive_fuel_cost(m) for m in input)
