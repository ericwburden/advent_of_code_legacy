struct Nop{T<:Value,U<:Union{Nothing,Value}} <: Instruction
    arg1::T
    arg2::U
end

function execute!(program::Program, ::Nop)
    program.pointer += 1
end

function execute!(program::Program, (; offset)::Tgl)
    idx = program.pointer + eval(program.registers, offset)
    if checkbounds(Bool, program.code, idx)
        program.code[idx] = toggle(program.code[idx])
    end
    program.pointer += 1
end

function execute!(program::Program)
    instruction = program.code[program.pointer]
    execute!(program, instruction)
end

toggle((; from, to)::Cpy) = Jnz(from, to)
toggle((; check, offset)::Jnz{Literal,Register}) = Cpy(check, offset)
toggle((; check, offset)::Jnz{Literal,Literal}) = Nop(check, offset)
toggle((; check, offset)::Jnz{Register,Register}) = Cpy(check, offset)
toggle((; check, offset)::Jnz{Register,Literal}) = Nop(check, offset)
toggle((; arg1, arg2)::Nop{Value,Value}) = Jnz(from, to)
toggle((; register)::Inc) = Dec(register)
toggle((; register)::Dec) = Inc(register)
toggle((; offset)::Tgl{Register}) = Inc(offset)
toggle((; offset)::Tgl{Literal}) = Nop(offset, nothing)
toggle((; arg1, arg2)::Nop{Register,Nothing}) = Inc(arg1)

function part1(input)
    registers = Registers('a' => 7, 'b' => 0, 'c' => 0, 'd' => 0)
    program = Program(1, registers, deepcopy(input))

    while checkbounds(Bool, program.code, program.pointer)
        execute!(program)
    end

    return program.registers['a'].value
end
