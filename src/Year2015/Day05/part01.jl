#= Regular Expressions ---------------------------------------------------------
| These regular expressions are used to determine whether a given string is
| 'nice' according to the puzzle rules. They match as follows:
| - VOWELS_RE matches any string that contains at least three vowels
| - DOUBLE_RE matches any string that contains a pair of sequential letters
| - EXCLUDE_RE matches any string containing 'ab' or 'cd' or 'pq' or 'xy'
------------------------------------------------------------------------------=#
const VOWELS_RE = r".*([aeiou].*){3}"
const DOUBLE_RE = r"([a-z])\1"
const EXCLUDE_RE = r"ab|cd|pq|xy"

"""
    isnice1(s::String)

Given a String `s`, return true if the string contains at least three vowels, 
one pair of repeated sequential letters (like 'aa'), and does not contain 'ab' 
or 'cd' or 'pq' or 'xy'.
"""
isnice1(s::String) =
    contains(s, VOWELS_RE) && contains(s, DOUBLE_RE) && !contains(s, EXCLUDE_RE)


"""
    part1(input)

Given the input as a list of strings, count the number of strings that return
`true` for `isnice1()`.
"""
function part1(input)
    count(isnice1, input)
end
