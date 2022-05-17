"Type alias for convenience"
const Triangles = Vector{Sides}

"""
    regroup(triangles::Triangles)

Given a `Triangles`, reshape the vector such that each `Sides` in the output
contains numbers from the three consecutive `Sides` in the input in the same 
position. Example as shown:

1. (1, 2, 3)  >  (1, 1, 1)
2. (1, 2, 3)  >  (2, 2, 2)
3. (1, 2, 3)  >  (3, 3, 3)
"""
function regroup(triangles::Triangles)
    regrouped = Sides[]

    for first_row = 1:3:length(triangles)
        for col = 1:3
            new_sides = Tuple([triangles[r][col] for r = first_row:first_row+2])
            push!(regrouped, new_sides)
        end
    end

    return regrouped
end

"Check the regrouped input for triangles and return the count of valid triangles"
part2(input) = mapreduce(istriangle, +, regroup(input))
