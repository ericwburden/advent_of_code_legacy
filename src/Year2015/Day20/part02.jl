"""
    part1(input)

Given the input as a number representing a minimum number of presents to 
deliver, identify the lowest house number that will recieve _at least_ `input`
presents. Similar to part 1, but the rules for how many presents and to how
many houses each elf delivers has been modified for part 2.
"""
function part2(input)
    presents = zeros(Int, MAX_HOUSES)
    presents[1:50] .= 1

    for elf in 2:MAX_HOUSES
        for (delivered, house) in enumerate(elf:elf:MAX_HOUSES)
            delivered > 50 && break
            presents[house] += elf * 11
        end
    end

    result = findfirst(x -> x >= input, presents)
    isnothing(result) && error("Did not check enough houses!")
    return result
end