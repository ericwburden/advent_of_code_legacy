struct Registers
    inner::Dict{Register,Literal}
end

function Registers(pairs::Pair{Char,Int}...)
    registers = Dict{Register,Literal}()
    for (r, v) in pairs
        registers[Register(r)] = Literal(v)
    end
    return Registers(registers)
end

Base.getindex((; inner)::Registers, r::Register) = getindex(inner, r)
Base.getindex((; inner)::Registers, c::Char) = getindex(inner, Register(c))
Base.setindex!((; inner)::Registers, l::Literal, r::Register) = Base.setindex!(inner, l, r)
Base.:+((; value)::Literal, b::Int) = Literal(value + b)
Base.:-((; value)::Literal, b::Int) = Literal(value - b)

function execute!(r::Registers, (; from, to)::Cpy{Register})
    r[to] = r[from]
    return 1
end

function execute!(r::Registers, (; from, to)::Cpy{Literal})
    r[to] = from
    return 1
end

function execute!(r::Registers, (; register)::Inc)
    r[register] += 1
    return 1
end

function execute!(r::Registers, (; register)::Dec)
    r[register] -= 1
    return 1
end

function execute!(r::Registers, (; check, offset)::Jnz{Register})
    return r[check] == Literal(0) ? 1 : offset.value
end

function execute!(::Registers, (; check, offset)::Jnz{Literal})
    return check == Literal(0) ? 1 : offset.value
end

function part1(input)
    pointer = 1
    registers = Registers('a' => 0, 'b' => 0, 'c' => 0, 'd' => 0)

    while checkbounds(Bool, input, pointer)
        instruction = input[pointer]
        pointer += execute!(registers, instruction)
    end

    return registers['a']
end
