using .IntCode: Running, Halted, execute!
using DataStructures: Queue, enqueue!, dequeue!

"""
    run_with_feedback(code::Vector{Int}, phases::Vector{Int})

Run five computers, in series, each taking in it's assigned phase and
the output from the previous computer as input (the first computer gets
an input of zero). Continue running the computers in a loop, feeding back
the value from the previous computer, until one of the computers halts.
Return the last value output from the fifth computer.
"""
function run_with_feedback(code::Vector{Int}, phases::Vector{Int})
    input     = 0
    max_value = 0
    computers = Queue{Tuple{Int,Computer}}()
    foreach(i -> enqueue!(computers, (i, (Computer ∘ deepcopy)(code))), 1:5)

    # Assign each phase to its computer's input
    for ((_, computer), phase) in zip(computers, phases)
        add_input!(computer, phase)
    end

    @label feedback
    (idx, computer) = dequeue!(computers)
    add_input!(computer, input)

    # Run the computer until it produces output (or halts), and 
    # immediately pass the output to the next computer in sequence
    while isempty(computer.output)
        # Whenever a computer halts, return the last `max_value`
        computer isa Computer{Halted} && return max_value
        computer = execute!(computer)
    end
    input = get_output!(computer)

    # Since we want to return the last value from computer 5
    idx == 5 && (max_value = input)
    enqueue!(computers, (idx, computer))
    @goto feedback # continue feedback until a computer halts
end

"""
    part2(input)

Run all permutations of the phases 5-9 through the amplifiers, feeding
results back into the firts computer in a loop, and return the maximum
output found.
"""
function part2(input)
    loop_output(p) = run_with_feedback(input, p)
    return maximum(loop_output, permutations((5, 6, 7, 8, 9)))
end
