# Generated by `template.jl`
function ingest(path)
    output = []
    open(path) do f
        for line in eachline(f)
            push!(output, line)
        end
    end
    return output
end

abstract type AbstractElement end
struct Curium    <: AbstractElement end
struct Elerium   <: AbstractElement end
struct Dilithium <: AbstractElement end
struct Hydrogen  <: AbstractElement end
struct Lithium   <: AbstractElement end
struct Plutonium <: AbstractElement end
struct Ruthenium <: AbstractElement end
struct Strontium <: AbstractElement end
struct Thulium   <: AbstractElement end

struct Microchip{T <: AbstractElement} element::Type{T} end
struct Generator{T <: AbstractElement} element::Type{T} end

const Microchips = Set{Microchip}
const Generators = Set{Generator}
const Component  = Union{Microchip,Generator}
const Components = Set{Component}

struct Facility
    current::Int
    floors::Vector{Components}
end

Facility(floors::Vector{Components}) = Facility(1, floors)

Base.getindex(facility::Facility, i::Int)    = facility.floors[i]
current_floor((; current, floors)::Facility) = floors[current]


const TEST_START = Facility(
    [
        Components([Microchip(Hydrogen), Microchip(Lithium)]),
        Components([Generator(Hydrogen)]),
        Components([Generator(Lithium)]),
        Components(),
    ]
)

const TEST_GOAL = Facility(
    4,
    [
        Components(),
        Components(),
        Components(),
        Components([Microchip(Hydrogen), Microchip(Lithium),
                    Generator(Hydrogen), Generator(Lithium)])
    ]
)

const INPUT1_START = Facility(
    [
        Components([Microchip(Strontium), Microchip(Plutonium), 
                    Generator(Strontium), Generator(Plutonium)]),
        Components([Microchip(Ruthenium), Microchip(Curium), 
                    Generator(Ruthenium), Generator(Curium), 
                    Generator(Thulium)]),
        Components([Microchip(Thulium)]),
        Components(),
    ]
)

const INPUT1_GOAL = Facility(
    4,
    [
        Components(),
        Components(),
        Components(),
        Components([Microchip(Strontium), Generator(Strontium), 
                    Microchip(Plutonium), Generator(Plutonium),
                    Microchip(Ruthenium), Generator(Ruthenium), 
                    Microchip(Curium),    Generator(Curium), 
                    Microchip(Thulium),   Generator(Thulium)]),
    ]
)

const INPUT2_START = Facility(
    [
        Components([Microchip(Strontium), Generator(Strontium), 
                    Microchip(Elerium),   Generator(Elerium),
                    Microchip(Dilithium), Generator(Dilithium),
                    Microchip(Plutonium), Generator(Plutonium)]),
        Components([Microchip(Ruthenium), Microchip(Curium), 
                    Generator(Ruthenium), Generator(Curium), 
                    Generator(Thulium)]),
        Components([Microchip(Thulium)]),
        Components(),
    ]
)

const INPUT2_GOAL = Facility(
    4,
    [
        Components(),
        Components(),
        Components(),
        Components([Microchip(Strontium), Generator(Strontium), 
                    Microchip(Elerium),   Generator(Elerium),
                    Microchip(Dilithium), Generator(Dilithium),
                    Microchip(Plutonium), Generator(Plutonium),
                    Microchip(Ruthenium), Generator(Ruthenium), 
                    Microchip(Curium),    Generator(Curium), 
                    Microchip(Thulium),   Generator(Thulium)]),
    ]
)

Base.string(::Microchip{Curium   }) = "CM"
Base.string(::Microchip{Dilithium}) = "DM"
Base.string(::Microchip{Elerium  }) = "EM"
Base.string(::Microchip{Hydrogen }) = "HM"
Base.string(::Microchip{Lithium  }) = "LM"
Base.string(::Microchip{Plutonium}) = "PM"
Base.string(::Microchip{Ruthenium}) = "RM"
Base.string(::Microchip{Strontium}) = "SM"
Base.string(::Microchip{Thulium  }) = "TM"

Base.string(::Generator{Curium   }) = "CG"
Base.string(::Generator{Dilithium}) = "DG"
Base.string(::Generator{Elerium  }) = "EG"
Base.string(::Generator{Hydrogen }) = "HG"
Base.string(::Generator{Lithium  }) = "LG"
Base.string(::Generator{Plutonium}) = "PG"
Base.string(::Generator{Ruthenium}) = "RG"
Base.string(::Generator{Strontium}) = "SG"
Base.string(::Generator{Thulium  }) = "TG"