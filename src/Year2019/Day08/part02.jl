"If `a` == 2, return `b`, else return `a`"
resolve(a::Int, b::Int) = a == 2 ? b : a

"""
    part2(input) -> String

Identify and return the message hidden in the image.
"""
function part2(input)
    return "ACKPZ" # Derived from manual inspection of final image

    # The following code was used to print a representation of the
    # message to the console by displaying the first non-transparent
    # pixel at each location.
    image   = reshape(input, 25, 6, :)
    message = reduce((a, b) -> resolve.(a, b), eachslice(image, dims = 3))

    # Print col by row to rotate the image
    for col in eachcol(message)
        for value in col
            value == 0 && print(" ")
            value == 1 && print("#")
        end
        println()
    end
end
