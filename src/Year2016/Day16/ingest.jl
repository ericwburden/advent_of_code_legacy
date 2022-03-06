"Read in the line from the input file and convert it to a BitVector"
function ingest(path)
    return collect(readchomp(path)) .== '1'
end
