using Match

#=------------------------------------------------------------------------------
| Types (structs) for modeling the circuit diagram system. The signals provided
| to each operation can either be `Raw` signals containing an input value or
| `Wire` signals referencing another wire in the circuit.
------------------------------------------------------------------------------=#
abstract type Signal end
struct Raw  <: Signal value::UInt16 end
struct Wire <: Signal value::String end

Signal(::Nothing)         = nothing
Signal(s::AbstractString) = all(isdigit, s) ? Raw(parse(Int, s)) : Wire(s)

#=------------------------------------------------------------------------------
| Each transformation of a `Signal` is modeled by an `Operation`. In the 
| simplest case, this just means `Assign`ing a value, but all included
| operations are modeled this way. The type of operation modeled depends
| on the input line, parsed by the `OPERATION_RE` regular expression.
------------------------------------------------------------------------------=#
abstract type Operation end
struct Assign     <: Operation input::Signal end
struct Not        <: Operation input::Signal end
struct And        <: Operation left::Signal; right::Signal end
struct Or         <: Operation left::Signal; right::Signal end
struct LeftShift  <: Operation input::Signal; magnitude::Signal end
struct RightShift <: Operation input::Signal; magnitude::Signal end

const OPERATION_RE = r"((?<left>[a-z0-9]+)? ?(?<op>[A-Z]+)? )?(?<right>\w+)"

function Operation(s::AbstractString)
    m = match(OPERATION_RE, s)
    left  = Signal(m["left"])
    right = Signal(m["right"])
    return @match m["op"] begin
        "NOT"    => Not(right)
        "AND"    => And(left, right)
        "OR"     => Or(left, right)
        "LSHIFT" => LeftShift(left, right)
        "RSHIFT" => RightShift(left, right)
        nothing  => Assign(right)
    end
end


"Type alias for the data structure relating `Wire`s to their inputs"
const CircuitDiagram = Dict{Wire,Operation}

"""
    ingest(path)

Given the path to an input file, parses each line of that input file into a
`Wire` => `Operation` pair and places them into a `CircuitDiagram` (Dict).
"""
function ingest(path)
    circuit_diagram = CircuitDiagram()
    open(path) do f
        for line in eachline(f)
            (input, output) = split(line, " -> ")
            output = Wire(output)
            circuit_diagram[output] = Operation(input)
        end
    end
    return circuit_diagram
end
