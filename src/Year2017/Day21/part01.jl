using IterTools: iterated, nth

"""
    make_replacements(replacement_map::ReplacementMap, pixels::BitMatrix)

Given a `ReplacementMap` and a `BitMatrix` of pixels, divide the pixels into 
size 2 (or 3) squares and replace each square with its corresponding
replacement from `ReplacementMap`. Returns an 'enhanced' image by stitching
together the replacements into a single `BitMatrix`.
"""
function make_replacements(replacement_map::ReplacementMap, pixels::BitMatrix)
    batch_size = iseven(size(pixels, 1)) ? 2 : 3
    batch_range = 1:batch_size:size(pixels, 1)
    replacements = BitMatrix[]

    for (first_row, first_col) in Iterators.product(batch_range, batch_range)
        last_row, last_col = (first_row, first_col) .+ (batch_size - 1)
        replace = pixels[first_row:last_row, first_col:last_col]
        replacement = get(replacement_map, replace, nothing)
        isnothing(replacement) && error("Cannot replace $replace")
        push!(replacements, replacement)
    end

    row_len = replacements |> length |> sqrt |> Int
    rows = Iterators.partition(replacements, row_len)

    return mapreduce(x -> reduce(vcat, x), hcat, rows)
end

"""
    make_n_replacements(replacement_map::ReplacementMap, pixels::BitMatrix, n::Int)

Given a `ReplacementMap`, a `BitMatrix` of pixels, and a number of replacements
to make, 'enhance' the image `n` times and return the result.
"""
function make_n_replacements(replacement_map::ReplacementMap, pixels::BitMatrix, n::Int)
    replace_with_map(x) = make_replacements(replacement_map, x)
    (result = pixels |> (x -> iterated(replace_with_map, x)) |> (x -> nth(x, n + 1)))
    return result
end

"""
    part1(input, itrs=5)

Given the input, and a number of iterations, 'enhance' the default image `itrs`
times and return the number of lit pixels.
"""
function part1(input, itrs = 5)
    pixels = [0 1 0; 0 0 1; 1 1 1] .== 1
    moar_pixels = make_n_replacements(input, pixels, itrs)
    return count(moar_pixels)
end
