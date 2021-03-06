#=
using AbstractAlgebra
function nextcoeff(f::SeriesElem{TT},Y::Vector{TT}) where TT <: RingElement
		R=parent(f)
		T=gen(R)
		#println("curseries=$(curseries)");
		#println("f=$f")#;println("f reduced = $(f-curseries)")#debug
		n=length(Y)+1
		yn=coeff(f, n)
		f*=(1-yn*T^n)
		#println("newseries=$newseries")
		#println("Y of type $(typeof(Y)), yn of type $(typeof(yn))")#debug
		return (f, push!(Y,yn))
end
function coordgen(curseries::SeriesElem{TT}, Y::Vector{TT}, m::Int) where TT <: RingElement#iterator function for nextcoeff
	if (length(Y)>m) return error("coordgen called with more coordinates given than asked for")
	elseif (length(Y)==m) return Y
	else 
		(newseries,newY)=nextcoeff(curseries,Y)
		return coordgen(newseries, newY, m)
	end
end
function getcoords1(f::SeriesElem{TT}) where TT<: RingElement #wrapper for coordgen which inputs a wittseries and outputs the witt coords to as high a precision as the given series. in general, this is the only one that should be called, since it is where f is checked to be an element of 1+TR[[T]] (otherwise we would have to check that *every* time we get another coordinate)
#	if coeff(f,0)!=(one(parent(f))) return error("getcoords called for f∉ 1+TR[[T]]") 
#	else
return coordgen(f,(elem_type(base_ring(parent(f))))[],precision(f)-1)
#	end
end
=#
function getcoords(f::SeriesElem{TT})::Vector{TT} where TT <: RingElement
	R=parent(f)
	T=gen(R)
	m=precision(f)-1
	Y=(elem_type(base_ring(R)))[]
	for n in 1:m
		yn=coeff(f,n)
		f*=(1-yn*T^n)
		push!(Y,yn)
	end
	return Y
end
