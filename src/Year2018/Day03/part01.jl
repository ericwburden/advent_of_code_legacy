"""
    overlay_claims(claims::Vector{Claim})

Given a list of claims, return a dictionary where each key is a coordinate for
a specific square inch of the fabric and the value is a list of the claim ID's
that include that square inch of fabric.
"""
function overlay_claims(claims::Vector{Claim})
    claimed_square_inches = Dict()

    for (; id, rows, cols) in claims
        for square_inch in Iterators.product(rows, cols)
            current = get!(claimed_square_inches, square_inch, [])
            push!(current, id)
        end
    end

    return claimed_square_inches
end


"""
    part1(input)

Given the input as a list of claims, overlay all the claims and count the number
of square inches claimed by more than one elf.
"""
function part1(input)
    claimed_square_inches = overlay_claims(input)
    return count(x -> length(x) > 1, values(claimed_square_inches))
end
