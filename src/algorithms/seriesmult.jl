#using AbstractAlgebra
function multseries(X::Vector{TT},Y::Vector{TT})::AbsSeriesElem{TT} where TT <: RingElement
	prec=min(length(X),length(Y))
	baseX=parent(X[1])
	baseY=parent(Y[1])
	R,T = PowerSeriesRing(baseX,prec+1,"T",model=:capped_absolute)
		@inbounds k=inv(1-(X[1])*(Y[1])*T)*prod(prod(inv((1-(X[r])^(s÷gcd(r,s))*(Y[s])^(r÷gcd(r,s))*T^(lcm(r,s)))*(1-(Y[r])^(s÷gcd(r,s))*(X[s])^(r÷gcd(r,s))*T^(lcm(r,s))))^(gcd(r,s)) for r in 1:s-1)*inv(1-(X[s])*(Y[s])*T^s)^s for s in 2:prec)
	return k
end
#=
function sPart(X::Vector{TT}, Y::Vector{TT}, s::Int64, prec::Int64) where TT <: RingElement
    R,T = PowerSeriesRing(baseX,prec+1,"T",model=:capped_absolute)

    return prod(inv((1-(X[r])^(s÷gcd(r,s))*(Y[s])^(r÷gcd(r,s))*T^(lcm(r,s)))(1-(Y[r])^(s÷gcd(r,s))*(X[s])^(r÷gcd(r,s))*T^(lcm(r,s))))^(gcd(r,s)) for r in 1:s-1)*inv(1-(X[s])*(Y[s])*T^s)^s 
end
=#
function multseries(X::Vector{TT},Y::Vector{TT}, S::Vector{Bool})::AbsSeriesElem{TT} where TT <: RingElement
	prec=min(length(X),length(Y))
	baseX=parent(X[1])
	baseY=parent(Y[1])
		R,T = PowerSeriesRing(baseX,prec+1,"T",model=:capped_absolute)
		@inbounds k=inv(1-(X[1])*(Y[1])*T)*prod(prod(inv((1-(X[r])^(s÷gcd(r,s))*(Y[s])^(r÷gcd(r,s))*T^(lcm(r,s)))*(1-(Y[r])^(s÷gcd(r,s))*(X[s])^(r÷gcd(r,s))*T^(lcm(r,s))))^(gcd(r,s)) for r in 1:s-1 if S[r])*inv(1-(X[s])*(Y[s])*T^s)^s for s in 2:prec if S[s])
	return k
end
function series_inv(x::WittVector{TT})::WittVector{TT} where TT <: RingElement
	m=length(x.xcoords)
	W=parent(x)
	y=W(0)
	X=x.xcoords
	Y=y.xcoords
	Y[1]=inv(X[1])
	f=multseries(X,Y)
	R,T=parent(f), gen(parent(f))
	for i in 2:m
		u=coeff(f,i)
		new=divexact((1-u),ghostpoly(X,i))
		Y[i]=new
		@inbounds f*=inv(prod( (1-X[j]^(lcm(i,j)÷j)*Y[i]^(lcm(i,j)÷i)*T^(lcm(i,j)))^(gcd(i,j))
				      for j in 1:m))
	end
	return W(Y)
end
function lift_to_big_unit(w::TruncatedWittVector{TT})::Vector{TT} where TT <: RingElement
	#will not produce a Big unit if w is not a unit with respect to its truncation set
	#slightly misnamed, produces a big unit's coordinate vector, not the Witt vector itself. 
	#output agrees with `w` on the truncation set
	X=deepcopy(w.xcoords)
	W=parent(w)
	R=base_ring(W)
	S=W.truncationset
	n=length(X)
	for i in 2:n
		if !(S[i])
			ωi=WittVectors.ghostpoly(X,i)
			if !(is_unit(ωi))
				X[i]+=R(1)-ωi
			end
		end
	end
	return X
end
"""
	function find_unit(w::TruncatedWittVector{TT})::TruncatedWittVector{TT} where TT<: RingElement
	function find_unit(w::WittVector{TT})::WittVector{TT} where TT <: RingElement
Returns a Witt Vector which is modified from a copy of `w` to be a unit by examination of ghost coordinates. 

This is still prototypical. 
oh uh and definitely doesn't work for every ring.... 

"""
function find_unit(w::TruncatedWittVector{TT})::TruncatedWittVector{TT} where TT <: RingElement
	X=deepcopy(w.xcoords)
	W=parent(w)
	R=base_ring(W)
	S=W.truncationset
	n=length(X)
	for i in 1:n
		if (S[i])
			ωi=WittVectors.ghostpoly(X,i)
			if !(is_unit(ωi))
				X[i]+=R(1)-ωi

				println("$(ghostpoly(X,i))")

			end
		end
	end
	return W(X)
end
function find_unit(w::WittVector{TT})::WittVector{TT} where TT <: RingElement
	X=deepcopy(w.xcoords)
	W=parent(w)
	R=base_ring(W)
	n=length(X)
	for i in 2:n
		ωi=WittVectors.ghostpoly(X,i)
		if !(is_unit(ωi))
			X[i]+=R(1)-ωi
		end
	end
	return W(X)
end

#export find_unit

function series_inv(x::TruncatedWittVector{TT})::TruncatedWittVector{TT} where TT <: RingElement
	m=length(x.xcoords)
	W=parent(x)
	y=W(0)
	S=W.truncationset
	X=lift_to_big_unit(x)
	Y=y.xcoords
	Y[1]=inv(X[1])
	f=multseries(X,Y)
	R,T=parent(f), gen(parent(f))
	for i in 2:m
		u=coeff(f,i)
		new=divexact((1-u),ghostpoly(X,i))
		Y[i]=new
		@inbounds f*=inv(prod( (1-X[j]^(lcm(i,j)÷j)*Y[i]^(lcm(i,j)÷i)*T^(lcm(i,j)))^(gcd(i,j))
				      for j in 1:m))
	end
	return W(Y)
end
