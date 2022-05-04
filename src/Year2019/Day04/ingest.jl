"Read in two numbers as a Tuple"
ingest(path) = parse.(Int, split(readline(path), "-")) |> Tuple
