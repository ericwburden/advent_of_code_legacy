"""
    part2!(input::CircuitDiagram)

Given the `input` `CircuitDiagram`, replace the input of `Wire("b")` with the
`Raw` output of Part 1. Again, trace the diagram starting with `Wire("a")`
and return the value output to `Wire("a")`.
"""
function part2!(input, part1answer)
    input[Wire("b")] = Assign(Raw(part1answer))
    return trace!(input, Wire("a"))
end
