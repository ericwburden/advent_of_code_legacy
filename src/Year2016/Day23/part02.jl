#=------------------------------------------------------------------------------
| `Add` instruction replaces the Inc/Dec/Jnz loops that serve to add the 
| value of one register to another, clearing the first. Optimize by replacing
| the first instruction in that loop with the `Add` instruction, which skips
| the other two. 
------------------------------------------------------------------------------=#

struct Add <: Instruction
    inc::Register
    dec::Register
end

function execute!(program::Program, (; inc, dec)::Add)
    program.registers[inc] += eval(program.registers, dec)
    program.registers[dec] = Literal(0)
    program.pointer += 3
end

function optimize_add!(instructions::Vector{Instruction})
    idx = 1
    while idx < length(instructions) - 2
        add_instr = try_add_instruction(instructions[idx:idx+2]...)
        if isnothing(add_instr)
            idx += 1
        else
            instructions[idx] = add_instr
            idx += 3
        end
    end
end

try_add_instruction(::Any, ::Any, ::Any) = nothing
try_add_instruction(dec::Dec, inc::Inc, jnz::Jnz) = try_add_instruction(inc, dec, jnz)
function try_add_instruction(inc::Inc, dec::Dec, jnz::Jnz)
    dec.register == jnz.check || return nothing
    jnz.offset == Literal(-2) || return nothing
    return Add(inc.register, dec.register)
end



#=------------------------------------------------------------------------------
| `Mul` instruction replaces the Cpy/Inc/Dec/Jnz(-2)/Dec/Jnz(-5) loops that 
| serve to add the product of two registers to a third, clearing two registers
| in the process. Optimize by replacing the first instruction in that loop with
| the `Mul` instruction, which skips the rest. This is a fairly brittle
| approach, leaving open possible issues with toggling multiple instructions
| inside the loop, but that doesn't happen with this input.
------------------------------------------------------------------------------=#

struct Mul <: Instruction
    inc::Register
    mul::Tuple{Value,Value}
    clr::Tuple{Register,Register}
end

function execute!(program::Program, (; inc, mul, clr)::Mul)
    mul1 = eval(program.registers, mul[1])
    mul2 = eval(program.registers, mul[2])
    program.registers[inc] += mul1 * mul2
    clr1, clr2 = clr
    program.registers[clr1] = Literal(0)
    program.registers[clr2] = Literal(0)
    program.pointer += 6
end

function optimize_mul!(instructions::Vector{Instruction})
    idx = 1
    while idx < length(instructions) - 5
        mul_instr = try_mul_instruction(instructions[idx:idx+5]...)
        if isnothing(mul_instr)
            idx += 1
        else
            instructions[idx] = mul_instr
            idx += 6
        end
    end
end

try_mul_instruction(::Any, ::Any, ::Any, ::Any, ::Any, ::Any) = nothing
try_mul_instruction(cpy::Cpy, add::Add, ::Dec, ::Jnz, dec::Dec, jnz::Jnz) =
    try_mul_instruction(cpy, add, dec, jnz)
try_mul_instruction(cpy::Cpy, add::Add, ::Inc, ::Jnz, dec::Dec, jnz::Jnz) =
    try_mul_instruction(cpy, add, dec, jnz)
function try_mul_instruction(cpy::Cpy, add::Add, dec::Dec, jnz::Jnz)
    cpy.to == add.dec || return nothing
    dec.register == jnz.check || return nothing
    jnz.offset == Literal(-5) || return nothing
    return Mul(add.inc, (cpy.from, dec.register), (add.dec, dec.register))
end


"""
    execute!(program::Program, (; offset)::Tgl) 

Replace the execute! function for the `Tgl` instruction, to optimize away 
addition and multiplication loops every time an instruction is toggled.
"""
# This works, but it breaks incremental compilation in Julia. Uncomment to 
# make the solution run MUCH faster! I could most likely fix this by
# specializing `Tgl` and replacing the `Tgl` instructions in part 2 with the
# optimizing version, but I've finished Day 25 by now and I don't feel like
# coming back to this one :D.

# function execute!(program::Program, (; offset)::Tgl) 
#     idx = program.pointer + eval(program.registers, offset)
#     if checkbounds(Bool, program.code, idx)
#         program.code[idx] = toggle(program.code[idx])
#         optimize_add!(program.code)
#         optimize_mul!(program.code)
#     end
#     program.pointer += 1
# end


function part2(input)
    instructions = deepcopy(input)
    optimize_add!(instructions)
    optimize_mul!(instructions)

    registers = Registers('a' => 12, 'b' => 0, 'c' => 0, 'd' => 0)
    program = Program(1, registers, instructions)

    while checkbounds(Bool, program.code, program.pointer)
        execute!(program)
    end

    return program.registers['a'].value
end # 479008074
