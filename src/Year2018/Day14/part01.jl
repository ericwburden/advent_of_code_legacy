"`ScoreTracker` bundles the state keeping up with recipe scores"
mutable struct ScoreTracker
    scoreboard::Vector{Int}
    elf1::Int
    elf2::Int
end

ScoreTracker() = ScoreTracker(Int[3, 7], 1, 2)

"""
    create!(score_tracker::ScoreTracker)

Given a `ScoreTracker`, generate and append the next round of recipe scores
and changing elf choices in accordance with the puzzle rules.
"""
function create!(score_tracker::ScoreTracker)
    (; scoreboard, elf1, elf2) = score_tracker

    # Calculate and add new scores to the scoreboard
    elf1_score = scoreboard[elf1]
    elf2_score = scoreboard[elf2]
    new_scores = Iterators.reverse(digits(elf1_score + elf2_score))
    foreach(score -> push!(scoreboard, score), new_scores)

    # Move the elves to their next recipe
    score_tracker.elf1 = (elf1 + elf1_score) % length(scoreboard) + 1
    score_tracker.elf2 = (elf2 + elf2_score) % length(scoreboard) + 1
end

"""
    part1(input)

Generate new recipe scores, until `input` + 10 number of scores have been
generated. Return the first 10 scores after `input` scores have been 
generated.
"""
function part1(input)
    score_tracker = ScoreTracker()
    
    # Generate the first `input` + 10 scores
    foreach(_ -> create!(score_tracker), 1:(input+10))

    # Return the ten scores following the `input`th score
    ten_subsequent_scores = score_tracker.scoreboard[(input+1):(input+10)]
    return join(ten_subsequent_scores)
end
