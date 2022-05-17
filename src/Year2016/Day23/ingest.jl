"Updated to include parsing for `Tgl`"
function Base.parse(::Type{Instruction}, s::AbstractString)
    m = match(r"(?<instr>\w+) (?<rem>.+)", s)
    occursin("cpy", m["instr"]) && return parse(Cpy, m["rem"])
    occursin("inc", m["instr"]) && return parse(Inc, m["rem"])
    occursin("dec", m["instr"]) && return parse(Dec, m["rem"])
    occursin("jnz", m["instr"]) && return parse(Jnz, m["rem"])
    occursin("tgl", m["instr"]) && return parse(Tgl, m["rem"])
    error("Cannot parse $s into an `Instruction`!")
end

"Represents a Toggle instruction"
struct Tgl{T<:Value} <: Instruction
    offset::T
end

function Base.parse(::Type{Tgl}, s::AbstractString)
    offset = parse(Value, s)
    return Tgl(offset)
end

ingest(path) = parse.(Instruction, readlines(path))
