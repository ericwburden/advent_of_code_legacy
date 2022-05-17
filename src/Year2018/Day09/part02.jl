"""
    part1(input)

Create a new marble game and play 100 times as many rounds as part 1, then
return the high score.
"""
function part2(input)
    players, last_marble = input
    game = MarbleGame(players)
    foreach(_ -> tick!(game), 1:(last_marble*100))
    return maximum(game.scores)
end
