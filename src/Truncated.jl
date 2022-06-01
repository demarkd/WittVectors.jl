#using AbstractAlgebra
#using BigWitt2
"""
	mutable struct TruncatedBigWittRing{T <: RingElement} <: Ring
Parent object for truncated rings of Witt vectors. Contains two fields, `untruncated::BigWittRing{T}` which is the underlying ring (prior to quotient) and `truncationset::Vector{Bool}` which determines which indices are kept in the truncation. `truncationset` should be the same length as `untruncated.prec`.
## Constructors
	function (W::TruncatedBigWittRing{T})() where T <: RingElement
	function (W::TruncatedBigWittRing{T})(c::Integer) where T <: RingElement
	function (W::TruncatedBigWittRing{T})(c::T) where T <: Integer
	function (W::TruncatedBigWittRing{T})(c::T) where T <: RingElement
Each of these mirror the functionality in the untruncated case.

    function (W::TruncatedBigWittRing{T})(A::Vector{T}) where T <: RingElem
Return a Witt vector with coordinates specified by `A`. `A` can be the length of `W.truncationset` (i.e. `W.untruncated.prec` in which case it will ignore the entries of `A` ignored by `W` or it can be length equal to the number of `true` entries in `W.truncationset`, in which case it will fill in the missing (irrelevant) entries with zero. 
## Example
```jldoctest
julia> using AbstractAlgebra, WittVectors;

julia> W=pTypicalWittVectorRing(GF(3),2,3)
Witt vector ring over Finite field F_3 truncated over the set [1, 2, 4, 8]

julia> w=W([2,1,0,2])
AbstractAlgebra.GFElem{Int64}[2, 1, 0, 2] truncated over [1, 2, 4, 8]

julia> w1=W([2,1,1,0,1,1,1,2])
AbstractAlgebra.GFElem{Int64}[2, 1, 0, 2] truncated over [1, 2, 4, 8]

julia> w==w1
true

julia> w1.xcoords #note the bogus entries are killed
8-element Vector{AbstractAlgebra.GFElem{Int64}}:
 2
 1
 0
 0
 0
 0
 0
 2
```
"""
mutable struct TruncatedBigWittRing{T <: RingElement} <: Ring
	untruncated::BigWittRing{T}
	truncationset::Vector{Bool}

	function TruncatedBigWittRing{T}(W::BigWittRing, truncationset::Vector{Bool}, cached::Bool) where T<: RingElement
		if length(truncationset)>W.prec return error("too large a truncation set!") end
		return get_cached!(TruncatedWittID, (W, truncationset), cached) do
			new{T}(W,truncationset)
		end::TruncatedBigWittRing{T}
	end
end

const TruncatedWittID=AbstractAlgebra.CacheDictType{Tuple{BigWittRing,Vector{Bool}},Ring}()
"""
	mutable struct TruncatedWittVector{T <: RingElement} <: RingElem
Child type for truncated Witt vectors. Contains three fields, `xcoords::Vector{T}` which are its coordinates (INCLUDING indices not in the truncation set), `truncationset::Vector{Bool}` and `parent::TruncatedBigWittRing{T}`. `truncationset` and `parent.truncationset` should match.
"""
mutable struct TruncatedWittVector{T <: RingElement} <: RingElem
	xcoords:: Vector{T}
	truncationset::Vector{Bool}
	parent:: TruncatedBigWittRing{T}

	function TruncatedWittVector{T}(xcoords::Vector{T}, truncationset::Vector{Bool}) where T <: RingElement
		return new(xcoords,truncationset)
	end
end
#####################################
#Data type and parent object methods#
#####################################

parent_type(::Type{TruncatedWittVector{T}}) where T <: RingElement = TruncatedBigWittRing{T}

elem_type(::Type{TruncatedBigWittRing{T}}) where T <: RingElement = TruncatedWittVector{T}

base_ring(W::TruncatedBigWittRing)=(W.untruncated).base_ring

parent(w::TruncatedWittVector)=w.parent

is_domain_type(::Type{TruncatedWittVector{T}}) where T <: RingElement = false#TODO figure out whether this is true (think not)
is_exact_type(::Type{TruncatedWittVector{T}}) where T <: RingElement = is_exact_type(T)

