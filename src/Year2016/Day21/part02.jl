using Combinatorics: permutations

const SCRAMBLED = "fbgdceah"

"""
    part2(input)

Given the input as a list of functions that perform in place transformations of
a Char vector, apply each transformation to a permutation of the letters in the
scrambled password and check if the scrambled password is produced. Return the 
arrangement of letters that produces the scrambled password when all the 
transformations are applied. 
"""
function part2(input)
    chars = collect(SCRAMBLED)

    # Theoretically, I could have written functions to reverse the operations
    # for each type of closure instead of using this brute-force method. But,
    # brute-force gives the right answer in a reasonable amount of time for 
    # solving the puzzle, so meh.
    for permutation in permutations(sort(chars))
        result = deepcopy(permutation)
        for fn in input
            fn(result)
        end
        result == chars && return join(permutation)
    end
    error("Could not crack password!")
end
