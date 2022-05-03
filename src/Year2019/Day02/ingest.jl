"Read a comma-separated list of numbers"
ingest(path) = parse.(Int, split(readline(path), ","))
