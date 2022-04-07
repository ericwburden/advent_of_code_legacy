"""
    can_react(c1::Char, c2::Char)

Two 'units' (characters) can react if they are the same letter, one lowercase
and one uppercase. For example, 'a' and 'A' can react, but not 'a' and 'a', or 
'a' and 'B'.
"""
can_react(::Nothing, ::Char) = false
function can_react(c1::Char, c2::Char)
    # The difference in the ASCII value for a capital letter and
    # its corresponding lowercase letter is exactly '32`.`
    return abs(c1 - c2) == 32
end

"""
    react_polymer(polymer::String)

Given a string representing a polymer, remove adjacent units that can react
until all reactive adjacent units are removed, and return the resulting string.
"""
function react_polymer(polymer::String)
    stack = []
    for char in polymer
        last_char = isempty(stack) ? nothing : pop!(stack)
        can_react(last_char, char) && continue
        isnothing(last_char) || push!(stack, last_char)
        push!(stack, char)
    end
    return join(stack)
end

"Return the length of the fully reacted input (polymer)"
part1(input) = (length ∘ react_polymer)(input)
