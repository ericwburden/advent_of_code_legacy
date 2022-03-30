"""
    ingest(path)

Given the path to the input file, create an adjacency list with one entry per
program (indicated by an Int) containing a Set of connected programs (Set{Int}).
Since all connections are undirected, every program (Int) that appears in a
set will have its own entry.
"""
function ingest(path)::Dict{Int,Set{Int}}
    adjacency_list = Dict{Int,Set{Int}}()
    open(path) do f
        for line in eachline(f)
            left, right = split(line, " <-> ")
            left_num    = parse(Int, left)
            right_nums  = [parse(Int, n) for n in split(right, ", ")]
            all_nums    = Set([left_num, right_nums...])

            for num in all_nums
                other_nums  = setdiff(all_nums, [num])
                current_set = get(adjacency_list, num, Set())
                adjacency_list[num] = current_set ∪ other_nums
            end
        end
    end
    return adjacency_list
end
