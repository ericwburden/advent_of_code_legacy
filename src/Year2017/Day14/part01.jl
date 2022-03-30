# Needed for the Knot Hash
include("../Day10/Day10.jl")

# Helper functions to get a Knot Hash and convert it to a BitVector
knot_hash(str)   = Day10.part2(str)
hex2bits(hex)    = join(bitstring(byte) for byte in hex2bytes(hex))
seq2hash(str, n) = knot_hash("$str-$n")
seq2bits(str, n) = [b == '1' for b in seq_hash(str, n) |> hex2bits |> collect]
    
"""
    part1(input)

Given the input string, sequentially hash it and return the total number
of bits in the result.
"""
function part1(input)
    bitify(n) = seq2bits(input, n)
    all_bits = mapreduce(bitify, vcat, 0:127)
    return count(all_bits)
end

