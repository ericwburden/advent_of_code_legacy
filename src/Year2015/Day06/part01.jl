#=------------------------------------------------------------------------------
| These functions modify the `lights` BitMatrix based on the given instruction
------------------------------------------------------------------------------=#

"Set a region of `M` to true"
function apply!(M::BitMatrix, (; topleft, bottomright)::TurnOn) 
    M[topleft:bottomright] .= true
end

"Set a region of `M` to false"
function apply!(M::BitMatrix, (; topleft, bottomright)::TurnOff) 
    M[topleft:bottomright] .= false
end

"Toggle a region of `M`, flipping their values"
function apply!(M::BitMatrix, (; topleft, bottomright)::Toggle)  
    M[topleft:bottomright] .= .!M[topleft:bottomright]
end



"""
    part1(input)

Given the input as a list of `Instruction`s, modify a 1000x1000 BitMatrix
according to each instruction in turn, then return the total number of lights
on at the end.
"""
function part1(input)
    lights = falses(1000, 1000)
    for instruction in input
        apply!(lights, instruction)
    end
    return count(lights)
end
