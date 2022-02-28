using DataStructures: Queue, enqueue!, dequeue!

#=------------------------------------------------------------------------------
| Additional sub-types for AbstractRepository, to represent the different 
| possible states of the output or robot.
------------------------------------------------------------------------------=#
struct FullOutput <: AbstractOutput
    id::Int
    value::Int
end

struct PartialBot <: AbstractBot
    id::Int
    value::Int
end

struct FullBot <: AbstractBot
    id::Int
    low::Int
    high::Int
end

"Represents the entire system of repositories"
const TransferSystem = Set{AbstractRepository}


"""
    hash(bot::AbstractBot)
    hash(out::AbstractOutput)
    isequal(a::AbstractBot,    b::AbstractBot)
    isequal(a::AbstractOutput, b::AbstractOutput)

Implemented to allow storing robots and outputs in a single Set, retrievable
by type and `id` only. Ignores the specific sub-type of the repository, and 
the values held. This way, an EmptyBot(1) matches a PartialBot(1, 10) matches
a FullBot(1, 10, 35), and any can be fetched from a set by any of the others.
"""
Base.hash(bot::AbstractBot)    = hash(AbstractBot, hash(bot.id))
Base.hash(out::AbstractOutput) = hash(AbstractOutput, hash(out.id))
Base.isequal(a::AbstractBot,    b::AbstractBot)    = hash(a) == hash(b)
Base.isequal(a::AbstractOutput, b::AbstractOutput) = hash(a) == hash(b)


"""
    get!(system::TransferSystem, repo::AbstractRepository)
    add!(system::TransferSystem, repo::AbstractRepository, (; value)::Direct)
    add!(system::TransferSystem, repo::AbstractRepository, (; high, low)::Comparative)

Functions to provide a (modified) interface to the `TransferSystem` (essentially
a Set) to allow fetching, adding, updating items to the set. `get!()` serves
as a fetch, and `add!()` serves as an 'upsert', adding values to existing
Repositories in the set if the matching Repository (by type and id) is in the
Set, or adding a new Repository if it's not already there.
"""
function Base.get!(system::TransferSystem, repo::AbstractRepository)
    repo ∈ system && return first(TransferSystem([repo]) ∩ system)
    push!(system, repo)
    return repo
end

function add!(system::TransferSystem, repo::AbstractRepository, (; value)::Direct)
    current  = get!(system, repo)
    new_repo = update(current, value)
    push!(system, new_repo)
    return true
end

function add!(system::TransferSystem, repo::AbstractRepository, (; high, low)::Comparative)
    from = get!(system, repo)
    from isa FullBot || return false

    add!(system, high, Direct(from.high))
    add!(system, low,  Direct(from.low))
    return true
end


"""
    update((; id)::EmptyOutput, value::Int)
    update((; id)::EmptyBot,    value::Int)
    update((; id, value)::PartialBot, next_value::Int)

Given any type of Repository, these functions add values (chips) to the 
repository, such that `update(EmptyBot(1), 10)` -> `PartialBot(1, 10)` and
`update(PartialBot(1, 10), 35)` -> `FullBot(1, 10, 35)`.
"""
update((; id)::EmptyOutput, value::Int) = FullOutput(id, value)
update((; id)::EmptyBot,    value::Int) = PartialBot(id, value)
function update((; id, value)::PartialBot, next_value::Int)
    if next_value > value
        return FullBot(id, value, next_value)
    else
        return FullBot(id, next_value, value)
    end
end


# Type aliases for convenience
const TransferList  = Vector{Tuple{AbstractRepository,AbstractTransfer}}
const TransferQueue = Queue{Tuple{AbstractRepository,AbstractTransfer}}


"""
    analyze(input::TransferList)

Repeatedly attempt to apply each of the transfers in the `TransferList`, 
updating a `TransferSystem` until each transfer has been applied. 
"""
function analyze(input::TransferList)
    system = TransferSystem()
    queue  = TransferQueue()
    foreach(v -> enqueue!(queue, v), input)

    while !isempty(queue)
        (repo, transfer) = dequeue!(queue)
        add!(system, repo, transfer) || enqueue!(queue, (repo, transfer))
    end

    return system
end


"Checks whether a given `FullBot` contains a pair of values"
function contains(repo::FullBot, values::Tuple{Int,Int})
    repo.low == min(values...) && repo.high == max(values...)
end


"""
    part1(input::TransferList)

Given the input as a list of `AbstractTransfer`s, analyze the list to determine
which chips flow to which robots and outputs, and return the `id` of the 
`FullBot` containing the indicated values.
"""
function part1(input::TransferList, values = (17, 61))
    for repo in analyze(input)
        contains(repo, values) && return repo.id
    end
    error("Could not find answer!")
end
