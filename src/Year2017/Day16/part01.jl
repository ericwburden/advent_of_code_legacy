"""
    execute!(dancers::Vector{Char}, (; n)::Spin) 
    execute!(dancers::Vector{Char}, (; a, b)::Exchange)
    execute!(dancers::Vector{Char}, (; a, b)::Partner)

Given a list of dancers and an instruction to follow, have the dancers 
'perform' the move.
"""
function execute!(dancers::Vector{Char}, (; n)::Spin) 
    circshift!(dancers, [dancers...], n)
end

function execute!(dancers::Vector{Char}, (; a, b)::Exchange)
    dancers[a], dancers[b] = dancers[b], dancers[a]
end

function execute!(dancers::Vector{Char}, (; a, b)::Partner)
    i, j = indexin((a, b), dancers)
    dancers[i], dancers[j] = dancers[j], dancers[i]
end

"""
    part1(moves)

Given a list of moves, have the dancers perform each move in turn and
return the final configuration of dancers, as a string.
"""
function part1(moves)
    dancers = collect("abcdefghijklmnop")
    move!(move) = execute!(dancers, move)
    foreach(move!, moves)
    return join(dancers)
end
