module WittVectors


using AbstractAlgebra

using Random: Random, SamplerTrivial, GLOBAL_RNG
using RandomExtensions: RandomExtensions, Make2, AbstractRNG
using Primes: isprime

import AbstractAlgebra: parent_type, elem_type, base_ring, parent, is_domain_type, is_exact_type, canonical_unit, isequal, divexact, zero!, mul!, add!, addeq!, get_cached!, is_unit, characteristic, Ring, RingElem, expressify, truncate
#consider renaming truncate function to avoid adding new method to AbstractAlgebra.truncate (toQuotient?)
import Base: show, +, -, *, ^, ==, inv, isone, iszero, one, zero, rand, deepcopy, deepcopy_internal, hash, parent

export BigWittRing, BigWittVectorRing, WittVector, TruncatedBigWittRing, TruncatedWittVector, TruncatedBigWittVectorRing, pTypicalWittVectorRing, truncate, isconstant, zero, one, isone, iszero, truncationbools, truncationlist, divisor_stabilize
"""
## Parent and child object types
	mutable struct BigWittRing{T <: RingElement} <: Ring
Parent object type for Big Witt Rings (i.e. truncated only by a maximum precision rather than a more general divisor-stable set). Should be constructed using the exported constructors, although I think it's basically safe to call WittVectors.BigWittRing directly.

	(W::BigWittRing{T})() where T <: RingElement
The basic constructor given a Witt Ring W. Identical to zero(W) (in fact the latter simply calls W())
#### Example:
```jldoctest
julia> using AbstractAlgebra; W=BigWittVectorRing(ZZ,10)
Big Witt vector ring represented up to degree 10 over Integers

julia> w=W()
BigInt[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
julia> iszero(w)
true
```
### Constructors
	(W::BigWittRing{T})(c::Integer) where T <: RingElement
	(W::BigWittRing{T})(c::T) where T <: RingElement
Since there is no additive ring homomorphism R→W(R), calling `W(c)` for `c` an element of `R` returns the constant lift of `c`. This is more-or-less the only candidate for that functionality, but for that reason `W(c)` for `c` an integer does not behave the way it does for the other functorial constructions out of the category of Rings of AbstractAlgebra.jl. All of the pre-existing such ``F`` (to my knowledge) admit a natural transformation ``id ⟹  F``, so in those cases calling ``FR(c)`` where `c` may be interpreted as either an element of R or as a Julia integral type is unambiguous and returns the image of `c` in the composition of structure maps ``Z→R→FR``. Since we do not have such a natural transformation at our disposal, to avoid ambiguity we have defined `W(c)` to be the constant lift of the image of `c` in ``ZZ→R``.
#### Example: 
```jldoctest

julia> using AbstractAlgebra; W1=BigWittVectorRing(ZZ,10)
Big Witt vector ring represented up to degree 10 over Integers

julia> W1(256)
BigInt[256, 0, 0, 0, 0, 0, 0, 0, 0, 0]

julia> W2=BigWittVectorRing(GF(7),10)
Big Witt vector ring represented up to degree 10 over Finite field F_7

julia> W2(256)
AbstractAlgebra.GFElem{Int64}[4, 0, 0, 0, 0, 0, 0, 0, 0, 0]

julia> W3=BigWittVectorRing(AbsSeriesRing(GF(23),10),10) #functionality uninterupted by using recursive constructions
Big Witt vector ring represented up to degree 10 over Univariate power series ring in x over Finite field F_23

julia> W3(256)
AbstractAlgebra.Generic.AbsSeries{AbstractAlgebra.GFElem{Int64}}[3 + O(x^10), O(x^10), O(x^10), O(x^10), O(x^10), O(x^10), O(x^10), O(x^10), O(x^10), O(x^10)]
```
The second one is possibly needed to prevent ambiguity, according to the [ring interface](https://nemocas.github.io/AbstractAlgebra.jl/dev/ring_interface/) documentation for AbstractAlgebra.jl.


	(W::BigWittRing{T})(c::T) where T <: RingElement
This is the constant lift ``R→W(R)``, which is multiplicative but not additive.


	(W::BigWittRing{T})(A::Vector{T}) where T <: RingElem
Additional constructor to create a Witt vector by supplying its coordinates. Will return an error if supplied more coordinates than `W.prec` 
"""
mutable struct BigWittRing{T <: RingElement} <: Ring
	base_ring::Ring
	prec::Int

	function BigWittRing{T}(R::Ring, max_prec::Int, cached::Bool) where T<: RingElement
		return get_cached!(WittVectorID, (R, max_prec), cached) do
			new{T}(R,max_prec)
		end::BigWittRing{T}
	end
