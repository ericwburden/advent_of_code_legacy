"A pair of characters indicating the first step depends on the second"
const StepOrder = Pair{Char,Char}

function Base.parse(::Type{StepOrder}, s::AbstractString)
    m = match(r"Step ([A-Z]).*([A-Z])", s)
    step1, step2 = first.(m.captures)
    return step1 => step2
end

"Parse each line as a `StepOrder` and return the list"
ingest(path) = parse.(StepOrder, readlines(path))
