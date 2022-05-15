"Read input as a list of integers"
ingest(path) = [parse(Int, c) for c in collect(readline(path))]
