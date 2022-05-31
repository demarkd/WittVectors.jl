using AbstractAlgebra
function nextcoeff(f::SeriesElem,Y)#issues: as it stands, this is not a pure function because it uses append!
	if (length(Y)==0) 
		return [coeff(f,1)]#this is an ad-hoc solution to avoiding a type-stability issue--this case would not be necessary except that if nextcoeff is called with Y==[], the return is of type Vector{any}; this automatically sets the return to Vector{RingElem{base_ring(Parent(f))}}  
	elseif (length(Y)==precision(f)-1)
		println("nextcoeff called with as many coordinates found as allowable by precision of its argument")
		return Y
	elseif (length(Y)>precision(f)-1)
		return error("nextcoeff called with more coordinates claimed found than possible")
	else
		R=parent(f)
		yseries=(length(Y)==0) ? one(R) : prod(  inv(1-Y[i]*gen(R)^i) for i ∈ eachindex(Y))
		#println("yseries=$(yseries)");println("f=$f");println("f reduced = $(f-yseries)")#debug
		yn=coeff(f-yseries,length(Y)+1)
		#println("Y of type $(typeof(Y)), yn of type $(typeof(yn))")#debug
		return vcat(vec(Y),vec([yn]))
	end
end
function coordgen(f::SeriesElem,Y,m::Int)#iterator function for nextcoeff
	if (length(Y)>m) return error("coordgen called with more coordinates given than asked for")
	elseif (length(Y)==m) return Y
	else return coordgen(f, nextcoeff(f,Y),m)
	end
end
function getcoords(f::SeriesElem) #wrapper for coordgen which inputs a wittseries and outputs the witt coords to as high a precision as the given series. in general, this is the only one that should be called, since it is where f is checked to be an element of 1+TR[[T]] (otherwise we would have to check that *every* time we get another coordinate)
	if coeff(f,0)!=(one(parent(f))) return error("getcoords called for f∉ 1+TR[[T]]") 
	else return coordgen(f,[],precision(f)-1)
	end
end
