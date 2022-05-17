"""
    LetterFreq(letter::Char, freq::Int)

Represents a letter in an input string and the number of times it is found. I'm
using this instead of a Tuple to make it easier to define custom sorting logic.
"""
struct LetterFreq
    letter::Char
    freq::Int
end
LetterFreq(p::Pair{Char,Int}) = LetterFreq(p[1], p[2])

"""
    letter_frequencies(s::AbstractString)

Given a string, return a list of `LetterFreq`s representing the number of times
each letter is found in the input, ignoring all instances of '-'. 
"""
function letter_frequencies(s::AbstractString)
    temp = Dict{Char,Int}()
    for c in s
        c == '-' && continue
        count = get!(temp, c, 0)
        temp[c] = count + 1
    end
    return map(LetterFreq, collect(temp))
end

"For sorting `LetterFreq`s"
Base.isless(a::LetterFreq, b::LetterFreq) =
    a.freq == b.freq ? a.letter < b.letter : b.freq < a.freq

"""
    check(room::RoomDesignation)

Check a room, generating a checksum according to the rules in the puzzle and 
comparing it to the checksum provided. Return `true` if they match, otherwise
`false`.
"""
function check(room::RoomDesignation)
    just_letters(x) = map(lf -> lf.letter, x)
    take_five(x) = x[1:5]
    (
        generated_checksum =
            room.encrypted_name |>
            letter_frequencies |>
            sort |>
            just_letters |>
            take_five |>
            join
    )
    return generated_checksum == room.checksum
end

"""
    part1(input)

Given the input as a list of `RoomDesignation`s, determine which ones are valid
via the checksums and return the sum of their `sector_id`s.
"""
function part1(input)
    valid_rooms = filter(check, input)
    sector_ids = map(rd -> rd.sector_id, valid_rooms)
    return sum(sector_ids)
end
