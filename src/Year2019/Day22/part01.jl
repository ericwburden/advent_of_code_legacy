"""
    shuffle(::NewStack,       deck::Vector{Int}) -> Vector{Int}
    shuffle((; n)::Cut,       deck::Vector{Int}) -> Vector{Int}
    shuffle((; n)::Increment, deck::Vector{Int}) -> Vector{Int}

Return a new deck of cards (Vector{Int}) that represents the result
of shuffling the given `deck` using the prescribed strategy.
"""
shuffle(::NewStack, deck::Vector{Int}) = reverse(deck)
shuffle((; n)::Cut, deck::Vector{Int}) = circshift(deck, -n)

function shuffle((; n)::Increment, deck::Vector{Int})
    new_deck = similar(deck)
    place = 1
    for card in deck
        new_deck[place] = card
        place = (place + n - 1) % length(deck) + 1
    end
    return new_deck
end

"""
    part1(input) -> Int

Given the input as a list of shuffles, shuffle the deck using each type of
shuffle in order and return the 0-based index of the deck where card `2019`
resides.
"""
function part1(input)
    deck = collect(0:10_006)
    foreach(t -> deck = shuffle(t, deck), input)
    return (first ∘ indexin)(2019, deck) - 1
end

