"Read each line and parse as an Int"
ingest(path) = [parse(Int, l) for l in readlines(path)]
