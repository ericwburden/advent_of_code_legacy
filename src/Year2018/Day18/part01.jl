using IterTools: iterated, nth

"""
Each `AbstractAcre` represents one of the states that an acre in our
`Landscape` can be, either open, forested, or occupied by a lumberyard.
"""
abstract type AbstractAcre end
struct Open <: AbstractAcre end
struct Trees <: AbstractAcre end
struct Lumberyard <: AbstractAcre end

const Landscape = Matrix{AbstractAcre}

"""
    show(landscape::Landscape)

Pretty printing for a `Landscape`.
"""
Base.show(::Open) = print('.')
Base.show(::Trees) = print('|')
Base.show(::Lumberyard) = print('#')

function Base.show(landscape::Landscape)
    for col in eachcol(landscape)
        foreach(show, col)
        println()
    end
    println()
end

"""
    convert(::Type{Landscape}, chars::Matrix{Char})
    
Converts a character matrix to a `Landscape`.
"""
function Base.convert(::Type{Landscape}, chars::Matrix{Char})
    landscape::Landscape = fill(Open(), size(chars))
    for (idx, char) in enumerate(chars)
        if char == '.'
            continue
        elseif char == '|'
            landscape[idx] = Trees()
        elseif char == '#'
            landscape[idx] = Lumberyard()
        else
            error("There is no `AbstractAcre` representation for $char")
        end
    end
    return landscape
end

"""
    get_environment(landscape::Landscape, idx::CartesianIndex)

Given the current `landscape` and the location of an acre as `idx`, return
a listing of the acre types surrounding `idx`.
"""
function get_environment(landscape::Landscape, idx::CartesianIndex)
    environment = AbstractAcre[]
    for offset = CartesianIndex(-1, -1):CartesianIndex(1, 1)
        offset == CartesianIndex(0, 0) && continue
        nearby = idx + offset
        checkbounds(Bool, landscape, nearby) || continue
        push!(environment, landscape[nearby])
    end
    return environment
end

"""
    next_state(::Open, nearby::Vector{AbstractAcre})
    next_state(::Trees, nearby::Vector{AbstractAcre})
    next_state(::Lumberyard, nearby::Vector{AbstractAcre})

Given an `AbstractAcre` and a list of the nearby types of `AbstractAcre`,
return the type of the given acre in the next state.
"""
function next_state(::Open, nearby::Vector{AbstractAcre})
    trees = count(a -> a isa Trees, nearby)
    return trees >= 3 ? Trees() : Open()
end

function next_state(::Trees, nearby::Vector{AbstractAcre})
    lumberyards = count(a -> a isa Lumberyard, nearby)
    return lumberyards >= 3 ? Lumberyard() : Trees()
end

function next_state(::Lumberyard, nearby::Vector{AbstractAcre})
    trees = count(a -> a isa Trees, nearby)
    lumberyards = count(a -> a isa Lumberyard, nearby)
    return (trees >= 1 && lumberyards >= 1) ? Lumberyard() : Open()
end

"""
    next_state(landscape::Landscape)

Given the entire `landscape`, populate and return a new `Landscape`
with the next state of each individual acre.
"""
function next_state(landscape::Landscape)
    state::Landscape = fill(Open(), size(landscape))
    for idx in CartesianIndices(landscape)
        current = landscape[idx]
        nearby = get_environment(landscape, idx)
        state[idx] = next_state(current, nearby)
    end
    return state
end

"""
    part1(input)

Given the input as a character matrix, convert it to a landscape and
simulate changes in the landscape through 10 generations, returning
the 'resource value' of the landscape in the 11th generation.
"""
function part1(input)
    landscape = convert(Landscape, input)
    last_state = nth(iterated(next_state, landscape), 11)
    trees = count(a -> a isa Trees, last_state)
    lumberyards = count(a -> a isa Lumberyard, last_state)
    return trees * lumberyards
end