end

const WittVectorID=AbstractAlgebra.CacheDictType{Tuple{Ring,Int},Ring}()
"""
	mutable struct WittVector{T <: RingElement} <: RingElem
Object type for Big Witt Vectors, i.e. child objcets of BigWittRing{T}s. DO NOT CONSTRUCT USING WittVectors.WittVector{T}(coords, prec), this will produce an orphan Witt Vector which you would then have to assign a parent to directly. Parent-child compatibility is geneerally unchecked, so no lifeguard on duty. Rather, construct with constructors below. 
"""
mutable struct WittVector{T <: RingElement} <: RingElem
	xcoords::Vector{T}
	prec::Int
	parent::BigWittRing{T}

	function WittVector{T}(coords::Vector{T}, prec::Int) where T <: RingElement
		return new(coords, prec)
	end
end
#########
#Imports#
#########

include("algorithms/wittseries.jl")
include("algorithms/getcoords.jl")
include("Truncated.jl")
#####################################
#Data type and parent object methods#
#####################################
"""
## Data type and parent object methods
	parent_type(::Type{WittVector{T}}) where T <: RingElement
	elem_type (::Type{WittVector{T}}) where T <: RingElement
	base_ring(R::BigWittRing)
	parent(R::WittVector)
	is_domain_type(::Type{WittVector{T}}) where T <: RingElement
	is_exact_type(::Type{WittVector{T}}) where T <: RingElement
	hash(w::WittVector, h::UInt)
	deepcopy_internal(w::WittVector{T}, d::IdDict) where T <: RingElement
Standard components of any conformant ring implementation in AbstractAlgebra.jl. See the documentation [there](https://nemocas.github.io/AbstractAlgebra.jl/dev/ring_interface/)
"""
parent_type(::Type{WittVector{T}}) where T <: RingElement = BigWittRing{T}

elem_type(::Type{BigWittRing{T}}) where T <: RingElement = WittVector{T}

base_ring(R::BigWittRing) = R.base_ring

parent(v::WittVector) = v.parent

is_domain_type(::Type{WittVector{T}}) where T <: RingElement = false#is_domain_type(T) #TODO figure out if this makes sense in our context/what this means

is_exact_type(::Type{WittVector{T}}) where T <: RingElement = is_exact_type(T) #TODO ditto, although I'm a little more confident for this one than the last

function hash(w::WittVector, h::UInt)
	r = 0x65125ab8e0cd44ca
	X= w.xcoords
	s=UInt(1)
	for i in eachindex(w.xcoords)
		s=xor(s, hash(X[i],h))
	end
	return xor(r,s)
end

function deepcopy_internal(w::WittVector{T},d::IdDict) where T <: RingElement
	coords=Array{T}(undef, w.prec)
	X=w.xcoords
	for i = 1:w.prec
		coords[i]=deepcopy_internal(X[i],d)
	end
	m=deepcopy_internal(w.prec,d)
	r=WittVector{T}(vec(coords),m)
	r.parent=w.parent
	return r
end

####################
#Basic manipulation#
####################
"""
	zero(W::BigWittRing)
	one(W::BigWittRing)
	isone(w::WittVector)
	iszero(w::WittVector)
More standard ring interface functions. Check the documentation for AbstractAlgebra.jl's [generic ring interface](https://nemocas.github.io/AbstractAlgebra.jl/dev/ring_interface/)
"""
function zero(W::BigWittRing)#TODO this needs to be figured out
#	R=W.base_ring
#	n=W.max_prec
	r=deepcopy(W())
	r.parent=W
	return r
