using Nettle

"""
    valid_hashes(salt::String)

Given a `salt`, return a generator over the 'valid' MD5 hashes derived from the
salt + an increasing integer. Valid hashes are those that begin with five 
consecutive zeros.
"""
function valid_hashes(salt::String)
    Channel() do channel
        for i = 1:typemax(Int)
            check = salt * string(i)
            digest = hexdigest("md5", check)
            startswith(digest, "00000") && put!(channel, digest)
        end
    end
end

"""
    part1(input)

Given the input string, generate 8 valid hashes from it and construct a
password from the 6th character of each hash.
"""
function part1(input)
    password_hashes = Iterators.take(valid_hashes(input), 8)
    password_chars = map(s -> s[6], password_hashes)
    return join(password_chars)
end
