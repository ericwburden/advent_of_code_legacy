"The input for today's puzzle is a constant String"
const input = "hepxcrrq"

#=------------------------------------------------------------------------------
| These functions are used to test whether a given character array constitutes
| a valid password, meeting all three criteria described in the puzzle. We're
| using a Vector{Char} instead of a String so that we can mutate it in place,
| which should improve performance.
------------------------------------------------------------------------------=#

"Check if `a` contains a restricted character"
isrestricted(a) = a in ['i', 'o', 'l']

"Check if `a`, `b`, and `c` constitute a straight run"
isstraight((a, b, c)) = a <= 'x' && b == a + 1 && c == b + 1

"""
    count_pairs(arr)

Given an iterable collection, count the number of non-overlapping pairs in the
collection and return the count.
"""
function count_pairs(arr)
    idx = 1
    pairs = 0
    while idx < length(arr)
        if arr[idx] == arr[idx+1]
            pairs += 1
            idx += 1
        end
        idx += 1
    end
    return pairs
end


#=------------------------------------------------------------------------------
| Encapsulates the logic for criteria checking into functions for readability
------------------------------------------------------------------------------=#

contains_straight(s) = any(isstraight, zip(s, s[2:end], s[3:end]))
contains_restricted(s) = any(isrestricted, s)
contains_two_pairs(s) = count_pairs(s) > 1

isvalid(s::String) = collect(s) |> isvalid
isvalid(s::Vector{Char}) =
    contains_straight(s) && !contains_restricted(s) && contains_two_pairs(s)


#=------------------------------------------------------------------------------
| Advance to the next password attempt
------------------------------------------------------------------------------=#

"""
    nextpassword!(s)

Given a Vector{Char}, increment the vector by advancing to the next Vector
in order. For example, ['a', 'b'] -> ['a', 'c'] or ['z'] -> ['a', 'a']
"""
function nextpassword!(s)
    idx = findlast(x -> x != 'z', s) # Index of the character to increment
    if isnothing(idx)
        s[:] .= 'a'
        push!(s, 'a')
    else
        s[idx] = s[idx] == 'z' ? 'a' : s[idx] + 1
        if idx < length(s)
            s[idx+1:end] .= 'a'
        end
    end
    return s
end


#=------------------------------------------------------------------------------
| Solve the puzzle
------------------------------------------------------------------------------=#

function solve(input)
    password = collect(input)
    while true
        nextpassword!(password)
        isvalid(password) && return join(password)
    end
end
