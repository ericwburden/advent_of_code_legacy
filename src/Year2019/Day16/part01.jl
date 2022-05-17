using IterTools: iterated, nth

"Provided in the puzzle"
const BASE_PATTERN = (0, 1, 0, -1)

# I don't like typing 'Iterators' over and over...
const imap     = Iterators.map
const repeated = Iterators.repeated
const flatten  = Iterators.flatten
const cycle    = Iterators.cycle
const drop     = Iterators.drop
const take     = Iterators.take

"""
    pattern_iter(reps::Int) -> Iterator{Int}

Produces an iterator yielding integers in the pattern described by
the puzzle based on the `BASE_PATTERN`. 
"""
function pattern_iter(reps::Int)
    (BASE_PATTERN
        |> (x -> imap(i -> repeated(i, reps), x))
        |> flatten
        |> cycle
        |> (x -> drop(x, 1)))
end

"""
    fft_digit_at(signal::Vector{Int}, idx::Int) -> Int

Calculate and return the digit obtained by 'FFT' transform at the given
index in from the input signal.
"""
function fft_digit_at(signal::Vector{Int}, idx::Int)
    pattern = pattern_iter(idx)
    total = sum(input * mask for (input, mask) in zip(signal, pattern))
    return abs(total % 10)
end

"""
    next_phase(signal::Vector{Int}) -> Vector{Int}

Calculate and return the next phase of the given signal by identifying
the 'FFT'-transformed digit at each index.
"""
function next_phase(signal::Vector{Int})
    digits = length(signal)
    return [fft_digit_at(signal, d) for d in 1:digits]
end

"""
    part1(input, n=100) -> String
    
Given the input as an integer vector, calculate and return the first eight values 
(as a String) of the signal obtained by processing the `input` `phases` number of
times.
"""
function part1(input, phases=100)
    signal = nth(iterated(next_phase, input), phases+1)
    return join(signal[1:8])
end