function hash(w::TruncatedWittVector, h::UInt)
	r = 0x65125ab8e0cd45ca
	X= w.xcoords
	s=UInt(1)
	for i in eachindex(X)
		s=xor(s,hash(X[i],h))
	end
	return xor(r,s)
end

function deepcopy_internal(w::TruncatedWittVector{T},d::IdDict) where T <: RingElement
	m=((w.parent).untruncated).prec
	coords=Array{T}(undef,m)
	X=w.xcoords
	for i = 1:m
		coords[i]=deepcopy_internal(X[i],d)
	end
	#mnew=deepcopy_internal(m,d)
	Snew=deepcopy_internal(w.truncationset,d)
	r=TruncatedWittVector{T}(vec(coords),Snew)
	r.parent=w.parent
	return r
end
####################
#Basic Manipulation#
####################
function zero(W::TruncatedBigWittRing)
	r=deepcopy(W())
	r.parent=W
	return r
end

function one(W::TruncatedBigWittRing)
	R=(W.untruncated).base_ring
	n=(W.untruncated).prec
	r=deepcopy(zero(W))
	r.xcoords=vcat(vec([one(R)]), zeros(R,n-1))
	return r
end

function iszero(w::TruncatedWittVector)
	X=w.xcoords
	#n=length(X)
	return prod(iszero(X[i]) for i in eachindex(X))
end
function isconstant(w::TruncatedWittVector)
	X=w.xcoords
	n=length(X)
	return prod(iszero(X[i]) for i in 2:n)
end
function isone(w::TruncatedWittVector)
	X=w.xcoords
	n=length(X)
	return isone(X[1])*isconstant(w)
end
function is_unit(w::TruncatedWittVector)
	println("WARNING: checking if a [truncated] Witt Vector is a unit, but I don't actually know how to implement it--this will return false negatives for units other than [1]")
	return isone(w)
end

################
#Canonical Unit#
################

canonical_unit(w::TruncatedWittVector)=one(w.parent)
####################
#Truncation Helpers#
####################
"""
    function truncationbools(X::Vector{Int},n::Int)
Return vector of booleans corresponding to a truncationset given as a `Vector`, `Array` or `Matrix` of integers. Unexpected results may occur if supplied a matrix with both dimensions exceeding 1. The second argument `n` specifies the length of the returned vector. `n` should exceed the largest member of `X`, will throw an index error otherwise. 
"""
function truncationbools(X::Vector{Int},n::Int)
	Y=zeros(Bool,n)
	for i in eachindex(X)
		Y[X[i]]=true
	end
	return Y
end
function truncationbools(X::Array{Int},n::Integer)
	return truncationbools(vec(X),n)
end
function truncationbools(X::Matrix{Int}, n::Integer)
	return truncationbools(vec(X),n)
end
function largestmember(X::Vector{Int})
	m=0
	for i in eachindex(X)
		if X[i]>m
			m=X[i]
		end
	end
	return m
end
"""
    function truncationbools(X)
Alias for `trunationbools(X,n)` where `n` is the maximal member of `X`.
"""
function truncationbools(X)
	return truncationbools(X,largestmember(X))
end
"""
	function truncationlist(S::Vector{Bool})
Return a list of integers representing the truncationset given its representation as a boolean vector.
"""
function truncationlist(S::Vector{Bool})
	return [k for k in eachindex(S) if S[k]]
end
#highly naive implementation, can be improved (some work to that end below)
"""
	function divisor_stabilize(S::Vector{Bool})
Return a divisor-stable truncationset (as a `Vector{Bool}`) generated by its argument. For now a very slow and naive implementation, but hardly performance-critical.
### Example
```jldoctest
julia> using WittVectors;

julia> using AbstractAlgebra;

julia> S=zeros(Bool, 36);

julia> S[36]=true
true

julia> S
36-element Vector{Bool}:
 0
 0
 0
 0
 0
 0
 0
 0
 0
 0
 ⋮
 0
 0
 0
 0
 0
 0
 0
 0
 1

julia> divisor_stabilize(S)
36-element Vector{Bool}:
 1
 1
 1
 1
 0
 1
 0
 0
 1
 0
 ⋮
 0
 0
 0
 0
 0
 0
 0
 0
 1

```
"""
function divisor_stabilize(S::Vector{Bool})
	X=deepcopy(S)
	for i in truncationlist(S)
		for j in 1:i
		#	println("looking at i=$i, j=$j. X[j]=$(X[j])")
			i%j==0 && (X[j]=true)
		#	println("now X[j]=$(X[j])")
		end
	end
	return X
