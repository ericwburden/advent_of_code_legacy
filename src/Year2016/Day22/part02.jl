using DataStructures: PriorityQueue, enqueue!, dequeue!
"""
    pprint(disks::Matrix{Disk})

This is a deceptively important function here. According to Eric Wastl, the
intended solution involves looking at the overall set of disks (nodes) and 
moving the 'hole' (empty disk space) to the target disk, then using that
hole to move the data from the target disk to the accessible disk. With this
representation, this puzzle can be solved by hand.
"""
function pprint(disks::Matrix{Disk})
    for (rowidx, row) in enumerate(eachrow(disks))
        for (colidx, disk) in enumerate(row)
            if rowidx == 1 && colidx == 1 
                print('0')
            elseif rowidx == 1 && colidx == length(row) 
                print('G')
            elseif disk.used > 92 
                print('#')
            elseif disk.used == 0 
                print('_')
            else 
                print('+')
            end
        end
        println()
    end
    println()
end

"""
    neighbors(disks::Matrix{Disk}, idx::CartesianIndex)

Given an matrix of `Disk`s and an index into that matrix, return a list of the
reachable neighbors from that index. Reachable neighbors are those disks that 
are in the array AND can fit their data onto the current disk. Because of the
specific setup, this means that the neighbor disk's used space is <= 92, which 
is the capacity of the 'hole' we're moving around.
"""
function neighbors(disks::Matrix{Disk}, idx::CartesianIndex)
    offsets  = [CartesianIndex(-1, 0), CartesianIndex(1, 0),
                CartesianIndex(0, -1), CartesianIndex(0, 1)]
    possible = filter(x -> checkbounds(Bool, disks, x), offsets .+ [idx]) 
    return filter(x -> disks[x].used <= 92, possible)
end

"""
    heuristic(current::CartesianIndex, goal::CartesianIndex)

A* heuristic, just the Manhattan distance from `current` to `goal`.
"""
function heuristic(current::CartesianIndex, goal::CartesianIndex)
    return mapreduce(abs, +, Tuple(current - goal))
end


"""
    shortest_path(disks::Matrix{Disk}, start::CartesianIndex, goal::CartesianIndex)

A* algorithm, calculates the shortest path from `start` to `goal`. Backtracking
and path bookkeeping have been removed since they're not needed for this puzzle.
"""
function shortest_path(disks::Matrix{Disk}, start::CartesianIndex, goal::CartesianIndex)
    frontier = PriorityQueue{CartesianIndex,Int}(start => 0)
    steps    = Dict{CartesianIndex,Int}(start => 0)

    while !isempty(frontier)
        current = dequeue!(frontier)
        current == goal && return steps[current]

        for next in neighbors(disks, current)
            next ∈ keys(steps) && continue  # No backtracking!
            new_steps = steps[current] + 1
            if get!(steps, next, typemax(Int)) > new_steps
                priority       = new_steps + heuristic(next, goal)
                steps[next]    = new_steps
                frontier[next] = priority
            end
        end
    end
end

"""
    find_hole(disks::Matrix{Disk})

There's one disk in `disks` considered a 'hole', an empty disk that can have 
all the data from any disk (other than the massive ones) transferred to it. 
Since we're moving this empty capacity around as a 'hole', we find it by
searching for the empty disk and returning its index.
"""
function find_hole(disks::Matrix{Disk})
    for (idx, disk) in pairs(disks)
        disk.used == 0 && return idx
    end
    error("Could not find hole!")
end

"""
    part2(input)

Way over-optimized solution to this puzzle. In truth, I solved it by hand and
copied the procedure to this function. We use A* to find the number of 
'movable' disks between the 'hole' and the disk containing the data. Then, we
determine the number of disks between the data and the 'goal' disk, where we
can access it. Using the dance described in the puzzle input, each step from 
the 'data' disk to the 'goal' disk takes 5 data moves. Return the total number
of data moves needed to get the empty capacity to the disk _next to_ the data, 
then to move the data to the goal disk.
"""
function part2(input)
    hole_idx     = find_hole(input)
    _, cols      = size(input)
    data_idx     = CartesianIndex(1, cols)
    hole_to_data = shortest_path(input, hole_idx, data_idx)

    goal_idx     = CartesianIndex(1, 1)
    data_to_goal = shortest_path(input, data_idx, goal_idx) - 1
    return hole_to_data + (5*data_to_goal)
end
