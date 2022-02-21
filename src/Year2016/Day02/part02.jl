#=
    1
  2 3 4
5 6 7 8 9
  A B C
    D
=#

const keypad2 = Dict(
    '1' => Dict(                                    'D' => '3'),
    '2' => Dict(                        'R' => '3', 'D' => '6'),
    '3' => Dict('L' => '2', 'U' => '1', 'R' => '4', 'D' => '7'),
    '4' => Dict('L' => '3',                         'D' => '8'),
    '5' => Dict(                        'R' => '6'),
    '6' => Dict('L' => '5', 'U' => '2', 'R' => '7', 'D' => 'A'),
    '7' => Dict('L' => '6', 'U' => '3', 'R' => '8', 'D' => 'B'),
    '8' => Dict('L' => '7', 'U' => '4', 'R' => '9', 'D' => 'C'),
    '9' => Dict('L' => '8'),
    'A' => Dict(            'U' => '6', 'R' => 'B'),
    'B' => Dict('L' => 'A', 'U' => '7', 'R' => 'C', 'D' => 'D'),
    'C' => Dict('L' => 'B', 'U' => '8'),
    'D' => Dict(            'U' => 'B')
)

part2(input, keypad = keypad2) = part1(input, keypad)
