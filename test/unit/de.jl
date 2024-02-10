@testset "de.jl" begin
    wt_sequence = ['A', 'A', 'A', 'A']

    # Define a custom screening oracle
    fitness_dict = Dict([
        (['A', 'A', 'A', 'A'], 1.0),
        (['A', 'B', 'A', 'A'], 0.7),
        (['A', 'C', 'A', 'A'], 2.1),
        (['A', 'D', 'A', 'A'], 3.0),
        (['A', 'E', 'A', 'A'], 0.0),
    ])
    struct DummyScreening <: DESilico.Screening end
    function (::DummyScreening)(sequence::Vector{Char})
        fitness_dict[sequence]
    end

    # Define a custom SelectionStrategy
    struct DummySelectionStrategy <: DESilico.SelectionStrategy end
    function (::DummySelectionStrategy)(variants::Vector{Variant})
        [variants[1].sequence]
    end

    # Define a custom Mutagenesis
    struct DummyMutagenesis <: DESilico.Mutagenesis end
    function (::DummyMutagenesis)(parents::Vector{Vector{Char}})
        new_parent = parents[1]
        new_parent[2] = new_parent[2] + 1
        return [new_parent]
    end

    # Run directed evolution of the wild type sequence
    top_variant = de(
        [wt_sequence],
        DummyScreening(),
        DummySelectionStrategy(),
        DummyMutagenesis(),
        n_iterations=length(fitness_dict) - 1,
    )

    @test typeof(top_variant) == Variant
    @test top_variant.sequence == ['A', 'D', 'A', 'A']
    @test top_variant.fitness == 3.0
end
