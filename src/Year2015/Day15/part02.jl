"""
    part2(input, ratiogenerator)

Given the input as a list of `NutritionInfo` and a function for generating all
the combinations of ingredients that can sum to 100 total, filter the batches of
ingedients to those with exactly 500 calories, then identify which 
batch of ingredients will produce the highest score, and return that high score.
"""
function part2(input, ratiogenerator = ratios4)
    makebatches(x)   = map(ratios -> sum(input .* ratios), x)
    scorebatches(x)  = map(score, x)
    caloriefilter(x) = filter(batch -> batch.calories == 500, x)
    (ratiogenerator()
        |> makebatches
        |> caloriefilter
        |> scorebatches
        |> maximum)
end
