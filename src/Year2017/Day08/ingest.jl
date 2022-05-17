const Registers = Dict{String,Int}

"""
    preprocess(s::AbstractString)

Given a part of a string from the input file (either the part before or after
the ' if '), parse out the string representing the name of the register, the
string representing the operator, and the numeric value. Return them as a 
tuple in the form of (<register>, <operator>, <value>).
"""
function preprocess(s::AbstractString)
    m = match(r"(?<reg>\w+) (?<op>[\w><=!]+) (?<val>-?\d+)", s)
    op = string(m["op"])
    val = parse(Int, m["val"])
    reg = string(m["reg"])
    return (reg, op, val)
end

"""
    update_fn_from(s::AbstractString)

Given the first part of a string from the input, parse the components from the
string and return a function that takes a set of `Registers` and updates the
indicated register (from the input line) according to the format of the input, 
either incrementing or decrementing the register by the indicated amount. 
Returns the value of the register.
"""
function update_fn_from(s::AbstractString)
    reg, op_str, value = preprocess(s)
    op_fn = op_str == "inc" ? Base.:+ : Base.:-
    operate(x) = op_fn(x, value)

    return function update!(registers::Registers)
        register_value = get!(registers, reg, 0)
        registers[reg] = operate(register_value)
        return registers[reg]
    end
end

"""
    check_fn_from(s::AbstractString)

Given the second part of a string from the input, parse the components from the
string and return a function that takes a set of `Registers` and returns a
boolean value indicating whether the value stored in the indicated register 
satisfies the comparison with the given value.
"""
function check_fn_from(s::AbstractString)
    reg, op_str, value = preprocess(s)
    op_fn = getfield(Main, Symbol(op_str))
    compare(x) = op_fn(x, value)

    return function check(registers::Registers)
        register_value = get(registers, reg, 0)
        return compare(register_value)
    end
end

"""
    execute_fn_from(s::AbstractString)

Given a string from the input file, parse the first part into an `update!` 
function and parse the second part into a `check` function. Returns a function
that takes a set of `Registers` and updates the indicated register according
to the instructions, returning the value in the register.
"""
function execute_fn_from(s::AbstractString)
    update, check = split(s, " if ")
    update! = update_fn_from(update)
    check = check_fn_from(check)

    return function execute!(registers::Registers)
        check(registers) && return update!(registers)
    end
end

"""
    ingest(path)

Given the path to the input file, parse each line from the input into a
function to execute the described instruction. Return the list of functions.
"""
ingest(path) = execute_fn_from.(readlines(path))
