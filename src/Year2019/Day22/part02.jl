const NUM_CARDS    = BigInt(119315717514047)
const NUM_SHUFFLES = BigInt(101741582076661)

"""
    part2(input) -> BigInt

Given the shuffle instructions as input, do some really complicated math to
find the value of the card at position `2020`. I do not understand this math,
and I'm not sure I ever will. This solution was adapted from a Kotlin solution
found here: https://todd.ginsberg.com/post/advent-of-code/2019/day22/.
"""
function part2(input)
    memory = BigInt[1, 0]

    # Nope, don't ask me why this works. I can't tell you.
    for instruction in reverse(input)
        if instruction isa NewStack
            memory[1] = -memory[1]
            memory[2] = -(memory[2] + 1)
        elseif instruction isa Cut
            memory[2] += instruction.n
        elseif instruction isa Increment
            mult = powermod(BigInt(instruction.n), NUM_CARDS - 2, NUM_CARDS)
            memory[1] *= mult
            memory[2] *= mult
        end
        memory[1] %= NUM_CARDS
        memory[2] %= NUM_CARDS
    end

    power = powermod(memory[1], NUM_SHUFFLES, NUM_CARDS)
    a = power * 2020
    b = memory[2] * (power + NUM_CARDS - 1)
    c = powermod((memory[1] - 1), NUM_CARDS - 2, NUM_CARDS)
    return (a + b * c) % NUM_CARDS
end

