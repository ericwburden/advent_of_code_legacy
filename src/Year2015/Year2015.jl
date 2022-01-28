module Year2015

export Day01

const DAYMODRE = r"Day\d{2}/Day\d{2}.jl$"
for (root, _, files) in walkdir(@__DIR__)
    for file in files
        filepath = joinpath(root, file)
        if occursin(DAYMODRE, filepath)
            include(filepath)
        end
    end
end

end # module
