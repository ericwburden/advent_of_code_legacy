using DataStructures: OrderedSet

"Key: Step Name; Value: Set of steps the key depends on"
const DependencyGraph = Dict{Char,Set{Char}}

"""
    build_dependency_graph(step_order_pairs::Vector{StepOrder})

Given a list of `StepOrder`s, build a `DependencyGraph`, a sort of adjacency
list indicating which steps are prerequisites for other steps.
"""
function build_dependency_graph(step_order_pairs::Vector{StepOrder})
    dependency_graph = DependencyGraph(c => Set() for c = 'A':'Z')
    for (step1, step2) in step_order_pairs
        push!(dependency_graph[step2], step1)
    end
    return dependency_graph
end

"""
    map_step_order(dependency_graph::DependencyGraph)

Given the dependencies of the steps, identify and return the order that the
steps should be completed, according to the rules in the puzzle input.
"""
function map_step_order(dependency_graph::DependencyGraph)
    steps_left = OrderedSet('A':'Z')
    steps_done = OrderedSet()

    while !isempty(steps_left)
        for step in steps_left
            !issubset(dependency_graph[step], steps_done) && continue
            delete!(steps_left, step)
            push!(steps_done, step)
            break
        end
    end

    return steps_done
end

"""
    part1(input)

Given the input as a list of `StepOrder`s, build a dependency graph, identify
the order the steps should be completed in, and return those steps joined into
a string.
"""
function part1(input)
    dependency_graph = build_dependency_graph(input)
    ordered_steps = map_step_order(dependency_graph)
    return join(ordered_steps)
end
