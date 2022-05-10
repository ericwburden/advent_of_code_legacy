using .IntCode: Computer, Running, Halted, add_input!, get_output!, run!

const Tiles = Dict{NTuple{2,Int},Int}

"""
    draw_screen!(computer::Computer) -> (::Computer, ::Tiles)

Run the computer, generating output specifying which tiles to set to which value.
That output is converted to `Tiles`, and the final state of the Computer and
resulting tiles are returned.
"""
function draw_screen!(computer::Computer)
    tiles    = Tiles()
    computer = run!(computer)

    while !isempty(computer.output)
        x    = get_output!(computer)
        y    = get_output!(computer)
        tile = get_output!(computer)
        tiles[(x, y)] = tile
    end
    return (computer, tiles)
end

"Shortcut for counting the number of block tiles"
count_blocks(tiles::Tiles) = count(v -> v == 2, values(tiles))

"""
    part1(input) -> Int

Run the supplied IntCode program, generate tiles, return the number
of block tiles generated.
"""
function part1(input)
    computer = Computer(input)
    _, tiles = draw_screen!(computer)
    return count_blocks(tiles)
end
