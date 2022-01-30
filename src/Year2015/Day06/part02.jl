#=------------------------------------------------------------------------------
| These functions modify the `lights` Matrix based on the given instruction
------------------------------------------------------------------------------=#

"Increase the value of the indicated lights by 1"
function apply!(lights::Matrix{Int}, (; topleft, bottomright)::TurnOn) 
    lights[topleft:bottomright] .+= 1
end

"Decrease the value of the indicated lights by 1, minimum 0"
function apply!(lights::Matrix{Int}, (; topleft, bottomright)::TurnOff) 
    lights[topleft:bottomright] .-= 1
    lights[lights .< 0] .= 0
end

"Increase the value of the indicated lights by 2"
function apply!(lights::Matrix{Int}, (; topleft, bottomright)::Toggle)  
    lights[topleft:bottomright] .+= 2
end



"""
    part2(input)

Given the input as a list of `Instruction`s, modify a 1000x1000 Matrix{Int}
according to each instruction in turn, then return the total brightness of
all lights on at the end.
"""
function part2(input)
    lights = zeros(Int, 1000, 1000)
    for instruction in input
        apply!(lights, instruction)
    end
    return sum(lights)
end
