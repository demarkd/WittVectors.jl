function ghost_vector(X::Vector{T}) where T <: RingElement
	return [ghostmap(X,i) for i in length(X)]
