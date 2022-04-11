"""
    ingest(path)

Parse out the two numbers from the input file and return them as a tuple.
"""
function ingest(path)
    m = match(r"(\d+)[^\d]+(\d+)", readline(path))
    p, m = parse.(Int, m.captures)
    return (players = p, last_marble = m)
end
