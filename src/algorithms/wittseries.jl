function seriesrep(w::WittVector)
	X=w.xcoords
	W=w.parent
	n=w.prec
	R=W.base_ring
	S,T = PowerSeriesRing(R,n+1,"T",model=:capped_absolute)
@inbounds	return prod(inv(1-X[i]*T^i) for i in eachindex(X))
end
function negseries(w::WittVector)
	X=w.xcoords
	W=w.parent
	n=w.prec
	R=W.base_ring
	S,T= PowerSeriesRing(R,n+1,"T",model=:capped_absolute)
@inbounds	return prod(1-X[i]*T^i for i in eachindex(X))
end
function intseries(c::Integer, W::BigWittRing)
	R=W.base_ring
	n=W.prec
	S,T= PowerSeriesRing(R,n+1,"T", model=:capped_absolute)
	if c>0
		return inv(1-T)^c
	elseif c<0
		return (1-T)^(-c)
	elseif c==0
		return S(1)
	end
end



	
