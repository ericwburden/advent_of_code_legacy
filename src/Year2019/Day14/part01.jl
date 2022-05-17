"""
An `Inventory` represents an inventory of unused materials that may
be available for producing additional components.
"""
struct Inventory
    inventory::Dict{String,Int}
end

"Empty constructor"
Inventory() = Inventory(Dict{String,Int}())

"""
    check_out!((; inventory)::Inventory, material::String, amount::Int)

Take `material` from the `inventory`, up to `amount`, and return the total
amount of material taken.
"""
function check_out!((; inventory)::Inventory, material::String, amount::Int)
    found = get!(inventory, material, 0)
    taken = found > amount ? amount : found
    inventory[material] -= taken
    return taken
end

"""
    check_in!((; inventory)::Inventory, material::String, amount::Int)

Add the `amount` of `material` to the `inventory`.
"""
function check_in!((; inventory)::Inventory, material::String, amount::Int)
    found = get!(inventory, material, 0)
    inventory[material] = found + amount
end

"""
    cost_of(
        recipes::Recipes, 
        material::String, 
        amount::Int, 
        inventory::Inventory=Inventory()
    ) -> Int

Given the `recipes` that are available, a `material` to produce, an `amount`
of that material to be produced, and an `inventory` of surplus materials
already produced, calculate and return the total cost in "ORE" to produce
the requested amount of the requested material.
"""
function cost_of(
    recipes::Recipes,
    material::String,
    amount::Int,
    inventory::Inventory = Inventory(),
)
    # Base case, the amount of "ORE" needed for `amount` is `amount`
    material == "ORE" && return amount

    # Check in the inventory for any surplus amount of the material left
    # over from producing previous steps. Take as much as needed to reduce
    needed = amount - check_out!(inventory, material, amount)
    needed > 0 || return 0

    # Determine how many 'batches' of the recipe need to be made to
    # produce the required amount. Check any surplus into the inventory.
    serving, recipe = recipes[material]
    batches = ceil(Int, needed / serving)
    produced = serving * batches
    surplus = produced - needed
    check_in!(inventory, material, surplus)

    # The total cost is the sum of the cost to produce the required amount
    # of each individual ingredient.
    return sum(
        cost_of(recipes, ingredient, amount * batches, inventory) for
        (amount, ingredient) in recipe
    )
end

"Calculate and return the cost of one 'FUEL'"
part1(input) = cost_of(input, "FUEL", 1)
