"""
    find_root(structure)

Given the `structure` of the recursive program stack (a dict as an adjacnency
list of dependent programs), identify the program name that is present in 
the keys of `structure` but not in any of the value lists.
"""
function find_root(structure)
    root = foldl(setdiff, values(structure), init = keys(structure))
    return only(root)
end

"""
    part1(input)

Given the `weights` and `structure` from the input, identify and return the
name of the program that lies at the root of the structure. The root program 
is the one that does not depend on any other program.
"""
function part1(input)
    _, structure = input
    return find_root(structure)
end
