struct Disk
    used::Int
    avail::Int
end

const DiskPosition = Tuple{Disk,CartesianIndex}

function get_disk_position(s::AbstractString)
    parts = split(s)
    m     = match(r"node-x(?<col>\d+)-y(?<row>\d+)", s)
    row   = parse(Int, m["row"]) + 1
    col   = parse(Int, m["col"]) + 1
    used  = parse(Int, strip(parts[3], ['T']))
    avail = parse(Int, strip(parts[4], ['T']))
    disk  = Disk(used, avail)
    pos   = CartesianIndex(row, col)
    return (disk, pos)
end


function ingest(path)
    lines          = readlines(path)
    disk_positions = get_disk_position.(lines[3:end])
    max_position   = mapreduce(x -> x[2], max, disk_positions)
    rows, cols     = Tuple(max_position)
    disk_grid      = Matrix{Disk}(undef, rows, cols)

    for (disk, position) in disk_positions
        disk_grid[position] = disk
    end

    return disk_grid
end
