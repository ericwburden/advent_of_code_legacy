"""
    part2(input)

Given the input as a list of claims, overlay the claims and identify the one
claim that doesn't overlap any others. Depends on there being only one claim
that doesn't overlap.
"""
function part2(input)
    claimed_square_inches = overlay_claims(input)
    all_ids = Set(claim.id for claim in input)

    # Remove all claim ID's from `all_ids` that jointly own any
    # of the square inches
    for claim_list in values(claimed_square_inches)
        # Ignore any square inches claimed by only one elf
        length(claim_list) == 1 && continue
        setdiff!(all_ids, claim_list)
    end

    return first(all_ids)
end
