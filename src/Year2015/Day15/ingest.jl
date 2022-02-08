"""
Data structure to keep track of the nutrition information provided by a single
ingredient or a whole batch of ingredients.
"""
struct NutritionInfo
    capacity::Int
    durability::Int
    flavor::Int
    texture::Int
    calories::Int
end

"""
    parse(NutritionInfo, s::String)

Parse a string containing the nutrition information for a single ingredient 
into a `NutritionInfo` struct.
"""
function Base.parse(::Type{NutritionInfo}, s::String)
    toints(x) = map(y -> parse(Int, y.match), x)
    (values 
        =  eachmatch(r"-?\d+", s) 
        |> toints
        |> collect)
    return NutritionInfo(values...)
end

"""
    ingest(path)

Given the path to the input file, parse each line into a `NutritionInfo` and
return the vector of these values.
"""
function ingest(path)
    ingredients = []
    open(path) do f
        for line in eachline(f)
            push!(ingredients, parse(NutritionInfo, line))
        end
    end
    return ingredients
end
