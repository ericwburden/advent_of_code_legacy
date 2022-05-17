"Read the lines into a character matrix"
ingest(path) = mapreduce(collect, hcat, readlines(path))
