"""
`AbstractRepository` represents any component of the system that can hold
one of the valued chips.
"""
abstract type AbstractRepository end

function Base.parse(::Type{AbstractRepository}, s::AbstractString)
    startswith(s, "bot") && return parse(EmptyBot, s)
    startswith(s, "output") && return parse(EmptyOutput, s)
    error("Don't know how to parse $s into an AbstractRepository")
end


"""
`EmptyOutput` represents an output container, an end-point repository that can
receive chips but not transfer them further.
"""
abstract type AbstractOutput <: AbstractRepository end

struct EmptyOutput <: AbstractOutput
    id::Int
end

AbstractOutput(id::Int) = EmptyOutput(id)

function Base.parse(::Type{EmptyOutput}, s::AbstractString)
    re = r"output (?<id>\d+)"
    m = match(re, s)
    id = parse(Int, m["id"])
    return EmptyOutput(id)
end


"""
`AbstractBot` represents one of the robots in the system, a component that
can both send and receive chips, and which sends chips based on their relative
values.
"""
abstract type AbstractBot <: AbstractRepository end

struct EmptyBot <: AbstractBot
    id::Int
end

AbstractBot(id::Int) = EmptyBot(id)

function Base.parse(::Type{EmptyBot}, s::AbstractString)
    re = r"bot (?<id>\d+)"
    m = match(re, s)
    id = parse(Int, m["id"])
    return EmptyBot(id)
end


"""
`AbstractTransfer` represents an intermediate step for one or more chips in 
the system of transfers. Each transfer models the sending/receiving 
repository(ies), and which chip(s) is/are transferred (or the rules for 
transfer).
"""
abstract type AbstractTransfer end

const RepositoryTransfer = Tuple{AbstractRepository,AbstractTransfer}

function Base.parse(::Type{AbstractTransfer}, s::AbstractString)::RepositoryTransfer
    startswith(s, "bot") && return parse(Comparative, s)
    startswith(s, "value") && return parse(Direct, s)
    error("Don't know how to parse $s into an AbstractTransfer.")
end



"""
`Comparative` represents a transfer from one robot to two other repositories. 
This transfer is based on the relative values of two chips held by a Robot.
"""
struct Comparative <: AbstractTransfer
    low::AbstractRepository
    high::AbstractRepository
end

function Base.parse(::Type{Comparative}, s::AbstractString)::RepositoryTransfer
    re = r"bot (?<from>\d+) gives low to (?<low>\w+ \d+) and high to (?<high>\w+ \d+)"
    m = match(re, s)
    from = parse(Int, m["from"])
    low = parse(AbstractRepository, m["low"])
    high = parse(AbstractRepository, m["high"])
    return (EmptyBot(from), Comparative(low, high))
end


"""
`Direct` represents a transfer from an input (essentially an infinite source of
chips of a single value), to a robot.
"""
struct Direct <: AbstractTransfer
    value::Int
end

function Base.parse(::Type{Direct}, s::AbstractString)::RepositoryTransfer
    re = r"value (?<value>\d+) goes to bot (?<bot>\d+)"
    m = match(re, s)
    value = parse(Int, m["value"])
    bot = parse(Int, m["bot"])
    return (EmptyBot(bot), Direct(value))
end


"""
    ingest(path)

Given the path to the input file, parse each line into a transfer instruction
end return the list of parsed values.
"""
ingest(path)::Vector{RepositoryTransfer} = parse.(AbstractTransfer, readlines(path))