end

#= Missing for now: 
function divisors(n)::Vector{Bool}
end
function divisor_stabilize(S::Vector{Bool})
	X=deepcopy(S)
	for i in truncationlist(S)
		divs=divisors(i)
		for j in eachindex divs
			X[j] = divs[j] || S[j]
		end
	end
	return X
end
=#
function truncatedcoords(w::TruncatedWittVector)
	S=(w.parent).truncationset
	X=w.xcoords
	return [X[i] for i in eachindex(S) if S[i]]
end 

function truncate!(w::TruncatedWittVector)
	R=base_ring(w.parent)
	S=broadcast(R,(w.parent).truncationset)
	X=deepcopy(w.xcoords)
	w.xcoords= X .* S
	return w
end

############
#String I/O#
############

function show(io::IO,W::TruncatedBigWittRing)
	print(io, "Witt vector ring over ")
	show(io, base_ring(W))
	print(io, " truncated over the set $(truncationlist(W.truncationset))")
	((W.untruncated).prec != largestmember(truncationlist(W.truncationset))) && print(io, ". Warning: underlying precision of $(W.untruncated.prec) greater than largest member $(largestmember(truncationlist(W.truncationset))) of truncation set")
end
function show(io::IO, w::TruncatedWittVector)
	print(io,truncatedcoords(w))
	print(io," truncated over $(truncationlist((w.parent).truncationset))")
end

##################
#Expressification#
##################

function expressify(W::TruncatedBigWittRing; context=nothing)
	return Expr(:sequence, Expr(:text, "Big Witt vectors over "), expressify(base_ring(W),context=context), Expr(:text, " truncated by truncation set"), expressify((truncationlist(W.truncationset)),context=context))
end

function expressify(w:: TruncatedWittVector; context=nothing)
	txcoords=truncatedcoords(w)
	tlist=truncationlist((w.parent).truncationset)
	return Expr(:sequence, expressify(txcoords, context=context), Expr(:text, " over truncation set "), expressify(tlist, context=context))
end

##################
#Unary Operations#
##################
include("algorithms/truncseries.jl")
function -(w::TruncatedWittVector)
	negw=deepcopy(w)
	negw.xcoords=getcoords(negseries(w))
	return truncate!(negw)
end

###################
#Binary Operations#
###################

function +(w::TruncatedWittVector{T}, v::TruncatedWittVector{T}) where T <: RingElement
	parent(w) != parent(v) && error("Incompatible Rings--possibly because of different native precision for underlying Witt rings")
	addnseries=seriesrep(w)*seriesrep(v)
	sumvec=deepcopy(w)
	sumvec.xcoords=getcoords(addnseries)
	return truncate!(sumvec)
end

function *(w::TruncatedWittVector{T}, v::TruncatedWittVector{T}) where T <: RingElement
	parent(w) != parent(v) && error("Incompatible Rings--possibly because of differing native precision for underlying Witt rings")
	S=parent(w).truncationset
	multnseries = multseries(w.xcoords, v.xcoords, S)
	prodvec=deepcopy(w)
	prodvec.xcoords=getcoords(multnseries)
	return truncate!(prodvec)
end
function -(w::TruncatedWittVector{T}, v::TruncatedWittVector{T}) where T <: RingElement
	parent(w) != parent(v) && error("Incompatible Rings--possibly because of differing native precision for underlying Witt rings")
	subnseries=divexact(seriesrep(w),seriesrep(v))
	r=deepcopy(w)
	r.xcoords=getcoords(subnseries)
	return truncate!(r)
end

#####################
#Z-Algebra structure#
#####################

function *(w::TruncatedWittVector{T}, c:: Integer) where T <: RingElement
	r=deepcopy(w)
	if c>= 0
		r.xcoords=getcoords(seriesrep(w)^c)
	elseif c< 0
		r.xcoords=getcoords(inv(seriesrep(w))^c)
	end
	return truncate!(r)
end
function *(c::Integer, w::TruncatedWittVector{T}) where T <: RingElement
end

