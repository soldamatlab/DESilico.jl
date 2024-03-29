using DESilico

# This example demonstrates how to define custom `SelectionStrategy`,
# `Mutagenesis` and `Screening` modules.

# We have a wild type sequence that we want to improve.
wild_type = Variant(['A', 'A', 'A', 'A'], 1.0)

# We define a custom screening oracle.
# A custom `Screening` structure should implement a method with signature
# `(::CustomScreening)(sequence::Vector{Char})`
# which returns fitness value of the input `sequence` as a subtype of `Real`.
fitness_dict = Dict([
    (['A', 'A', 'A', 'A'], 1.0),
    (['A', 'B', 'A', 'A'], 0.7),
    (['A', 'C', 'A', 'A'], 2.1),
    (['A', 'D', 'A', 'A'], 3.0),
    (['A', 'E', 'A', 'A'], 0.0),
])
struct DummyScreening <: DESilico.Screening end
(::DummyScreening)(sequence::Vector{Char}) = fitness_dict[sequence]
(s::DummyScreening)(sequences::AbstractVector{Vector{Char}}) = map(sequence -> s(sequence), sequences)

# We define a custom SelectionStrategy.
# A custom `SelectionStrategy` structure should implement a method with signature
# `(::CustomSelectionStrategy)(sequence_fitness_pairs::AbstractVector{Variant})`
# which returns a vector of the selected sequences as a subtype of `AbstractVector{Vector{Char}}`.
struct DummySelectionStrategy <: DESilico.SelectionStrategy end
function (::DummySelectionStrategy)(variants::Vector{Variant})
    [variants[1].sequence]
end

# We define a custom Mutagenesis.
# A custom `Mutagenesis` structure should implement a method with signature
# `(::CustomMutagenesis)(parents::AbstractVector{Vector{Char}})`
# which returns a vector of the created sequences as a subtype of `AbstractVector{Vector{Char}}`.
struct DummyMutagenesis <: DESilico.Mutagenesis end
function (::DummyMutagenesis)(parents::Vector{Vector{Char}})
    new_parent = copy(parents[1])
    new_parent[2] = new_parent[2] + 1
    return [new_parent]
end

# We need to initiate `SequenceSpace`
ss = SequenceSpace([wild_type])

# Finally, we run `n_iterations` of directed evolution with the custom modules.
de!(
    ss,
    screening=DummyScreening(),
    selection_strategy=DummySelectionStrategy(),
    mutagenesis=DummyMutagenesis(),
    n_iterations=length(fitness_dict) - 1,
)
println(ss.top_variant)
