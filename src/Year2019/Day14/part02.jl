"Produce this much"
const ONE_TRILLION = 1_000_000_000_000

"""
    part2(input) -> Int

Binary search for the most "FUEL" that can be produced from 
`ONE_TRILLION` "ORE" and return that amount.
"""
function part2(input)
    low = 0
    high = ONE_TRILLION

    while low <= high
        guess = (low + high) ÷ 2
        cost = cost_of(input, "FUEL", guess)
        cost == ONE_TRILLION && return guess
        cost > ONE_TRILLION && (high = guess - 1)
        cost < ONE_TRILLION && (low = guess + 1)
    end
    return low - 1
end
