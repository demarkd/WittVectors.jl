function verschiebung(n::Integer, w::WittVector{TT}) where TT <: RingElement
	W=w.parent
	y=W(0)
	Y=y.xcoords
	X=w.xcoords
	#k=length(w.xcoords)
	Threads.@threads for m in eachindex(Y)
		if m % n ==0
			Y[m]=X[m ÷ n]
		end
	end
	return y
end
function verschiebung(n::Integer, w::TruncatedWittVector{TT}) where TT <: RingElement
	W=w.parent
	S=W.truncationset
	if !(S[n])
		return W(0)
	else
		X=w.xcoords
		y=W(0)
		Y=y.xcoords
		Threads.@threads for m in eachindex(Y)
			if m % n == 0
				Y[m] = X[m÷n]
			end
		end
		return y
	end
end
