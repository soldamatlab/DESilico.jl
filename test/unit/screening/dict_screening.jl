@testset "dict_screening.jl" begin
    file_path = joinpath(@__DIR__, "data/test_data.xlsx")
    fitness_dict = Dict(
        ['V', 'D', 'G', 'V'] => 1.0,
        ['A', 'D', 'G', 'V'] => 0.0619096557142,
        ['C', 'D', 'G', 'V'] => 0.242237277886,
        ['D', 'D', 'G', 'V'] => 0.00647208961971,
        ['E', 'D', 'G', 'V'] => 0.0327191845926,
        ['F', 'D', 'G', 'V'] => 0.377100728425,
        ['G', 'D', 'G', 'V'] => 0.00829790573568,
        ['H', 'D', 'G', 'V'] => 0.0264798489707,
        ['I', 'D', 'G', 'V'] => 1.4459050863,
    )
    default = 0.0
    missing_key = ['V', 'D', 'G', 'A']

    @testset "DictScreening" begin
        @testset "from Dict" begin
            ds = DESilico.DictScreening(fitness_dict)

            @test typeof(ds) == DESilico.DictScreening
            for key in keys(fitness_dict)
                @test ds(key) == fitness_dict[key]
            end
            @test_throws KeyError(missing_key) ds(missing_key)
        end

        @testset "from file" begin
            ds = DESilico.DictScreening(file_path)

            @test typeof(ds) == DESilico.DictScreening
            for key in keys(fitness_dict)
                @test ds(key) == fitness_dict[key]
            end
            @test_throws KeyError(missing_key) ds(missing_key)
        end
    end

    @testset "DictScreeningWithDefault" begin
        @testset "direct constructor" begin
            ds = DESilico.DictScreeningWithDefault(fitness_dict, default)

            @test typeof(ds) == DESilico.DictScreeningWithDefault
            for key in keys(fitness_dict)
                @test ds(key) == fitness_dict[key]
            end
            @test ds(missing_key) == default
        end

        @testset "from Dict" begin
            ds = DESilico.DictScreening(fitness_dict, default)

            @test typeof(ds) == DESilico.DictScreeningWithDefault
            for key in keys(fitness_dict)
                @test ds(key) == fitness_dict[key]
            end
            @test ds(missing_key) == default
        end

        @testset "from file" begin
            ds = DESilico.DictScreening(file_path, default)

            @test typeof(ds) == DESilico.DictScreeningWithDefault
            for key in keys(fitness_dict)
                @test ds(key) == fitness_dict[key]
            end
            @test ds(missing_key) == default
        end
    end
end
