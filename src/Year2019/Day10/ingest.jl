"Read in the input file as a character matrix"
ingest(path) =
    open(path) do f
        row(line) = reshape(collect(line), 1, :)
        return mapreduce(row, vcat, eachline(f))
    end