end


function one(W::BigWittRing)# =R(1)#TODO same
	R=W.base_ring
	n=W.prec
	r=deepcopy(zero(W))
	r.xcoords=vcat(vec([one(R)]),zeros(R,n-1))
	return r
end
function iszero(w::WittVector)
	X=w.xcoords
	return prod(iszero(X[i]) for i in eachindex(X))
end
"""
	function isconstant(w::WittVector)
Returns true if w is in the image of the constant lift set map R→W(R) (better known by another name, but we are avoiding the Nazi associations (somewhat unavoidable in the case of Ernst Witt)).
"""
function isconstant(w::WittVector)
	X=w.xcoords
	n=length(X)
	return prod(iszero(X[i]) for i in 2:n)
end
function isone(w::WittVector)
	X=w.xcoords
	n=length(X)
	return isone(X[1])*prod(iszero(X[i]) for i in 2:n)
end
"""
	is_unit(w::WittVector)
Returns true if w is known to be a unit. Known being the operative word here--outside of special cases like W_p(Z/p), I do not really know a good way to know whether a given Witt vector is a unit. This functionality may be expanded in the future (but perhaps do not hold your breath).
"""
function is_unit(w::WittVector)
	println("WARNING: checking if a Witt Vector is a unit, but I don't actually know how to implement it--this will return false negatives for units other than [1]")
	return isone(w)
end
		
#is_unit(w::WittVector)#TODO honestly I don't even know a characterization of units in W(R). probably should figure out if there's a well-known one. Obviously, requires that w.xcoords[1] is a unit--is that all though? certainly the case for series rings, but these obviously do not work in exact analogy.
#characteristic(R::BigWittRing) #TODO same basically
################
#Canonical Unit#
################

canonical_unit(w::WittVector)=one(w.parent)#improving this could potentially help performance, but uh... lets get things working first

############
#String I/O#
############

function show(io::IO,W::BigWittRing)
	print(io, "Big Witt vector ring represented up to degree $(W.prec) over ")
	show(io, base_ring(W))
end

function show(io::IO, w::WittVector)
	print(io, w.xcoords)
end
###################
#Expressification?#
###################

function expressify(W::BigWittRing; context = nothing)
	return Expr(:sequence, Expr(:text,"Big Witt vectors over "), expressify(base_ring(W),context = context))
end
function expressify(w::WittVector; context = nothing)
	return expressify(f.xcoords, context = context)
end

##################
#Unary operations#
##################
#One idea that may improve performance and may fix some type-stability problems that may arise is to associate the power series ring used for addition and multiplication to the witt ring itself--possibly as an optional field (need to look in to how possible that is/if I can parametrize the default choice by the necessary fields) or possibly by some global dictionary strategy.
#

function -(w::WittVector)
	negw=deepcopy(w)
	negw.xcoords=getcoords(negseries(w))
	return negw
end

###################
#Binary Operations#
###################

function +(w::WittVector{T}, v::WittVector{T}) where T<: RingElement
	parent(w) != parent(v) &&error("Incompatible Rings")
	addnseries=seriesrep(w)*seriesrep(v)
	sumvec=deepcopy(w)
	sumvec.xcoords=getcoords(addnseries)
	return sumvec
end
include("algorithms/seriesmult.jl")
function *(w::WittVector{T}, v::WittVector{T}) where T <: RingElement
	parent(w) != parent(v) && error("Incompatible Rings")
	multnseries= multseries(w.xcoords,v.xcoords)
	prodvec=deepcopy(w)
	prodvec.xcoords=getcoords(multnseries)
	return prodvec
end
function -(w::WittVector{T}, v::WittVector{T}) where T <: RingElement
	parent(w) != parent(v) && error("Incompatible Rings")
	subnseries=divexact(seriesrep(w),seriesrep(v))
	r=deepcopy(w)
	r.xcoords=getcoords(subnseries)
	return r
end

