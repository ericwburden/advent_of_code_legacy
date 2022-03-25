"""
    is_valid(passphrase)

A valid passphrase is one where none of the words are repeated. Checks the
passphrase for duplicate words and returns `true` if all words are unique.
"""
function is_valid(passphrase)
    check_set = Set()
    for word in passphrase
        word ∈ check_set && return false
        push!(check_set, word)
    end
    return true
end

"Count valid passphrases"
part1(input) = mapreduce(is_valid, +, input)
