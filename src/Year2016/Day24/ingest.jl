const PointsOfInterest = Dict{Int,CartesianIndex}

"""
    ingest(path)

We needed two data structures for today's puzzle (well, I wanted two, at any 
rate). Given the path to the input file, returns a tuple containing a `BitMatrix`
(where true values represent spaces that the robot can move on and false values
represent walls) and a `Dict` indicating where the numbered points are on the
grid.
"""
function ingest(path)
    lines = readlines(path)
    rows = length(lines)
    cols = length(lines[1])
    grid_map = trues(rows, cols)
    poi = PointsOfInterest()

    for (row, line) in enumerate(lines)
        for (col, char) in enumerate(line)
            if (isdigit(char)) 
                int = parse(Int, char)
                poi[int] = CartesianIndex(row, col)
            end
            if (char == '#') grid_map[row, col] = false end
        end
    end

    return (grid_map, poi)
end
