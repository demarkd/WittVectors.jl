using AbstractAlgebra
function nextcoeff(f::SeriesElem{TT},Y::Vector{TT}, curseries::SeriesElem{TT}) where TT <: RingElement
		R=parent(f)
		#println("curseries=$(curseries)");println("f=$f");println("f reduced = $(f-curseries)")#debug
		n=length(Y)+1
		yn=coeff(f-curseries,n)
		newseries=curseries*inv((1-yn*gen(R)^n))
		#println("Y of type $(typeof(Y)), yn of type $(typeof(yn))")#debug
		return (vcat(vec(Y),vec([yn])), newseries)
end
function coordgen(f::SeriesElem{TT},Y::Vector{TT}, curseries::SeriesElem{TT},m::Int) where TT <: RingElement#iterator function for nextcoeff
	if (length(Y)>m) return error("coordgen called with more coordinates given than asked for")
	elseif (length(Y)==m) return Y
	else 
		(newY, newseries)=nextcoeff(f,Y,curseries)
		return coordgen(f, newY,newseries,m)
	end
end
function getcoords(f::SeriesElem{TT}) where TT<: RingElement #wrapper for coordgen which inputs a wittseries and outputs the witt coords to as high a precision as the given series. in general, this is the only one that should be called, since it is where f is checked to be an element of 1+TR[[T]] (otherwise we would have to check that *every* time we get another coordinate)
#	if coeff(f,0)!=(one(parent(f))) return error("getcoords called for f∉ 1+TR[[T]]") 
#	else
return coordgen(f,(elem_type(base_ring(parent(f))))[],(parent(f))(1),precision(f)-1)
#	end
end
