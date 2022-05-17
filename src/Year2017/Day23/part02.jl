"""
    primes_in_range(start::Int, stop::Int)

Return a list of the prime numbers in the range from `start` to `stop`.
"""
function primes_in_range(start::Int, stop::Int)
    numbers = collect(1:stop)
    primes = trues(stop)

    # Run a prime sieve from 1 to `stop`
    for n in numbers[2:end]
        primes[n] || continue
        for check = (n*2):n:stop
            primes[check] = false
        end
    end

    # Use these views to return only primes in the range from `start` to `stop`
    prime_mask = @view primes[start:stop]
    number_range = @view numbers[start:stop]
    return number_range[prime_mask]
end

"""
    part2(input)

Part 2's puzzle is really another input analysis problem. A really good
explanation (according to me) can be found here:
https://todd.ginsberg.com/post/advent-of-code/2017/day23/
"""
function part2()
    start = (79 * 100) + 100_000
    stop = start + 17_000
    prime_set = Base.Set(primes_in_range(start, stop))
    non_primes = 0
    for number = start:17:stop
        number ∈ prime_set && continue
        non_primes += 1
    end
    return non_primes
end
