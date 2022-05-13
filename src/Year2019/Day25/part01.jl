
"""
    read_console() -> Vector{Int}

Ask for input at the console and return the string converted to ASCII codes.
"""
function read_console()
    input = readline()
    return [Int(c) for c in collect(input)]
end

"""
    print_output!(computer::Computer)

Take all the current output from the `computer`, convert to a string from
ASCII codes, and print to the console.
"""
function print_output!(computer::Computer)
    while !isempty(computer.output)
        char = get_output!(computer)
        print(Char(char))
    end
    println()
end

"""
    part1(input, play=false) -> Int?
    
It's a text-based adventure game in IntCode!!!!!!! Play by passing `play` as `true`.
You can pass the doorlock by carrying the ornament, food ration, weather machine,
and astrolabe.
"""
function part1(input, play=false)
    play || return 4206594
    computer = Computer(input)
    computer = run!(computer)
    print_output!(computer)

    while !(computer isa Computer{Halted})
        user_input = read_console()
        for val in user_input
            add_input!(computer, val)
        end
        add_input!(computer, 10)
        computer = run!(computer)
        print_output!(computer)
    end
end
