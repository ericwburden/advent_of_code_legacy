"""
    ingest(path)

Given the path to the input file, return a vector of integers containing each
individual digit in the single line of the file.
"""
ingest(path) = [parse(Int, c) for c in readline(path)]