#############
#Comparisons#
#############
"""
	function ==(w::TruncatedWittVector{T}, v::TruncatedWittVector{T}) where T<: RingElement
Return true if and only if `w` and `v` have the same parent and `w[i]==v[i]` for `i ∈ w.truncationset` (equivelently `i ∈ v.truncationset`). In general any `TruncatedWittVector` constructed normally will have zeros for those entries anyway, but in the event this property is somehow broken, that will be invisible to `==`.
"""
function ==(w::TruncatedWittVector{T}, v::TruncatedWittVector{T}) where T<: RingElement
	parent(w) != parent(v) && error("Incompatible Rings")
	X=v.xcoords
	Y=w.xcoords
	S=parent(w).truncationset
	return prod(X[i]==Y[i] for i in eachindex(X) if S[i])
end
function isequal(w::TruncatedWittVector{T},v::TruncatedWittVector{T}) where T<: RingElement
	parent(w) != parent(v) && error("Incompatible Rings")
	X=v.xcoords
	Y=w.xcoords
	S=parent(w).truncationset
	return prod(isequal(X[i],Y[i]) for i in eachindex(X) if S[i])
end
################
#Exact Division#
################
#Ah, no idea how to handle this. We NEED a good way to tell when w is a unit. Leaving blank for now.
function divexact(w::TruncatedWittVector{T}, v::TruncatedWittVector{T}; check::Bool=true) where T <: RingElement
	parent(w) != parent(v) && error("Incompatible rings")
	iszero(v) && error("Witt vector division by zero (fix: should be a division error") 
	if v==one(parent(v)) return w
	else
		return error("Witt vector division only implemented for denominator==1")
	end
end
function inv(w::TruncatedWittVector)
	W=parent(w)
	if w==one(W) return one(w)
	else
		return error("Witt vector inversion only implemented for denominator==1")
	end
end

#########
#Inverse#
#########
#same problem

##################
#Unsafe Operators#
##################

function zero!(w::TruncatedWittVector)
	w=zero(parent(w))
	return w
end
function mul!(u::TruncatedWittVector{T}, w::TruncatedWittVector{T}, v::TruncatedWittVector{T}) where T <: RingElement
	#parent(w) != parent(v) && error("Incompatible Rings")
	#parent(u) != parent(w) && error("Incompatible Rings")
	u.xcoords=getcoords(multseries(w.xcoords,v.xcoords))
	return truncate!(u)
end
function add!(u:: TruncatedWittVector{T}, w::TruncatedWittVector{T}, v::TruncatedWittVector{T}) where T<: RingElement
	#parent(w) != parent(v) && error("Incompatible Rings")
	#parent(u) != parent(w) && error("Incompatible Rings")
	u.xcoords=getcoords(seriesrep(w)*seriesrep(v))
	return truncate!(u)
end

function addeq!(w::TruncatedWittVector{T}, v::TruncatedWittVector{T}) where T <: RingElement
	w.xcoords=getcoords(seriesrep(w)*seriesrep(v))
	return truncate!(w)
end

###################
#Random Generation#
###################

#hooooooooo ok also #TODO
#I suppose one option would be using the existing implementation for series rings--namely <random witt vector> = getcoords . 1+x<random series>
#
function RandomExtensions.make(W::TruncatedBigWittRing, deg_range::UnitRange{Int}, vs...)
   R = base_ring(W)
   if length(vs) == 1 && elem_type(R) == Random.gentype(vs[1])
      Make(W, deg_range, vs[1]) # forward to default Make constructor
   else
      make(W, deg_range, make(R, vs...))
   end
end

RandomExtensions.maketype(W::TruncatedBigWittRing, _) = elem_type(W)

# define rand for make(S, deg_range, v)
#function rand(rng::AbstractRNG, sp::SamplerTrivial{<:Make3{<:RingElement,<:BigWittRing,UnitRange{Int}}})
function rand(rng::AbstractRNG, sp::SamplerTrivial{<:Make2{<:RingElement,<:TruncatedBigWittRing}})
   W, v = sp[][1:end]
   R = base_ring(W)
   w = deepcopy(W())
   #x = gen(S)
   # degree -1 is zero polynomial
   Sl=truncationlist((w.parent).truncationset)
   for i in Sl
      w.xcoords[i] = rand(rng, v)
   end
   # ensure leading coefficient is nonzero
  #= c = R()
   while iszero(c)
      c = rand(rng, v)
   end
   f += c*x^deg
   return f=#
   return w
end

#################
#Promotion Rules#
#################

