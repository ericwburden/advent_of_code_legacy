function part2(input)
    pointer = 1
    registers = Registers('a' => 0, 'b' => 0, 'c' => 1, 'd' => 0)

    while checkbounds(Bool, input, pointer)
        instruction = input[pointer]
        pointer += execute!(registers, instruction)
    end

    return registers['a'].value
end
