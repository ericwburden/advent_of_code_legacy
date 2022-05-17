"""
    part1(input) -> Int

Given the input as a list of integers, reshape the list into a 3-d array with
dimensions that correspond to width, height, and layer. Search each layer to 
find the layer with the fewest zeroes, then return the number of ones multiplied
by the number of twos on that layer.
"""
function part1(input)
    image = reshape(input, 25, 6, :)
    layer = argmin(l -> count(v -> v == 0, l), eachslice(image, dims = 3))
    ones = count(v -> v == 1, layer)
    twos = count(v -> v == 2, layer)
    return ones * twos
end
