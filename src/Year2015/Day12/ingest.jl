using JSON: parsefile

"Alias for JSON.parsefile, since the input file is a JSON document"
ingest(path) = parsefile(path)