"Input is a space separated list of numbers"
ingest(path) = parse.(Int, split(readline(path), " "))
