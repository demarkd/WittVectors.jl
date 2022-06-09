#using AbstractAlgebra
function multseries(X::Vector{TT},Y::Vector{TT})::AbsSeriesElem{TT} where TT <: RingElement
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
#		return prod( prod( prod( inv((1-prod(X[r] for xi ∈1:(lcm(r,s)÷r))*prod(Y[s] for yi ∈1:(lcm(r,s)÷s))*prod(R(T) for j ∈ 1:(lcm(r,s))))) for i ∈ 1:(gcd(r,s))) for r∈1:prec) for s ∈ 1:prec)#WOW I HATE IT! for some reason this appears to be necessary at least for the moment since otherwise the REPL throws up a methoderror TODO pretty this up
		@inbounds k=inv(1-(X[1])*(Y[1])*T)*prod(prod(inv((1-(X[r])^(s÷gcd(r,s))*(Y[s])^(r÷gcd(r,s))*T^(lcm(r,s)))*(1-(Y[r])^(s÷gcd(r,s))*(X[s])^(r÷gcd(r,s))*T^(lcm(r,s))))^(gcd(r,s)) for r in 1:s-1)*inv(1-(X[s])*(Y[s])*T^s)^s for s in 2:prec)
	end
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
	if baseX!=baseY return error("multseries called with apparent base ring mismatch")
	elseif prec==0 return error("multseries called with empty Witt vector")
	else
		R,T = PowerSeriesRing(baseX,prec+1,"T",model=:capped_absolute)
		@inbounds return inv(1-(X[1])*(Y[1])*T)*prod(prod(inv((1-(X[r])^(s÷gcd(r,s))*(Y[s])^(r÷gcd(r,s))*T^(lcm(r,s)))*(1-(Y[r])^(s÷gcd(r,s))*(X[s])^(r÷gcd(r,s))*T^(lcm(r,s))))^(gcd(r,s)) for r in 1:s-1 if S[r])*inv(1-(X[s])*(Y[s])*T^s)^s for s in 2:prec if S[s])
		
	end
end
