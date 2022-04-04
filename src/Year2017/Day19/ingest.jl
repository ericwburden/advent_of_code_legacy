"Convert a string to a one-row character matrix"
Base.convert(::Matrix{Char}, s::String) = reshape(collect(s), 1, :)

"Read in the input file as a character matrix"
ingest(path) = reduce(vcat, convert(Matrix{Char}, l) for l in readlines(path))