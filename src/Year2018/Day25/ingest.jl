const Point = NTuple{4,Int}

function into_point(s::AbstractString)::Point
    return Tuple(parse(Int, x) for x in split(s, ","))
end

ingest(path) = into_point.(readlines(path))
