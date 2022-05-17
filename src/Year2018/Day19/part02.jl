"""
    examine_output(input, path)

Runs a series of instructions and prints the resulting program state to a file for
examination. I examined this output, along with the input program, to determing that
the operation of the program was to set the fifth register to a large number
and run a hot loop, setting the second register to `1` and the sixth register to
increasing values as multples of the value in the second register. Once the sixth
register value reached the value of the large number stored in the fifth register,
if it reached that value exactly, the first register was incremented by the value
in the second register, the value in the second register was incremented by one,
and the loop began again. The result is that the first register was accumulating
the sum of factors of the value in the fifth register.
"""
function examine_output(input, path)
    program, instructions = input
    open(path, "a") do f
        while program.state == Running
            program = execute(instructions, program)
            println(f, program)
        end
    end
end

"""
    part2(input)

Setting the first register to `1` causes the value whose factors are accumulated by
the program to be _much_ larger, causing the program to run _MUCH_ longer. Use the
insight from examining the instructions and program output and sum the factors of the
value set to the fifth register. Return this value.
"""
function part2(input)
    program, instructions = input
    (; pointer, bind, registers) = program
    registers = set_register(registers, 0, 1)
    program = Program(Running, pointer, bind, registers)

    while get_value(program.registers, 0) > 0
        program = execute(instructions, program)
    end

    bignum = get_value(program.registers, 4)
    return mapreduce(n -> bignum % n == 0 ? n : 0, +, 1:bignum)
end
