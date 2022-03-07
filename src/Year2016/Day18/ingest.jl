"Read in the input as a BitVector, 1's represent trapped tiles"
ingest(path) = collect(readchomp(path)) .== '^'
