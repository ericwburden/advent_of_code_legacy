"Read the input file as an integer vector"
ingest(path) = [parse(Int, c) for c in collect(readline(path))]
