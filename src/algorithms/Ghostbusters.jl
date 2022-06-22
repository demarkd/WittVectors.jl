#using AbstractAlgebra
function divideby_leastprimedivisior(n::Integer)
	if n <= 1 return n end
	found::Bool=false
	i::Int64=0
	while found==false
		i=nextprime(i+1)
		#println("i=$i, n%i = $(n%i)")
		if n%i==0
			found = true
		end
	end
	return n ÷ i
end
function factorby_leastprimedivisor(n::Integer)
	if n <= 1 return n end
	found::Bool=false
	i::Int64=0
	while found==false
		i=nextprime(i+1)
		#println("i=$i, n%i = $(n%i)")
		if n%i==0
			found = true
		end
	end
	return i, n ÷ i
end
function check_factorby(n::Integer)
	i,np=factorby_leastprimedivisor(n)
	return n==i*np
end
function pghost(X::Vector{TT},n::Integer)::TT where TT<:RingElement
	return sum(d*X[d]^(n÷d) for d in 1:n-1 if n%d ==0)
end
function ghost_exp(X::Vector{TT}, n::Integer)::TT where TT<: RingElement
	return sum(d*X[d]^(n÷d) for d in 1:n if n%d==0)
end
function ghostbuster(ω::Vector{TT})::Vector{TT} where TT <: RingElement
	#if division by integers is not possible, this will error
	n=length(ω)
	res = ω[1:1]
	R=parent(ω[1])
	for i in 2:n
		new=(ω[i] -pghost(res,i))÷R(i)
		push!(res,new)
	end
	return res
end
function ghostbuster(ω::Vector{TT},S::Vector{Bool})::Vector{TT} where TT <: RingElement
	#if division by integers is not possible, this will error
	n=length(ω)
	res = ω[1:1]
	R=parent(ω[1])
	for i in 2:n
		if S[i]
			new=(ω[i] -pghost(res,i))÷R(i)
			push!(res,new)
		else
			push!(res,R(0))
		end
	end
	return res
end
function ghost_vector(X::Vector{TT})::Vector{TT} where TT <: RingElement
	return [WittVectors.ghostpoly(X,n) for n in eachindex(X)]
end
function ghost_vector(X::Vector{TT},S::Vector{Bool})::Vector{TT} where TT <: RingElement
	return [S[n] ? WittVectors.ghostpoly(X,n) : 0 for n in eachindex(X)]
end
function ghostvec_add(X1::Vector{TT},X2::Vector{TT})::Vector{TT} where TT <: RingElement
	#W=parent(w1)
	#X1=w1.xcoords
	ω1=ghost_vector(X1)
	#X2=w2.xcoords
	ω2=ghost_vector(X2)
	ghostres=similar(X1)
	@inbounds Threads.@threads for i in eachindex(X1)
		ghostres[i]=ω1[i]+ω2[i]
	end
	return ghostbuster(ghostres)
end
function ghostvec_add(X1::Vector{TT},X2::Vector{TT},S::Vector{Bool})::Vector{TT} where TT <: RingElement
	#W=parent(w1)
	#X1=w1.xcoords
	ω1=ghost_vector(X1)
	#X2=w2.xcoords
	ω2=ghost_vector(X2)
	ghostres=similar(X1)
	@inbounds Threads.@threads for i in eachindex(X1)
		if S[i] ghostres[i]=ω1[i]+ω2[i] end
	end
	return ghostbuster(ghostres)
end
function ghostvec_mul(X1::Vector{TT},X2::Vector{TT})::Vector{TT} where TT <: RingElement
	#W=parent(w1)
	#X1=w1.xcoords
	ω1=ghost_vector(X1)
	#X2=w2.xcoords
	ω2=ghost_vector(X2)
	ghostres=similar(X1)
	@inbounds Threads.@threads for i in eachindex(X1)
		ghostres[i]=ω1[i]*ω2[i]
	end
	return ghostbuster(ghostres)
end
function ghostvec_mul(X1::Vector{TT},X2::Vector{TT},S::Vector{Bool})::Vector{TT} where TT <: RingElement
	#W=parent(w1)
	#X1=w1.xcoords
	ω1=ghost_vector(X1)
	#X2=w2.xcoords
	ω2=ghost_vector(X2)
	ghostres=similar(X1)
	@inbounds Threads.@threads for i in eachindex(X1)
		if S[i] ghostres[i]=ω1[i]*ω2[i] end
	end
	return ghostbuster(ghostres)
end
function ghostvec_pow(X::Vector{TT},n::Integer)::Vector{TT} where TT <: RingElement
	#W=parent(w1)
	#X1=w1.xcoords
	ω=ghost_vector(X)
	#X2=w2.xcoords
	#ω2=ghost_vector(X2)
	ghostres=similar(X)
	@inbounds Threads.@threads for i in eachindex(X)
		ghostres[i]=ω[i]^n
	end
	return ghostbuster(ghostres)
end
function ghostvec_pow(X::Vector{TT},n::Integer,S::Vector{Bool})::Vector{TT} where TT <: RingElement
	#W=parent(w1)
	#X1=w1.xcoords
	ω=ghost_vector(X)
	#X2=w2.xcoords
	#ω2=ghost_vector(X)
	ghostres=similar(X)
	@inbounds Threads.@threads for i in eachindex(X)
		if S[i] ghostres[i]=ω[i]^n end
	end
	return ghostbuster(ghostres,S)
end
function ghost_add(w1::WittVector{TT},w2::WittVector{TT})::WittVector{TT} where TT <: RingElement
	w3=deepcopy(w1)
	X1=w1.xcoords
	X2=w2.xcoords
	w3.xcoords=ghostvec_add(X1,X2)
	return w3
end
		
function ghost_add(w1::TruncatedWittVector{TT},w2::TruncatedWittVector{TT})::TruncatedWittVector{TT} where TT <: RingElement
	w3=deepcopy(w1)
	X1=w1.xcoords
	X2=w2.xcoords
	W=w1.parent
	S=W.truncationset
	w3.xcoords=ghostvec_add(X1,X2,S)
	return w3
end
	
function ghost_mul(w1::WittVector{TT},w2::WittVector{TT})::WittVector{TT} where TT <: RingElement
	w3=deepcopy(w1)
	X1=w1.xcoords
	X2=w2.xcoords
	w3.xcoords=ghostvec_mul(X1,X2)
	return w3
end
function ghost_mul(w1::TruncatedWittVector{TT},w2::TruncatedWittVector{TT})::TruncatedWittVector{TT} where TT <: RingElement
	w3=deepcopy(w1)
	X1=w1.xcoords
	X2=w2.xcoords
	W=w1.parent
	S=W.truncationset
	w3.xcoords=ghostvec_mul(X1,X2,S)
	return w3
end

function ghost_pow(w::WittVector{TT},n::Integer)::WittVector{TT} where TT <: RingElement
	w1=deepcopy(w)
	X=w.xcoords
	#X2=w2.xcoords
	w1.xcoords=ghostvec_pow(X,n)
	return w1
end
function ghost_pow(w::TruncatedWittVector{TT},n::Integer)::TruncatedWittVector{TT} where TT <: RingElement
	w1=deepcopy(w)
	X=w.xcoords
	#X2=w2.xcoords
	W=w.parent
	S=W.truncationset
	w1.xcoords=ghostvec_pow(X,n,S)
	return w1
end

