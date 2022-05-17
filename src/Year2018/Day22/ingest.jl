"""
    ingest(path)

Given the path to the input file, parse out the cave depth and the 
location of the target, convert to numbers as appropriate, and return
a tuple containing depth and target location.
"""
ingest(path) =
    open(path) do f
        first_line, second_line = readlines(f)
        _, depth_str = split(first_line)
        _, target_str = split(second_line)
        depth = parse(Int, depth_str)
        target_x, target_y = parse.(Int, split(target_str, ","))
        return (depth, (target_x, target_y))
    end
