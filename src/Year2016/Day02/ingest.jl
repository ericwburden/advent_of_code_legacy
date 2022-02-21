const Instruction = Vector{Char}

function ingest(path)
    instructions = Instruction[]
    open(path) do f
        for line in eachline(f)
            push!(instructions, collect(line))
        end
    end
    return instructions
end
