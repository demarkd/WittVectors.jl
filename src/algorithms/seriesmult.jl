using AbstractAlgebra
function multseries(X::Vector{TT},Y::Vector{TT}) where TT <: RingElement #type-stability is going to be a complete pain here, assume this is quite unstable until this comment is gone
	prec=min(length(X),length(Y))
	#=
	if isa(X,Vector{Int64})
		X=broadcast(BigInt,X)
	end
	if isa(Y,Vector{Int64})
		Y=broadcast(BigInt,Y)
	end#we might be able to remove this if type-stability is improved elsewhere. The problem is really that nothing should be called with Int64 arguments.
	=#
	baseX=parent(X[1])
	baseY=parent(Y[1])
	#println("Base ring of X=$X believed to be $baseX. Base ring of Y=$Y believed to be $baseY. Check bases (oh god) match: $(baseX==baseY)") #debug
	if baseX!=baseY return error("multseries called with apparent base ring mismatch")
	elseif prec==0 return error("multseries called with empty Witt vector")
	else
		R,T = PowerSeriesRing(baseX,prec+1,"T",model=:capped_absolute)
		#println("R=$R, X of type $(typeof(X)), Y of type $(typeof(Y)). If we have made it this far, the div error is definitely in the next line")#debug
		return prod( prod( prod( inv((1-prod(X[r] for xi ∈1:(lcm(r,s)÷r))*prod(Y[s] for yi ∈1:(lcm(r,s)÷s))*prod(R(T) for j ∈ 1:(lcm(r,s))))) for i ∈ 1:(gcd(r,s))) for r∈1:prec) for s ∈ 1:prec)#WOW I HATE IT! for some reason this appears to be necessary at least for the moment since otherwise the REPL throws up a methoderror TODO pretty this up
	end
end
function multseries(X::Vector{TT},Y::Vector{TT}, S::Vector{Bool}) where TT <: RingElement #type-stability is going to be a complete pain here, assume this is quite unstable until this comment is gone
	prec=min(length(X),length(Y))
	#=
	if isa(X,Vector{Int64})
		X=broadcast(BigInt,X)
	end
	if isa(Y,Vector{Int64})
		Y=broadcast(BigInt,Y)
	end#we might be able to remove this if type-stability is improved elsewhere. The problem is really that nothing should be called with Int64 arguments.
	=#
	baseX=parent(X[1])
	baseY=parent(Y[1])
	#println("Base ring of X=$X believed to be $baseX. Base ring of Y=$Y believed to be $baseY. Check bases (oh god) match: $(baseX==baseY)") #debug
	if baseX!=baseY return error("multseries called with apparent base ring mismatch")
	elseif prec==0 return error("multseries called with empty Witt vector")
	else
		R,T = PowerSeriesRing(baseX,prec+1,"T",model=:capped_absolute)
		#println("R=$R, X of type $(typeof(X)), Y of type $(typeof(Y)). If we have made it this far, the div error is definitely in the next line")#debug
		return prod( prod( prod( inv((1-prod(X[r] for xi ∈1:(lcm(r,s)÷r))*prod(Y[s] for yi ∈1:(lcm(r,s)÷s))*prod(R(T) for j ∈ 1:(lcm(r,s))))) for i ∈ 1:(gcd(r,s))) for r∈1:prec if S[r]) for s ∈ 1:prec if S[s])#WOW I HATE IT! for some reason this appears to be necessary at least for the moment since otherwise the REPL throws up a methoderror TODO pretty this up
	end
end
