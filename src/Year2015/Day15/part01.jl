"""
    ratios2()

Returns a generator over all the combinations of two numbers (from 0 - 100)
that can sum to 100. Used for testing the two-ingredient examples.
"""
function ratios2()
    Channel() do channel
        for i = 0:100
            put!(channel, (i, 100 - i))
        end
    end
end

"""
    ratios4()

Returns a generator over all the combinations of four numbers (from 0 - 100)
that can sum to 100, ex. (1, 2, 3, 96). Used for exploring the ratios of various
ingredients.
"""
function ratios4()
    Channel() do channel
        for i = 0:100
            for j = 0:(100-i)
                for k = 0:(100-i-j)
                    put!(channel, (i, j, k, 100 - i - j - k))
                end
            end
        end
    end
end

"""
    *(a::NutritionInfo, b::Int)

Operator overloading to allow scaling a `NutritionInfo` by an integer value.
"""
function Base.:*(a::NutritionInfo, b::Int)
    (; capacity, durability, flavor, texture, calories) = a
    return NutritionInfo(
        capacity * b,
        durability * b,
        flavor * b,
        texture * b,
        calories * b,
    )
end

"""
    +(a::NutritionInfo, b::NutritionInfo)

Operator overloading to allow adding two `NutritionInfo` structs to obtain 
a composite struct where each value is the sum of the values in `a` and `b`.
"""
function Base.:+(a::NutritionInfo, b::NutritionInfo)
    return NutritionInfo(
        a.capacity + b.capacity,
        a.durability + b.durability,
        a.flavor + b.flavor,
        a.texture + b.texture,
        a.calories + b.calories,
    )
end

"""
    score(i::NutritionInfo)

Score a particular `NutritionInfo` according to the puzzle rules, setting each
negative value to 0 and multiplying together the capacity, durability,
flavor, and texture values.
"""
function score((; capacity, durability, flavor, texture)::NutritionInfo)
    any(x -> x <= 0, (capacity, durability, flavor, texture)) && return 0
    return prod((capacity, durability, flavor, texture))
end

"""
    part1(input, ratiogenerator)

Given the input as a list of `NutritionInfo` and a function for generating all
the combinations of ingredients that can sum to 100 total, identify which 
batch of ingredients will produce the highest score, and return that high score.
"""
function part1(input, ratiogenerator = ratios4)
    makebatches(x) = map(ratios -> sum(input .* ratios), x)
    scorebatches(x) = map(score, x)
    (ratiogenerator() |> makebatches |> scorebatches |> maximum)
end