#####################
#Z-Algebra structure#
#####################
#not really necessary per se (you can also multiply by constant elements) but this will likely perform no small amount better!
"""
## Z-algebra Structure
	*(w::WittVector{T}, c::Integer) where T <: RingElement
Since there is no additive ring homomorphism R→W(R), calling W(c) for c an element of R returns the constant lift of c. This is more-or-less the only candidate for that functionality, but for that reason W(c) for c an integer does not behave the way it does for the other functorial constructions out of the category of Rings of AbstractAlgebra.jl. All of the pre-existing such F (to my knowledge) admit a natural transformation id ⟹F, so in those cases calling FR(c) where c may be interpreted as either an element of R or as a Julia integral type is unambiguous and returns the image of c in the composition of structure maps Z→R→FR. Since we do not have such a natural transformation at our disposal, to avoid ambiguity we have defined W(c) to be the constant lift of the image of c in Z→R. Thus, in particular, for a Witt Vector w∈W, W(2)*w ≂̸ w+w (again, unlike other functorial ring constructions in Julia). To compensate, an additional method has been added to the multiplication function * to accept mixed arguments.
### Example:
```jldoctest
julia> using AbstractAlgebra; W=BigWittVectorRing(ZZ,10)
Big Witt vector ring represented up to degree 10 over Integers

julia> w=one(W)
xBigInt[1, 0, 0, 0, 0, 0, 0, 0, 0, 0]

julia> x=W(2)*w
BigInt[2, 0, 0, 0, 0, 0, 0, 0, 0, 0]

julia> y=2*w
BigInt[2, -1, -2, -4, -6, -12, -18, -40, -54, -120]

julia> x==w+w
false

julia> y==w+w
true

julia> z=w*2
BigInt[2, -1, -2, -4, -6, -12, -18, -40, -54, -120]

julia> z==w+w
true

julia> r=(-2)*w
BigInt[-2, -3, 2, -9, 6, -4, 18, -93, 54, -72]

julia> r + w + w== 0
true
```
"""
function *(w::WittVector{T}, c::Integer) where T <: RingElement
	r=deepcopy(w)
	if c>= 0 
		r.xcoords=getcoords(seriesrep(w)^c)
	elseif c<0
		r.xcoords=getcoords(inv(seriesrep(w))^(-c))
	end
	return r
end
function *(c::Integer, w::WittVector{T}) where T <: RingElement
	return *(w,c)#is this necessary?
end
############
#Comparison#
############

function ==(w::WittVector{T}, v::WittVector{T}) where T<: RingElement
	parent(w) != parent(v) && error("Incompatible Rings")
	X=v.xcoords
	Y=w.xcoords
	return prod(X[i]==Y[i] for i in eachindex(X))
end
function isequal(w::WittVector{T},v::WittVector{T}) where T<: RingElement
	parent(w) != parent(v) && error("Incompatible Rings")
	X=v.xcoords
	Y=w.xcoords
	return prod(isequal(X[i],Y[i]) for i in eachindex(X))
end
################
#Exact Division#
################
#Ah, no idea how to handle this. We NEED a good way to tell when w is a unit. Leaving blank for now.
"""
	divexact(w::WittVector{T}, v::WittVector{T}; check::Bool=true) where T <: RingElement
	inv(w::WittVector)
These are effectively not implemented--it has exactly what it needs to in order not to fail the conformance tests, which is to say that if v=W(1), divexact(w,v) returns w. Otherwise, it returns an error. Like everything else having to do with units in the ring of Big Witt Vectors, this may be expanded eventually, but no promises.
"""
function divexact(w::WittVector{T}, v::WittVector{T}; check::Bool=true) where T <: RingElement
	parent(w) != parent(v) && error("Incompatible rings")
	iszero(v) && error("Witt vector division by zero (fix: should be a division error") 
	if v==one(parent(v)) return w
	else
		return error("Witt vector division only implemented for denominator==1")
	end
end
function inv(w::WittVector)
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

function zero!(w::WittVector)
	w=zero(parent(w))
	return w
end
function mul!(u::WittVector{T}, w::WittVector{T}, v::WittVector{T}) where T <: RingElement
	#parent(w) != parent(v) && error("Incompatible Rings")
	#parent(u) != parent(w) && error("Incompatible Rings")
	u.xcoords=getcoords(multseries(w.xcoords,v.xcoords))
	return u
