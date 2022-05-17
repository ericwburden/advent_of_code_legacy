"Type aliases"
const Component = Tuple{Int,String}
const Recipes = Dict{String,Tuple{Int,Vector{Component}}}

"""
    parse_component(s::AbstractString) -> Component

Parse a string in the format "<number> <string>" into a `Component`.
"""
function parse_component(s::AbstractString)
    amount, name = split(s)
    amount = parse(Int, amount)
    name = string(name)
    return (amount, name)
end

"""
    ingest(path) = open(path) -> Recipes
    
Parse each line from the input into an entry in a `Recipes`.
"""
ingest(path) =
    open(path) do f
        recipes = Recipes()
        for line in eachline(f)
            left, right = split(line, " => ")
            ingredients = map(s -> parse_component(s), split(left, ", "))
            amount, name = parse_component(right)
            recipes[name] = (amount, ingredients)
        end
        return recipes
    end
