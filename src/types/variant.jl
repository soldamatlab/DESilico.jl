struct Variant
    sequence::AbstractVector{Char}
    fitness::Real

    Variant(sequence::AbstractVector{Char}, fitness::Real) = new(copy(sequence), fitness)
end

Base.copy(v::Variant) = Variant(v.sequence, v.fitness)

Base.hash(v::Variant, h::UInt) = hash(v.sequence, hash(:Variant, h))
Base.isequal(a::Variant, b::Variant) = Base.isequal(hash(a), hash(b))
