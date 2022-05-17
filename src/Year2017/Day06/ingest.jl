parse_ints(x) = map(s -> parse(Int, s), x)
ingest(path) = readline(path) |> split |> parse_ints
