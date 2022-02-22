"""
    rotate(ch::Char, amount::Int)

Given a character to rotate and a number of letters to rotate it by (`amount`),
move the letter forward through the alphabet that many times, wrapping from 
'z' to 'a' as many times as needed. Only works for lowercase letters, does
not change case.
"""
function rotate(ch::Char, amount::Int)
    ch == '-' && return ' '
    rotated = ch + (amount % 26)
    return rotated > 'z' ? rotated - 26 : rotated
end

"""
    decrypt(room::RoomDesignation)

Decrypts a room's name and returns a tuple of the decrypted name and the
original `RoomDesignation`.
"""
function decrypt(room::RoomDesignation)
    rotate_name(s) = map(c -> rotate(c, room.sector_id), s)
    return (rotate_name(room.encrypted_name), room)
end

"""
    part2(input)

Given the input as a list of `RoomDesignation`s, filter out the invalid rooms,
decrypt the remaining room names, identify the room where the North Pole
contraband is being held, then return that room's sector_id.
"""
function part2(input)
    valid_rooms = filter(check, input)
    decrypted   = map(decrypt, valid_rooms)
    contraband  = filter(s -> occursin("northpole", s[1]), decrypted)
    return first(contraband)[2].sector_id
end