end
function add!(u:: WittVector{T}, w::WittVector{T}, v::WittVector{T}) where T<: RingElement
	#parent(w) != parent(v) && error("Incompatible Rings")
	#parent(u) != parent(w) && error("Incompatible Rings")
	u.xcoords=getcoords(seriesrep(w)*seriesrep(v))
	return u
end

function addeq!(w::WittVector{T}, v::WittVector{T}) where T <: RingElement
	w.xcoords=getcoords(seriesrep(w)*seriesrep(v))
	return w
end

###################
#Random Generation#
###################

#hooooooooo ok also #TODO
#I suppose one option would be using the existing implementation for series rings--namely <random witt vector> = getcoords . 1+x<random series>
#
function RandomExtensions.make(W::BigWittRing, deg_range::UnitRange{Int}, vs...)
   R = base_ring(W)
   if length(vs) == 1 && elem_type(R) == Random.gentype(vs[1])
      Make(W, deg_range, vs[1]) # forward to default Make constructor
   else
      make(W, deg_range, make(R, vs...))
   end
end

RandomExtensions.maketype(W::BigWittRing, _) = elem_type(W)

# define rand for make(S, deg_range, v)
#function rand(rng::AbstractRNG, sp::SamplerTrivial{<:Make3{<:RingElement,<:BigWittRing,UnitRange{Int}}})
function rand(rng::AbstractRNG, sp::SamplerTrivial{<:Make2{<:RingElement,<:BigWittRing}})
   W, v = sp[][1:end]
   R = base_ring(W)
   w = deepcopy(W())
   #x = gen(S)
   # degree -1 is zero polynomial
   m = W.prec
   for i = 1:m
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

promote_rule(::Type{WittVector{T}}, ::Type{WittVector{T}}) where T <: RingElement = WittVector{T}

function promote_rule(::Type{WittVector{T}}, ::Type{U}) where {T <: RingElement, U <: RingElement}
	#YIKES do I have no idea what is going on here. For now copying the minimal ring interface code.
	promote_rule(T, U) == T ? WittVector{T} : Union{}
end

##############
#Constructors#
##############

function (W::BigWittRing{T})() where T <: RingElement
	R=base_ring(W)
	n=W.prec
	r=WittVector{T}(zeros(R,n),n)
	r.parent=W
	return r
end
function (W::BigWittRing{T})(c::Integer) where T <: RingElement
	r=deepcopy(zero(W))
	R=base_ring(W)
	r.xcoords[1]=R(c)#getcoords(intseries(c,W))
	return r
end

#possibly needed to prevent ambiguity
function (W::BigWittRing{T})(c::T) where T <: Integer
	r=deepcopy(zero(W))
	R=base_ring(W)
	r.xcoords[1]=R(c)# =getcoords(intseries(c,W))
	return r
end
function (W::BigWittRing{T})(c::T) where T <: RingElement
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
function (W::BigWittRing{T})(A::Vector{T}) where T <: RingElem
	n=W.prec
	n>length(A) && error("not enough terms supplied to give unambiguous Witt Vector output")
	length(A)>n && println("Warning: more coordinates given that allowable precision, throwing out all terms past $(W.prec)")
	r=deepcopy(zero(W))
	r.xcoords=A[1:n]
	return r
end

function (W::BigWittRing{T})(w::WittVector{T}) where T <: RingElement
	W != parent(w) && error("Unable to coerce element")
	return w
end

####################
#Parent constructor#
####################
"""
	BigWittVectorRing(R::Ring, n::Integer, cached::Bool=true)
Main constructor for creating rings of Witt vectors. Returns parent object for the ring of Witt vectors over the base ring `R` up to degree `n`. The optional `cached` argument determines whether to cache the returned object, so that calling the same constructor with the same arguments `R,n` twice returns the same object and hence child objects will be compatible--no life guard on duty if you call `BigWittVectorRing` with `cached==false`.

"""
function BigWittVectorRing(R::Ring, n::Integer, cached::Bool=true)
	T=elem_type(R)
	return BigWittRing{T}(R,n,cached)
end
end


