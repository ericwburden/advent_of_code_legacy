function viable_pairs(disks::Matrix{Disk})
    total = 0
    for (a_pos, a_disk) in pairs(disks), (b_pos, b_disk) in pairs(disks)
        a_pos == b_pos   && continue
        a_disk.used == 0 && continue
        if (a_disk.used <= b_disk.avail) total += 1 end
    end
    return total
end

function part1(input)
    return viable_pairs(input)
end
