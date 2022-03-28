"Regular expression for parsing lines from the input"
const LINE_RE = r"(?<name>\w+) \((?<wgt>\d+)\)( -> (?<holds>[\w, ]+))?"

"""
    ingest(path)

Given the path to the input file, parse each line into an entry into a `weights`
dict and `structure` dict. `weights` contains one entry per line, where the key
is the program name and the value is the 'weight' of that program. `structures`
also contains one entry per line, where the key is the name of the program and
the value is a list of the program names that depend on the key program.

Returns a tuple of (<weights>, <structure>).
"""
function ingest(path)
    weights   = Dict()
    structure = Dict()

    for line in readlines(path)
        m     = match(LINE_RE, line)
        name  = m["name"]
        wgt   = parse(Int, m["wgt"])
        holds = m["holds"]
        weights[name] = wgt
        structure[name] = isnothing(holds) ? [] : split(holds, ", ")
    end

    return (weights, structure)
end
