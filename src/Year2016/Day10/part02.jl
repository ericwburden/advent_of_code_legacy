"""
    part2(input::TransferList)

Given the input as a list of `AbstractTransfer`s, analyze the list to determine
which chips flow to which robots and outputs. Identify the value of the chips
stored in outputs `0`, `1`, and `2` and return their product.
"""
function part2(input::TransferList)
    system = analyze(input)
    targets = Set{AbstractRepository}([EmptyOutput(0), EmptyOutput(1), EmptyOutput(2)])
    filled = targets ∩ system
    value(x) = x.value
    return mapreduce(value, *, filled)
end
