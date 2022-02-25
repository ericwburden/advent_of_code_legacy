"""
    Marker(chars::Int, reps::Int)

Represents a text compression marker.
"""
struct Marker
    chars::Int
    reps::Int
end

"""
    parse(::Type{Marker}, s::AbstractString)

Parse a string into a Marker if it matches the format "(<number>x<number>)"
"""
function Base.parse(::Type{Marker}, s::AbstractString)
    m = match(r"(\d+)x(\d+)", s)
    chars, reps = parse.(Int, m.captures)
    Marker(chars, reps)
end


"""
    RegularText(text::String)                      <: Token
    CompressedText(marker::Marker, string::String) <: Token

Represents a text element from the input string, either a bit of normal, 
uncompressed text or a bit of compressed text with the compression marker.
"""
abstract type Token end

struct RegularText    <: Token
    text::String
end

struct CompressedText <: Token
    marker::Marker
    text::String
end

"Is this string a compression marker?"
ismarker(s::AbstractString) = contains(s, r"^\(\d+x\d+\)$")

"""
    tokenize(str::AbstractString)

Parses a string compressed with the compression algorithm described in the 
puzzle into `Token`s whose uncompressed length can be readily determined.
"""
function tokenize(str::AbstractString)
    buffer = ""
    tokens = Token[]
    index  = 1

    while index <= length(str)
        # If the buffer contains a marker, we've found a compressed bit of text
        # to tokenize as such. Otherwise, add the next character to the buffer
        # and move on.
        if ismarker(buffer)
            marker = parse(Marker, buffer)
            text   = str[index:(index+marker.chars-1)]
            buffer = ""
            index += marker.chars
            push!(tokens, CompressedText(marker, text))
            continue
        end

        # Any text not in a compressed bit should be tokenized as regular text
        if str[index] == '(' && !isempty(buffer)
            push!(tokens, RegularText(buffer))
            buffer = "$(str[index])"
            index += 1
            continue
        end

        buffer *= str[index]
        index  += 1
    end

    # Add any remaining text after the last compressed bit
    !isempty(buffer) && push!(tokens, RegularText(buffer))

    return tokens
end

# Overload the default `length` function for `Token`s
Base.length((; text)::RegularText) = length(text)
Base.length((; marker, text)::CompressedText) = length(text) * marker.reps


"""
    part1(input)

Given the input as a compressed string, tokenize the compressed string and
determine how long the uncompressed string would be as described in part one
of the puzzle.
"""
function part1(input)
    tokens = tokenize(input)
    return mapreduce(length, +, tokens)
end
