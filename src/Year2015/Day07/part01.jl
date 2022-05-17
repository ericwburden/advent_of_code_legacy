#=------------------------------------------------------------------------------
| Using function overloading, provides a set of functions to recursively search
| the `CircuitDiagram` for the raw signal provided to a given `Wire`. The
| input `CircuitDiagram` is modified on each pass, providing memoization for
| the entire operation.
------------------------------------------------------------------------------=#

"""
    trace!(circuit_diagram::CircuitDiagram, wire::Wire)

If the referenced `Wire` is receiving a Raw input, return the value of the 
input. Otherwise, recursively search for the input value and return it
when calculated. Modifies the input `circuit_diagram` to update the 
given `wire` with it's Raw input when found.
"""
function trace!(circuit_diagram::CircuitDiagram, wire::Wire)
    operation = circuit_diagram[wire]
    output = trace!(circuit_diagram, operation)
    circuit_diagram[wire] = Assign(Raw(output))
    return output
end

"""
    trace!(circuit_diagram::CircuitDiagram, (; input)::Assign)

If the referenced `Assign` is assigning a `Raw` value, then just return
the value. Otherwise, recursively search the `circuit_diagram` for the value
and return it.
"""
function trace!(circuit_diagram::CircuitDiagram, (; input)::Assign)
    return input isa Raw ? input.value : trace!(circuit_diagram, input)
end

"""
    trace!(circuit_diagram::CircuitDiagram, (; input)::Not)

If the referenced `Not` contains a `Raw` input, return the bitwise complement
of the `Raw` value. Otherwise, recursively search the `circuit_diagram` for the
value and return it's bitwise complement.
"""
function trace!(circuit_diagram::CircuitDiagram, (; input)::Not)
    return input isa Raw ? ~input.value : ~trace!(circuit_diagram, input)
end

"""
    trace!(circuit_diagram::CircuitDiagram, (; left, right)::And)

If the referenced `And` contains a `Raw` for both left and right, return the 
bitwise `and` of the two `Raw` values. Otherwise, recursively search the 
`circuit_diagram` for either (or both) inputs and return the bitwise `and`
of their values.
"""
function trace!(circuit_diagram::CircuitDiagram, (; left, right)::And)
    leftval = left isa Raw ? left.value : trace!(circuit_diagram, left)
    rightval = right isa Raw ? right.value : trace!(circuit_diagram, right)
    return leftval & rightval
end

"""
    trace!(circuit_diagram::CircuitDiagram, (; left, right)::And)

If the referenced `Or` contains a `Raw` for both left and right, return the 
bitwise `or` of the two `Raw` values. Otherwise, recursively search the 
`circuit_diagram` for either (or both) inputs and return the bitwise `or`
of their values.
"""
function trace!(circuit_diagram::CircuitDiagram, (; left, right)::Or)
    leftval = left isa Raw ? left.value : trace!(circuit_diagram, left)
    rightval = right isa Raw ? right.value : trace!(circuit_diagram, right)
    return leftval | rightval
end

"""
    trace!(circuit_diagram::CircuitDiagram, (; input, magnitude)::LeftShift)

If the referenced `LeftShift` contains a `Raw` for both input and magnitude, 
return the result of left shifting the value of the input by the magnitude. 
Otherwise, recursively search the `circuit_diagram` for either (or both) the
input and magnitude and return the left shifted result of their values.
"""
function trace!(circuit_diagram::CircuitDiagram, (; input, magnitude)::LeftShift)
    inputval = input isa Raw ? input.value : trace!(circuit_diagram, input)
    magval = magnitude isa Raw ? magnitude.value : trace!(circuit_diagram, magnitude)
    return inputval << magval
end

"""
    trace!(circuit_diagram::CircuitDiagram, (; input, magnitude)::RightShift)

If the referenced `RightShift` contains a `Raw` for both input and magnitude, 
return the result of right shifting the value of the input by the magnitude. 
Otherwise, recursively search the `circuit_diagram` for either (or both) the
input and magnitude and return the right shifted result of their values.
"""
function trace!(circuit_diagram::CircuitDiagram, (; input, magnitude)::RightShift)
    inputval = input isa Raw ? input.value : trace!(circuit_diagram, input)
    magval = magnitude isa Raw ? magnitude.value : trace!(circuit_diagram, magnitude)
    return inputval >> magval
end

"""
    part1!(input::CircuitDiagram)

Given the `input` `CircuitDiagram`, trace the diagram starting with `Wire("a")`
and return the value output to `Wire("a")`.
"""
part1!(input::CircuitDiagram) = trace!(input, Wire("a"))