promote_rule(::Type{TruncatedWittVector{T}}, ::Type{TruncatedWittVector{T}}) where T <: RingElement = TruncatedWittVector{T}

function promote_rule(::Type{TruncatedWittVector{T}}, ::Type{U}) where {T <: RingElement, U <: RingElement}
	#YIKES do I have no idea what is going on here. For now copying the minimal ring interface code.
	promote_rule(T, U) == T ? TruncatedWittVector{T} : Union{}
end

##############
#Constructors#
#############

function (W::TruncatedBigWittRing{T})() where T <: RingElement
	R=base_ring(W)
	S=W.truncationset
	n=(W.untruncated).prec
	r=TruncatedWittVector{T}(zeros(R,n),S)
	r.parent=W
	return r
end
#need to change this if I change corresponding behavior for normal Witt vectors
function (W::TruncatedBigWittRing{T})(c::Integer) where T <: RingElement
	r=deepcopy(zero(W))
	R=base_ring(W)
	r.xcoords[1]= R(c) #getcoords(intseries(c,W))
	return truncate!(r)
end

#possibly needed to prevent ambiguity
function (W::TruncatedBigWittRing{T})(c::T) where T <: Integer
	r=deepcopy(zero(W))
	R=base_ring(W)
	r.xcoords[1]= R(c) # =getcoords(intseries(c,W))
	return truncate!(r)
end
function (W::TruncatedBigWittRing{T})(c::T) where T <: RingElement
	base_ring(W) != parent(c) && error("Unable to coerce element")
	r=deepcopy(zero(W))
	r.xcoords[1]=c
	return r
end
#TODO (1) double check this makes sense (2) make sure this is compatible with the testing interace
#=
function (W::BigWittRing{T})(A::Array{T,1}) where T <: RingElem
	n=W.prec
	n>length(A) && error("not enough terms supplied to give unambiguous Witt Vector output")
	length(A)>n && println("Warning: more coordinates given that allowable precision, throwing out all terms past $(W.prec)")
	r=deepcopy(zero(W))
	r.xcoords=A[1:n]
	return r
end
=#
function (W::TruncatedBigWittRing{T})(A::Vector{T}) where T <: RingElem
	n=(W.untruncated).prec
	m=length(truncationlist(W.truncationset))
	if n== length(A)
		r=deepcopy(zero(W))
		r.xcoords=A
	elseif m==length(A)
		r=deepcopy(zero(W))
		Sl=truncationlist(W.truncationset)
		for i in eachindex(Sl)
			r.xcoords[Sl[i]]=A[i]
		end
	else error("Dimension mismatch; could not confidently interpret supplied vector as coordinates for a truncated Witt vector in $(W)")
	end
	return truncate!(r)
end

function (W::TruncatedBigWittRing{T})(A::Vector) where T <: RingElement
	R=base_ring(W)
	Ap=broadcast(R,A)
	n=(W.untruncated).prec
	m=length(truncationlist(W.truncationset))
	if n== length(A)
		r=deepcopy(zero(W))
		r.xcoords=Ap
	elseif m==length(A)
		r=deepcopy(zero(W))
		Sl=truncationlist(W.truncationset)
		for i in eachindex(Sl)
			r.xcoords[Sl[i]]=Ap[i]
		end
	else error("Dimension mismatch; could not confidently interpret supplied vector as coordinates for a truncated Witt vector in $(W)")
	end
	return truncate!(r)
end
function (W::TruncatedBigWittRing{T})(w::TruncatedWittVector{T}) where T <: RingElement
	W != parent(w) && error("Unable to coerce element")
	return w
end

