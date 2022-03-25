"A dict representing locations and values in a square spiral"
const Spiral = Dict{Tuple{Int,Int},Int}

"""
    SpiralWalker(
        pos::Tuple{Int,Int}
        dir::Tuple{Int,Int}
        seed::Int
        idx::Int
    )

Represents a 'walker' around a square spiral, starting at `pos` and moving
around in combination with the `next!` function. `dir` represents the offset
of the last move, `seed` is used to determine the next `idx` at which the 
walker turns to continue the spiral, and `idx` represents the current step of
the walker if their moves were laid out in a linear array.
"""
mutable struct SpiralWalker
    pos::Tuple{Int,Int}
    dir::Tuple{Int,Int}
    seed::Int
    idx::Int
end
SpiralWalker() = SpiralWalker((0, 0), (0, 1), 2, 1)

"Given a seed value, return the next index that will be a turn"
next_turn(seed::Int)   = floor(Int, (seed*seed)/4) + 1

"Indicates whether the walk should turn on the current step"
will_turn(s::SpiralWalker) = s.idx == next_turn(s.seed)

"""
    turn_left(dir::Tuple{Int,Int})

Given a tuple representing a directional offset on a square grid, return the
offset if the direction were to take a left turn.
"""
function turn_left(dir::Tuple{Int,Int})
    dir == ( 0,  1) && return (-1,  0)
    dir == (-1,  0) && return ( 0, -1)
    dir == ( 0, -1) && return ( 1,  0)
    dir == ( 1,  0) && return ( 0,  1)
    error("`dir` was $dir, should be one of (0, 1), (1, 0), (0, -1), (-1, 0)!")
end

"""
    next!(s::SpiralWalker)

Move the `SpiralWalker` forward one step.
"""
function next!(s::SpiralWalker)
    if will_turn(s)
        s.dir   = turn_left(s.dir)
        s.seed += 1
    end
    s.pos  = s.pos .+ s.dir
    s.idx += 1
end

"""
    value_at(pos::Tuple{Int,Int}, spiral::Spiral)

Calculate the value at a given position in a square spiral, based on the 
`spiral`'s current state, as the sum of all the surrounding values.
"""
function value_at(pos::Tuple{Int,Int}, spiral::Spiral)
    value = 0
    for row_offset in -1:1, col_offset in -1:1
        row_offset == col_offset == 0 && continue
        check_at = pos .+ (row_offset, col_offset)
        value += get(spiral, check_at, 0)
    end
    return value
end

"""
    part2(input)

Given the input as a numeric value, initiate a 'walker' around a square spiral,
calculating the value at each index according to the puzzle description. Return
the first value that exceeds `input`.
"""
function part2(input)
    spiral = Spiral()
    walker = SpiralWalker()
    value  = 1

    while value <= input
        spiral[walker.pos] = value
        next!(walker)
        value = value_at(walker.pos, spiral)
    end
    return value
end
