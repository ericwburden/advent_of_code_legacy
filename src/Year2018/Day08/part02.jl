"""
    node_value((; children, metadata)::Node)

Given a `node`, return the value of the node as described in the puzzle, 
which is the sum of the metadata for a childless node or the sum of child
values (referenced by metadata indices) for a node with children.
"""
function node_value((; children, metadata)::Node)
    isempty(children) && return sum(metadata)

    child_total = 0
    for idx in metadata
        checkbounds(Bool, children, idx) || continue
        child_total += node_value(children[idx])
    end
    return child_total
end

"""
    part2(input)

Convert the input list of numbers to a nested `Node` and return
the value of the root node.
"""
function part2(input)
    node = convert(Node, input)
    return node_value(node)
end
