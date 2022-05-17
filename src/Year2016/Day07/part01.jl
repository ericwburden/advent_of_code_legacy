"""
    supports_tls(ipv7::String)

Given a string, determine if that string supports TLS by checking for an 
'ABBA' character pattern outside the square brackets, and no 'ABBA' inside
any set of square brackets.
"""
function supports_tls(ipv7::String)
    in_hypernet_seq = false
    found_abba = false

    # Iterate through 4-character chunks of the ipv7 address
    for (c₁, c₂, c₃, c₄) in zip(ipv7, ipv7[2:end], ipv7[3:end], ipv7[4:end])
        # Flag whether we're inside a hypernet sequence or not
        if (c₁ == ']')
            in_hypernet_seq = false
        end
        if (c₁ == '[')
            in_hypernet_seq = true
        end

        # If the character pattern like 'abba'
        pattern_found = (c₁ == c₄ && c₂ == c₃ && c₁ != c₂)

        # If found in a hypernet sequence, return false
        (pattern_found && in_hypernet_seq) && return false
        if (pattern_found)
            found_abba = true
        end
    end

    return found_abba
end

"Check each IPv7 address for 'TLS' support and return the count"
part1(input) = count(supports_tls, input)
