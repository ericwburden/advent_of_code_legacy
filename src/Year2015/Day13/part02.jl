"""
    part2!(input)

Given an adjacency matrix, calculate the total happiness for the entire table
for each possible seating arrangement and return the maximum happiness achieved.
This time, we remember to add ourselves to the seating chart with a happiness
change of 0 no matter who we are seated by. This function modifies the input.
"""
function part2!(input)
    for (person, _) in input.keys
        add!(input, ("Self", person, 0))
        add!(input, (person, "Self", 0))
    end
    howhappy(people) = happiness(input, people)
    return mapreduce(howhappy, max, permutations(input))
end
