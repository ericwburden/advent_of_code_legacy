"Just an integer today"
ingest(path) = parse(UInt32, readchomp(path))
