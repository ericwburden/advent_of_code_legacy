"""
    is_validv2(passphrase)

A valid passphrase is one where each word contains a unique combination of
letters. Returns `true` if each word in the passphrase contains a unique
combination of letters, otherwise `false`.
"""
function is_validv2(passphrase)
    check_set = Set()
    for word in passphrase
        sorted_word = sort!(collect(word))
        sorted_word ∈ check_set && return false
        push!(check_set, sorted_word)
    end
    return true
end

"Count valid passphrases, version 2"
part2(input) = mapreduce(is_validv2, +, input)


