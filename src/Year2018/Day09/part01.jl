using DataStructures: Deque

"Represents the circle of marbles, with a push/pop interface."
struct MarbleCircle{T}
    deque::Deque{T}
end
MarbleCircle{T}() where {T} = MarbleCircle(Deque{T}())

function MarbleCircle{T}(itr::Vector{T}) where {T}
    deque = Deque{T}()
    foreach(v -> push!(deque, v), itr)
    return MarbleCircle{T}(deque)
end

function Base.pop!(circle::MarbleCircle)
    return pop!(circle.deque)
end

function Base.push!(circle::MarbleCircle{T}, value::T) where {T}
    isempty(circle.deque) || push!(circle.deque, popfirst!(circle.deque))
    push!(circle.deque, value)
end

"""
    circshift!(circle::MarbleCircle, n::Int)

Shift the circle of marbles clockwise (positive `n`) or counterclockwise 
(negative `n`), effectively moving the current position for pushing/popping.
"""
function Base.circshift!(circle::MarbleCircle, n::Int)
    isempty(circle.deque) && return
    if n < 0
        foreach(_ -> pushfirst!(circle.deque, pop!(circle.deque)), 1:abs(n))
    elseif n > 0
        foreach(_ -> push!(circle.deque, popfirst!(circle.deque)), 1:n)
    end
end


"Represents the state of the marble game"
mutable struct MarbleGame
    marble::Int
    elves::Int
    circle::MarbleCircle{Int}
    scores::Vector{Int}
end

"Create a new game with a set number of players"
function MarbleGame(elves::Int)
    circle = MarbleCircle{Int}([0])
    MarbleGame(0, elves, circle, zeros(elves))
end

"""
    tick!(game::MarbleGame)

Play one round of the game, placing a marble or scoring as described in the
puzzle. Updates the game state and returns the points scored during the round.
"""
function tick!(game::MarbleGame)
    game.marble += 1
    (; marble, elves, circle) = game
    if marble % 23 == 0
        circshift!(circle, -7)
        score = marble + pop!(circle)
        circshift!(circle, 1)
        elf = (marble - 1) % elves + 1
        game.scores[elf] += score
        return score
    else
        push!(circle, marble)
        return 0
    end
end


"""
    part1(input)

Create a new marble game and play until the `last_marble` is played, then 
return the high score.
"""
function part1(input)
    players, last_marble = input
    game = MarbleGame(players)
    foreach(_ -> tick!(game), 1:last_marble)
    return maximum(game.scores)
end
