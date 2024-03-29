using XLSX

SHEET = 1
SEQUENCE_COLUMN = "Variants"
FITNESS_COLUMN = "Fitness"

"""
Uses a sequence-fitness dictionary to simulate the screening.

    DictScreening(fitness_dict::Dict{Vector{Char},Float64}; kwargs...)

Constructs `DictScreening` from a dictionary.

# Arguments
- `fitness_dict::Dict{Vector{Char},Float64}`: Dictionary mapping sequences to their fitness values.

# Keywords
- `default::Float64`: If present, the constructor returns `DictScreeningWithDefault` instead.

    DictScreening(file_path::String; kwargs...)

Constructs `DictScreening` from a '.xlsx' file.
    
# Arguments
- `file_path::String`: Defines path to a '.xlsx' file with the sequences and their fitness values.

# Keywords
- `sheet::Int`: The number of the excel sheet which will be loaded from the file. Default is 1.
- `sequence_column::String`: Label in the first row of the column containing the sequences. Default is "Variants".
- `fitness_column::String`: Label in the first row of the column containing the fitness values. Default is "Fitness".
- `default::Float64`: If present, the constructor returns `DictScreeningWithDefault` instead.
"""
struct DictScreening <: Screening
    fitness_dict::Dict{Vector{Char},Float64}
end

function DictScreening(file_path::String; sheet::Int=SHEET, sequence_column::String=SEQUENCE_COLUMN, fitness_column::String=FITNESS_COLUMN)
    DictScreening(load_dict(file_path; sheet, sequence_column, fitness_column))
end

function DictScreening(fitness_dict, default)
    DictScreeningWithDefault(fitness_dict, default)
end
function DictScreening(file_path::String, default::Float64; sheet::Int=SHEET, sequence_column::String=SEQUENCE_COLUMN, fitness_column::String=FITNESS_COLUMN)
    DictScreeningWithDefault(load_dict(file_path; sheet, sequence_column, fitness_column), default)
end

function load_dict(file_path::String; sheet::Int=SHEET, sequence_column::String=SEQUENCE_COLUMN, fitness_column::String=FITNESS_COLUMN)
    xf = XLSX.readxlsx(file_path)
    dt = XLSX.readtable(file_path, XLSX.sheetnames(xf)[sheet])

    variants_idx = dt.column_label_index[Symbol(sequence_column)]
    variants = Vector{String}(dt.data[variants_idx])
    variants = collect.(variants)

    fitness_idx = dt.column_label_index[Symbol(fitness_column)]
    fitness = Vector{Float64}(dt.data[fitness_idx])

    Dict(variants .=> fitness)
end

(s::DictScreening)(sequence::Vector{Char}) = s.fitness_dict[sequence]
(s::DictScreening)(sequences::AbstractVector{Vector{Char}}) = map(sequence -> s(sequence), sequences)

"""
Uses a sequence-fitness dictionary to simulate the screening.
Returns a default fitness value for sequences not present in the dictionary.

    DictScreeningWithDefault(fitness_dict::Dict{Vector{Char},Float64}, default::Float64)

# Arguments
- `fitness_dict::Dict{Vector{Char},Float64}`: Dictionary mapping sequences to their fitness values.
- `default::Float64`: Default fitness value returned for sequences not present in `fitness_dict`.

    DictScreening(fitness_dict::Dict{Vector{Char},Float64}; default::Float64)
    DictScreening(file_path::String; default::Float64, kwargs...)

Constructs `DictScreeningWithDefault` via `DictScreening` constructors by adding the `default` fitness value.

# Arguments
    See `DictScreening`.

# Keywords
    `default::Float64`: Default fitness value returned for sequences not present in `fitness_dict`.
    See `DictScreening`.
"""
struct DictScreeningWithDefault <: Screening
    fitness_dict::Dict{Vector{Char},Float64}
    default::Float64
end

(s::DictScreeningWithDefault)(sequence::Vector{Char}) = get(s.fitness_dict, sequence, s.default)
(s::DictScreeningWithDefault)(sequences::AbstractVector{Vector{Char}}) = map(sequence -> s(sequence), sequences)
