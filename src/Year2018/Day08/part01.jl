"Node structure"
struct Node
    header::Tuple{Int,Int}
    children::Vector{Node}
    metadata::Vector{Int}
end

"""
    convert(::Type{Node}, numbers::Vector{Int})

Converts a list of numbers into a `Node`. Recursively converts child nodes
until all nodes are nested inside the returned root node.
"""
function Base.convert(::Type{Node}, numbers::Vector{Int})
    cursor = 1

    function convert_recursively()
        header  = (numbers[cursor], numbers[cursor + 1])
        cursor += 2

        children = [convert_recursively() for _ in 1:header[1]]
        metadata = [numbers[cursor:(cursor + header[2] - 1)]...]
        cursor += header[2]
        return Node(header, children, metadata)
    end

    return convert_recursively()
end

"""
    sum_metadata((; children, metadata)::Node)

Given the root node, sums the value of the root nodes metadata plus the
metadata sum of all child nodes, and returns the result.
"""
function sum_metadata((; children, metadata)::Node)
    child_totals = 0
    for child in children
        child_totals += sum_metadata(child)
    end
    return child_totals + sum(metadata, init = 0)
end

"""
    part1(input)

Convert the input list of numbers to a nested `Node` and return
the sum of all the metadata in all nodes.
"""
function part1(input)
    node = convert(Node, input)
    return sum_metadata(node)
end