####################
#Parent constructor#
####################
"""
	function TruncatedBigWittVectorRing(R::Ring, S::Vector{Bool}, cached::Bool=true, stabilize::Bool=true)
Return a ring of Witt vectors over the base ring `R` truncated by the truncation set `S`. 

Similarly to the corresponding untruncated constructor, the `cached` argument determines whether to add the created ring to the parent types dictionary. Recommended this is always true unless you really know what you are doing. The `stabilize` option determines whether to replace the truncation set `S` with `divisor_stabilize(S)`. One can expect a slight speedup if called with `stabilize=false` the first time the ring is created, but this will induce unexpected behavior (namely it will in all likelihood break the associativity of the `+` and `*` operators) if `S` is not divisor-stable to begin with. Recommended you call with `stabilize=true` (the default option if no argument specified) unless you are creating a great number of Witt rings at once with truncation sets you know to be divisor-stable and need the speedup. The resulting object `W` will have `W.untruncated.prec` equal to the length of the supplied truncation set. Recommended the last entry of `S` is true in order to optimize performance and decrease the chances of creating functionally identical parent objects which are unequal.

    function TruncatedBigWittVectorRing(R::Ring, Ns::Vector{Int}, cached::Bool=true, stabilize::Bool=true)
Same as above except now taking an integer-vector argument.

    function TruncatedBigWittVectorRing(W::BigWittRing, S::Vector{Bool}, cached::Bool=true, stabilize::Bool=true)
Return `TruncatedBigWittVectorRing(W.base_ring, S, cached, stabilize)`.
"""
function TruncatedBigWittVectorRing(R::Ring, S::Vector{Bool}, cached::Bool=true, stabilize::Bool=true)
	T=elem_type(R)
	n=length(S)
	stabilize ? S_stable=divisor_stabilize(S) : S_stable=S
	W=BigWittRing{T}(R,n,cached)
	return TruncatedBigWittRing{T}(W,S_stable,cached)
end
function TruncatedBigWittVectorRing(R::Ring, Ns::Vector{Int}, cached::Bool=true, stabilize::Bool=true)
	return TruncatedBigWittVectorRing(R,truncationbools(Ns), cached, stabilize)
end
"""
    function pTypicalWittVectorRing(R::Ring, p::Integer, m::Integer,cached::Bool=true)
Specialized version of the `TruncatedBigWittVectorRing` to create ``W_{p^m}(R)``, the ring of `p`-typical Witt vectors represented up to entry `p^m`. Resulting object `W` will have `W.untruncated.prec` equal to `p^m`.

## Example:
```jldoctest
julia> using AbstractAlgebra, WittVectors;

julia> W=pTypicalWittVectorRing(GF(3),2,3)
Witt vector ring over Finite field F_3 truncated over the set [1, 2, 4, 8]

julia> w=W([2,1,0,2])
AbstractAlgebra.GFElem{Int64}[2, 1, 0, 2] truncated over [1, 2, 4, 8]

julia> w1=W([2,1,1,0,1,1,1,2])
AbstractAlgebra.GFElem{Int64}[2, 1, 0, 2] truncated over [1, 2, 4, 8]

julia> w==w1
true

julia> w1.xcoords
8-element Vector{AbstractAlgebra.GFElem{Int64}}:
 2
 1
 0
 0
 0
 0
 0
 2
```
    pTypicalWittVectorRing(W::BigWittRing, p::Integer, m::Integer, cached::Bool=true)
Return `pTypicalWittVectorRing(base_ring(W), p, m, cached)` 
"""
function pTypicalWittVectorRing(R::Ring, p::Integer, m::Integer,cached::Bool=true)
	 ~isprime(p) && error("nonprime p") 
	 Sl=[p^(k-1) for k in 1:(m+1)]
	 return TruncatedBigWittVectorRing(R,Sl,cached, false)
end
function TruncatedBigWittVectorRing(W::BigWittRing, S::Vector{Bool}, cached::Bool=true, stabilize::Bool=true)
	return TruncatedBigWittVectorRing(base_ring(W), S, cached, stabilize)
end
pTypicalWittVectorRing(W::BigWittRing, p::Integer, m::Integer, cached::Bool=true)=pTypicalWittVectorRing(base_ring(W), p, m, cached)
#############################
#Truncating Big Witt vectors#
#############################
"""
    truncate(W::BigWittRing, S::Vector{Bool}) 
Return a `TruncatedBigWittVectorRing` `W_new` with `W_new.untruncated` being `W`, truncated by `S`.  
"""
truncate(W::BigWittRing, S::Vector{Bool}) = TruncatedBigWittVectorRing(W,S,true,true)
"""
    function truncate(w::WittVector, S::Vector{Bool})
Return the image of `w` in the quotient map ``W(R)→W_S(R)``. Parent object will be `truncate(w.parent, S)`
"""
function truncate(w::WittVector, S::Vector{Bool})
	W=truncate(w.parent, S)
	t=deepcopy(zero(W))
	t.xcoords=w.xcoords
	return truncate!(t)
end
