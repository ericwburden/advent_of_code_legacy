#=
1 2 3
4 5 6
7 8 9
=#
const keypad1 = Dict(
    '1' => Dict('R' => '2', 'D' => '4'),
    '2' => Dict('L' => '1', 'R' => '3', 'D' => '5'),
    '3' => Dict('L' => '2', 'D' => '6'),
    '4' => Dict('U' => '1', 'R' => '5', 'D' => '7'),
    '5' => Dict('L' => '4', 'U' => '2', 'R' => '6', 'D' => '8'),
    '6' => Dict('L' => '5', 'U' => '3', 'D' => '9'),
    '7' => Dict('U' => '4', 'R' => '8'),
    '8' => Dict('L' => '7', 'U' => '5', 'R' => '9'),
    '9' => Dict('L' => '8', 'U' => '6'),
)


function part1(input, keypad = keypad1)
    code = Char[]
    current = '5'
    next(x, d) = get(keypad[x], d, x)

    for instruction in input
        current = reduce(next, instruction, init = current)
        push!(code, current)
    end

    return code
end
