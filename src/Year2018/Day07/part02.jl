using DataStructures: BinaryMinHeap

"Represents a worker working on the sleigh."
struct Worker
    working_on::Union{Nothing,Char}
    turns_left::Int
end
Worker() = Worker(nothing, 0)

is_ready((; working_on)::Worker) = isnothing(working_on)

# Since the ASCII representations of 'A':'Z' are 65:90, subtracting
# 64 from their representation gives a range of 1:26.
assign(step::Char) = Worker(step, 60 + (step - Char(64)))


"Represents the state of the ongoing work"
struct WorkQueue
    workers::Vector{Worker}
    ready::BinaryMinHeap{Char}
    completed::Set{Char}
    dependencies::DependencyGraph
end

"""
    WorkQueue(n_workers::Int, dependencies::DependencyGraph)

Construct a `WorkQueue` with `n_workers` idle workers and the given 
graph of dependencies.
"""
function WorkQueue(n_workers::Int, dependencies::DependencyGraph)
    workers = fill(Worker(), n_workers)
    ready   = BinaryMinHeap{Char}()
    completed = Set{Char}()
    return WorkQueue(workers, ready, completed, dependencies)
end

can_assign((; workers)::WorkQueue) = any(is_ready, workers)
any_ready((; ready)::WorkQueue)    = !isempty(ready)

function all_done((; workers, dependencies)::WorkQueue)   
    return all(is_ready, workers) && isempty(dependencies)
end

"""
    assign!(work_queue::WorkQueue)

Assign steps from the steps that are 'ready' to idle workers, in alphabetical
order.
"""
function assign!(work_queue::WorkQueue)
    while any_ready(work_queue) && can_assign(work_queue)
        step = pop!(work_queue.ready)
        widx = findfirst(is_ready, work_queue.workers)
        work_queue.workers[widx] = assign(step)
    end
end

"""
    work!(work_queue::WorkQueue) 

For each worker in the `WorkQueue`, have the worker complete one second of 
work. If the worker completes a step, set them to be idle and add the completed
step to the set of completed steps.
"""
function work!(work_queue::WorkQueue) 
    for (idx, worker) in enumerate(work_queue.workers)
        (; working_on, turns_left) = worker
        isnothing(working_on) && continue
        if turns_left > 1
            work_queue.workers[idx] = Worker(working_on, turns_left - 1)
        else
            work_queue.workers[idx] = Worker()
            push!(work_queue.completed, working_on)
        end
    end
end

"""
    queue_ready!((; ready, completed, dependencies)::WorkQueue)

Move all the steps whose prerequisites have been completed to the `ready`
queue and remove their entries from `dependencies`.
"""
function queue_ready!((; ready, completed, dependencies)::WorkQueue)
    for (step, requirements) in dependencies
        !issubset(requirements, completed) && continue
        push!(ready, step)
        delete!(dependencies, step)
    end
end

"""
    update!(work_queue::WorkQueue)

Handy wrapper around the three functions needed to move the entire `WorkQueue` 
forward by one second.
"""
function update!(work_queue::WorkQueue)
    work!(work_queue)
    queue_ready!(work_queue)
    assign!(work_queue)
end

"""
    build_sleigh!(dependencies::DependencyGraph)

Initialize a work queue with 5 total workers and being processing the steps
to build the sleigh. Once all steps are processed, return the total time
needed to build the sleigh.
"""
function build_sleigh!(dependencies::DependencyGraph)
    total_time  = 0
    work_queue  = WorkQueue(5, dependencies)
    update!(work_queue)

    while !all_done(work_queue)
        total_time += 1
        update!(work_queue)
    end

    return total_time
end

"""
    part2(input)

Given the input as a list of `StepOrder`s, build a sleigh and return how
many seconds it took to do it.
"""
function part2(input)
    dependencies = build_dependency_graph(input)
    return build_sleigh!(dependencies)
end