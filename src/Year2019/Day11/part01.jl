using .IntCode: Computer, Running, Halted, add_input!, get_output!, run!

"""
An `AbstractDirection` is used to sub-type `Robot`, indicating which
direction it is facing.
"""
abstract type AbstractDirection end
struct Up <: AbstractDirection end
struct Right <: AbstractDirection end
struct Down <: AbstractDirection end
struct Left <: AbstractDirection end

function Base.convert(::Type{AbstractDirection}, d::BigInt)
    d == 0 && return Left()
    d == 1 && return Right()
    error("'$d' cannot be converted to an `AbstractDirection`!")
end


"""
An `AbstractColor` represents the color of a panel, either `Black`
or `White`.
"""
abstract type AbstractColor end
struct Black <: AbstractColor end
struct White <: AbstractColor end

function Base.convert(::Type{AbstractColor}, c::BigInt)
    c == 0 && return Black()
    c == 1 && return White()
    error("'$c' cannot be converted to an `AbstractColor`!")
end

function Base.convert(::Type{BigInt}, c::AbstractColor)
    c isa Black && return 0
    c isa White && return 1
end


"Type alias"
const Position = NTuple{2,Int}

"""
A `Robot` represents the 'emergency hull painting robot', keeping track
of the robot's current position and the direction it is facing.
"""
struct Robot{D<:AbstractDirection}
    direction::Type{D}
    position::Position
end

"""
    step(robot::Robot) -> Robot

Move the `robot` forward one step in the direction it is currently facing.
"""
step((; position)::Robot{Up}) = Robot(Up, position .+ (-1, 0))
step((; position)::Robot{Right}) = Robot(Right, position .+ (0, 1))
step((; position)::Robot{Down}) = Robot(Down, position .+ (1, 0))
step((; position)::Robot{Left}) = Robot(Left, position .+ (0, -1))


"""
    turn(robot::Robot, ::Left)  -> Robot
    turn(robot::Robot, ::Right) -> Robot

Turn the `robot` either left or right, returning a new `Robot` with the
same position, but facing the appropriate direction.
"""
turn((; position)::Robot{Up}, ::Left) = Robot(Left, position)
turn((; position)::Robot{Right}, ::Left) = Robot(Up, position)
turn((; position)::Robot{Down}, ::Left) = Robot(Right, position)
turn((; position)::Robot{Left}, ::Left) = Robot(Down, position)

turn((; position)::Robot{Up}, ::Right) = Robot(Right, position)
turn((; position)::Robot{Right}, ::Right) = Robot(Down, position)
turn((; position)::Robot{Down}, ::Right) = Robot(Left, position)
turn((; position)::Robot{Left}, ::Right) = Robot(Up, position)


const Panels = Dict{Position,AbstractColor}

"""
    paint(program::Vector{Int}, start_color::AbstractColor) -> Panels

Runs the IntCode `program` on an 'emergency hull-painting robot' (starting
on a panel of `start_color` color) until it halts, keeping track of and
return the color of the panels on the outside of the ship.
"""
function paint(program::Vector{Int}, start_color::AbstractColor = Black())
    panels = Dict{Position,AbstractColor}((0, 0) => start_color)
    robot = Robot(Up, (0, 0))
    computer = Computer(program)

    while !(computer isa Computer{Halted})
        panel::Int = get(panels, robot.position, Black())
        add_input!(computer, panel)
        computer = run!(computer)

        paint::AbstractColor = get_output!(computer)
        panels[robot.position] = paint

        turn_dir::AbstractDirection = get_output!(computer)
        robot = turn(robot, turn_dir)
        robot = step(robot)
    end

    return panels
end

"Run the program, count the panels painted"
part1(input) = paint(input) |> length
