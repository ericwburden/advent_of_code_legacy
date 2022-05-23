"Convert a string to a BitMatrix row, where '#' -> 1"
to_row(line) = reshape(collect(line) .== '#', 1, :)

"Read the input file and map each line to a row in a BitMatrix"
ingest(path) = mapreduce(to_row, vcat, readlines(path))
