"""
    supports_ssl(ipv7::String)

Given a string, determine if that string supports 'SSL' by checking for an 
'ABA' character sequence outside the square brackets and a corresponding
'BAB' sequence inside the square brackets.
"""
function supports_ssl(ipv7::String)
    aba_found = Set{Tuple{Char,Char,Char}}()
    bab_found = Set{Tuple{Char,Char,Char}}()
    in_hypernet_seq = false

    # Iterate through 3-character chunks of the ipv7 address
    for (c₁, c₂, c₃) in zip(ipv7, ipv7[2:end], ipv7[3:end])
        # Flag whether we're inside a hypernet sequence or not
        if (c₁ == ']')
            in_hypernet_seq = false
        end
        if (c₁ == '[')
            in_hypernet_seq = true
        end

        # If we didn't find an 'aba' sequence, try the next chunk
        (c₁ == c₃ && c₁ != c₂) || continue

        # If we're in a hypernet sequence, record the 'BAB' version, otherwise
        # record the 'ABA' version into it's respective set.
        if in_hypernet_seq
            push!(bab_found, (c₂, c₁, c₂))
        else
            push!(aba_found, (c₁, c₂, c₃))
        end
    end

    # If the sets overlap at all, then 'SSL' is supported
    return !isdisjoint(aba_found, bab_found)
end


"Check each IPv7 address for 'SSL' support and return the count"
part2(input) = count(supports_ssl, input)
