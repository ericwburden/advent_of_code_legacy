# I came to this number by checking the presents/house number ratio for a 
# variety of houses in the 100-400 range, noting that this ratio tended to 
# hover around 23. To give some margin for error, I decided to divide the 
# `INPUT` by 20 and check that, which seemed plenty large enough. This was
# borne out by the results :D
"How many houses to check for the answer?"
const MAX_HOUSES = INPUT ÷ 20

"""
    part1(input)

Given the input as a number representing a minimum number of presents to 
deliver, identify the lowest house number that will recieve _at least_ `input`
presents. The number of presents delivered by each elf is as described in the
puzzle input. This function uses a version of a *Sieve of Erastosthenes* to
calculate the number of presents delivered to each house in the range.
"""
function part1(input)
    presents = ones(Int, MAX_HOUSES)

    for elf = 2:MAX_HOUSES
        for house = elf:elf:MAX_HOUSES
            presents[house] += elf * 10
        end
    end

    result = findfirst(x -> x >= input, presents)
    isnothing(result) && error("Did not check enough houses!")
    return result
end
