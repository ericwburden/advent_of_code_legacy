"""
    ingest(path)

Given the path to the input file, read each line as a Int and return
a Vector{Int}
"""
ingest(path) = parse.(Int, readlines(path))
