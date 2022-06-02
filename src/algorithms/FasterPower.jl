function fasterpower(w::WittVector{T}, n::Int64) where T <: RingElement
	W=parent(w)
	if n<0 return error("negative powers of Witt vectors not implemented")
	elseif n==0 return W(1)
	elseif n==1 return w
	elseif n==2 return w*w
	elseif n==3 return w*w*w
	else
		digs=digits(n, base=2)
		#println("digs=$(digs)")#DEBUG
		dlog=length(digs)
		#println("dlog=$dlog")#DEBUG
		sqdict=Dict{Int64, WittVector{T}}([(1,w)])
		diglist=[i for i in 1:dlog if digs[i]==1]
		#println("diglist=$diglist")#DEBUG
		for i in 2:dlog
			sqdict[i]=sqdict[i-1]*sqdict[i-1]
			#println("w^$(2^i)=$(sqdict[i])")
		end
		#println("dictionary of powers from 1 to $dlog: $([sqdict[i] for i in 1:dlog])")
		#println("multiplying following elements: $([sqdict[i] for i in diglist])")
		return prod(sqdict[j] for j in diglist)
	end
end
fasterpower(w::WittVector{T}, n::Integer) where T <: RingElement = fasterpower(w, Int64(n))
