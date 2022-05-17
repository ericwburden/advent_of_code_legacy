using Match

"Abstract type for any of the instructions used in this exercise"
abstract type Instruction end

"An instruction to turn lights on"
struct TurnOn <: Instruction
    topleft::CartesianIndex{2}
    bottomright::CartesianIndex{2}
end

"An instruction to turn lights off"
struct TurnOff <: Instruction
    topleft::CartesianIndex{2}
    bottomright::CartesianIndex{2}
end

"An instruction to toggle lignts"
struct Toggle <: Instruction
    topleft::CartesianIndex{2}
    bottomright::CartesianIndex{2}
end


"""
    toindex(row, col)

Given two strings representing the row and column indices for a given point,
convert the strings to integers, increase them both by 1 to account for 
Julia being 1-indexed, and return a `CartesianIndex` indicating that point.
"""
function toindex(row::AbstractString, col::AbstractString)
    CartesianIndex(parse.(Int, (row, col)) .+ 1)
end

"Regular expression for parsing a line of the input"
const INSTRUCTION_RE = r"(?<type>[a-z ]+)\s+(?<t>\d+),(?<l>\d+)\D*(?<b>\d+),(?<r>\d+)"

"""
    ingest(path)

Given the path to an input file, parse each line into an `Instruction` and
return the list of instructions.
"""
function ingest(path)
    instructions = []
    open(path) do f
        for line in eachline(f)
            m = match(INSTRUCTION_RE, line)
            topleft = toindex(m["t"], m["l"])
            bottomright = toindex(m["b"], m["r"])
            instruction = @match m["type"] begin
                "turn on" => TurnOn(topleft, bottomright)
                "turn off" => TurnOff(topleft, bottomright)
                "toggle" => Toggle(topleft, bottomright)
            end
            push!(instructions, instruction)
        end
    end
    return instructions
end
