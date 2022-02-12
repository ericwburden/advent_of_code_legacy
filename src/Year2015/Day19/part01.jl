# Helper functions!
pipe_join(strings)  = join(strings, "|")
replace_re(strings) = strings |> pipe_join |> Regex

"""
    replace_match(str::String, regex_match::RegexMatch, replacement::String)

Given a String `str`, a `RegexMatch` into that String, and a `replacement` 
String, return a string where the matched characters are replaced by 
`replacement`.
"""
function replace_match(str::String, regex_match::RegexMatch, replacement::String)
    prefix_end   = regex_match.offset - 1
    suffix_start = regex_match.offset + length(regex_match.match)
    last_idx     = length(str)
    prefix       = prefix_end >= 1 ? str[1:prefix_end] : ""
    suffix       = suffix_start <= last_idx ? str[suffix_start:end] : ""
    return prefix * replacement * suffix
end

"""
    can_fabricate(molecule, replacements)

Given a `molecule` and a mapping of `replacements` (the two pieces parsed by 
`input()`), return a Set of all the molecules (Strings) that can be fabricated
by making a single replacement.
"""
function can_fabricate(molecule, replacements)
    fabricated = Set{String}()
    stash_molecule!(mol) = push!(fabricated, join(mol))
    regex = keys(replacements) |> replace_re

    for regex_match in eachmatch(regex, molecule)
        fabricate(x) = replace_match(molecule, regex_match, x)
        new_molecules = map(fabricate, replacements[regex_match.match])
        foreach(stash_molecule!, new_molecules)
    end

    return fabricated
end


"""
    part1(input)

Given the input as a tuple of a replacement mapping and initial molecule,
return the count of all unique new molecules that can be fabricated by
making a single replacement in the initial molecule.
"""
function part1(input)
    replacements, molecule = input
    return can_fabricate(molecule, replacements) |> length
end