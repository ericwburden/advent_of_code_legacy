"String to one-row matrix of characters"
to_row(s::AbstractString) = reshape(collect(s), 1, :)

"Read the input file into a character matrix"
ingest(path) = mapreduce(to_row, vcat, readlines(path))
