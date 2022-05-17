"""
    most_common(values)

Given an iterable list of `values`, identify and return the value that appears
most commonly in the list.
"""
function most_common(values)
    counts = Dict()
    max_found = 0
    common_val = nothing

    for value in values
        count = get(counts, value, 0) + 1
        counts[value] = count
        if count > max_found
            max_found = count
            common_val = value
        end
    end

    return common_val
end

"""
    part2(input)

Given the `weights` and `structure` of the input, identify the sibling programs 
whose cumulative weights are not all equal, then return the 'corrected' weight
of the one program whose cumulative weight differs. The 'corrected' weight is 
the weight that would cause the program's cumulative weight to equal its 
siblings' cumulative weights. For more details, see the puzzle description.
"""
function part2(input)
    weights, structure = input
    root = find_root(structure)
    cums = deepcopy(weights)
    corrected_weight = nothing

    # Inner recursive function. Writing it this way allows the inner function to
    # access the scope inside the outer function, which makes handling the 
    # otherwise complicated passing of values up and down the call stack much
    # easier. This function updates the `cums` dict with the cumulative weight
    # of each node, with additional functionality to check for imbalanced
    # child nodes and write the weight the unbalanced node should be to
    # `corrected_weight`.
    function accumulate!(node)
        foreach(accumulate!, structure[node])
        child_weights = [cums[child] for child in structure[node]]
        cums[node] += foldl(+, child_weights, init = 0)

        # Don't try to set the corrected weight if one has already been found
        !isnothing(corrected_weight) && return
        common_weight = most_common(child_weights)
        for child in structure[node]
            if cums[child] != common_weight
                adjustment = common_weight - cums[child]
                corrected_weight = weights[child] + adjustment
            end
        end
    end

    accumulate!(root)
    return corrected_weight
end
