#= Regular Expressions ---------------------------------------------------------
| These regular expressions are used to determine whether a given string is
| 'nice' according to the puzzle rules. They match as follows:
| - REPEATED_PAIR_RE matches any string that contains a combination of any
|   two sequential letters in the string twice, non-overlapping. For example, 
|   'xyxy' would match, 'xxx' would not.
| - SPLIT_TRIPLET_RE matches any string that contains a pair of matching letters
|   to either side of a single, intervening letter. For example, 'xyx'.
------------------------------------------------------------------------------=#
const REPEATED_PAIR_RE = r"([a-z]{2})[a-z]*\1"
const SPLIT_TRIPLET_RE = r"([a-z])[a-z]\1"

"""
    isnice1(s::String)

Given a String `s`, return true if the string contains at least two instances of
any letter pair and at least one instance of a 'split triplet'. See the comments
for the regular expressions in this file for more details.
"""
isnice2(s::String) = contains(s, REPEATED_PAIR_RE) &&
                     contains(s, SPLIT_TRIPLET_RE)

"""
    part2(input)

Given the input as a list of strings, count the number of strings that return
`true` for `isnice2()`.
"""
function part2(input)
    count(isnice2, input)
end
