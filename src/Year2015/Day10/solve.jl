using IterTools: iterated, nth

# Today's input is a constant value
const input = 1321131112


"""
    rle(arr)

Run length encodes an iterable `arr`, returning a vector where the values
alternate between the run length and the value. For example, [1, 1, 1, 2, 2] ->
[3, 1, 2, 2].
"""
function rle(arr)
    runlength = 0
    current = arr[1]
    output = []

    for item in arr
        if item == current
            runlength += 1
        else
            push!(output, runlength, current)
            current = item
            runlength = 1
        end
    end
    push!(output, runlength, current)

    return output
end


"""
    solve(input, rounds)

Given the input as an integer, repeatedly run length encode the input `rounds`
times and return the length of the final result.
"""
function solve(input, rounds)
    encoded(x) = iterated(rle, x)
    takelast(x) = nth(x, rounds + 1)
    input |> digits |> reverse |> encoded |> takelast |> length
end
