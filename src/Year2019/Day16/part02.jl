"""
    part2(input, phases=100)

Given the input as a vector of integers representing _a part_ of the input
signal, calculate and return the eight digits (as a String) immediately 
following the offset index encoded into the input signal.
"""
function part2(input, phases=100)
    # Take the offset as the value of the first seven digits, plus one
    offset = sum(input[k]*10^(7-k) for k in 1:7) + 1

    # Produce a signal vector containing the initial values from
    # `offset` to the end of the signal (if repeated 10_000 times).
    # Values from the beginning up to `offset` can be ignored, since
    # they will be 'mixed' with a value of `0` because of the way
    # the patterns are generated.
    signal_length = 10_000 * length(input)
    signal = [input[((i - 1) % length(input)) + 1] for i in offset:signal_length]

    # Using a DP approach to calculate each digit in the next phase
    # of the signal. Because of the way the patterns are generated,
    # we can assume each of these values will be mixed with a `1`, so
    # that the value in each index will be the sum of the values from
    # that index to the end of the signal. Here, we essentially do a 
    # 'scan' operation from the end of the signal array back toward
    # the beginning, maintaining the total value observed in `carry`
    # and producing a digit at each index.
    for _ in 1:phases
        carry = 0
        for idx in length(signal):-1:1
            carry += signal[idx]
            signal[idx] = abs(carry % 10)
        end
    end

    return parse(Int, join(signal[1:8]))
end
