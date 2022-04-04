"""
    part2(input, itrs=18)

Given the input, and a number of iterations, 'enhance' the default image `itrs`
times and return the number of lit pixels. Exactly the same as part 1, just
with 18 iterations instead of 5.
"""
function part2(input, itrs=18)
    pixels = [0 1 0; 0 0 1; 1 1 1] .== 1
    moar_pixels = make_n_replacements(input, pixels, itrs)
    return count(moar_pixels)
end