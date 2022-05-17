using Nettle
using DataStructures: CircularBuffer

"""
    Short <: HashingStrategy
    Long  <: HashingStrategy

Part two changes the way hashes are computed, so we'll use an empty struct
to indicate what hashing strategy to use.
"""
abstract type HashingStrategy end
struct Short <: HashingStrategy end
struct Long <: HashingStrategy end

"""
    digest(s::AbstractString, ::Short)

The basic hashing function, using a `Short` hashing strategy just does a 
single-pass MD5 hash.
"""
function digest(s::AbstractString, ::Short)
    return hexdigest("md5", s)
end

"""
    find_triple(s::AbstractString)

Given a string, return the first character to be repeated three times
sequentially, or `nothing` if no three-peating character is found.
"""
function find_triple(s::AbstractString)
    last_idx = length(s) - 2

    for idx = 1:last_idx
        a, b, c = s[idx:idx+2]
        a == b == c && return a
    end

    return nothing
end

"Check if a string contains a run of 5 characters `c`"
contains_quintuple(s::AbstractString, c::Char) = occursin(c^5, s)

"""
    generate_hash_buffer(salt::AbstractString, n::Int, strategy::HashingStrategy)

Generates a `CircularBuffer` of hashes of capacity `n`, using the `strategy`
HashingStrategy to generate the hashes. Each hash consists of the hashed string
derived from concatenating the `salt` and sequential numbers from 0 to `n`.
"""
function generate_hash_buffer(salt::AbstractString, n::Int, strategy::HashingStrategy)
    integers = collect(0:n)
    hash_buffer = CircularBuffer{String}(n)
    add_hash(i) = push!(hash_buffer, digest("$salt$i", strategy))
    foreach(add_hash, integers)
    return hash_buffer
end

"""
    find_keys(salt::AbstractString, search::Int, n::Int, strategy::HashingStrategy)

Each key, according to the puzzle instructions, is a hash with a character
triplet where a hash in the next `search` hashes contains a quintuplet of that
same character. This function searches for these keys sequentially, starting
with the first generated hash until `n` qualifying hashes are found. Hashes 
are generated in accordance with the `stratetgy` hashing strategy. Returns
a vector of (<concatenated integer>, <qualifying hash>).
"""
function find_keys(salt::AbstractString, search::Int, n::Int, strategy::HashingStrategy)
    hash_buffer = generate_hash_buffer(salt, search, strategy)
    next_integer = search
    found_keys = Tuple{Int,String}[]

    while length(found_keys) < n
        hash = popfirst!(hash_buffer)
        triple_char = find_triple(hash)

        if !isnothing(triple_char)
            for other_hash in hash_buffer
                if contains_quintuple(other_hash, triple_char)
                    push!(found_keys, (next_integer - search, hash))
                    break
                end
            end
        end

        push!(hash_buffer, digest("$salt$next_integer", strategy))
        next_integer += 1
    end

    return found_keys
end

"""
    part1(input)

Generate 64 qualifying keys and return the integer that was hashed to produce
the 64th key.
"""
function part1(input)
    keys = find_keys(input, 1000, 64, Short())
    return keys[64][1]
end
