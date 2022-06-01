var documenterSearchIndex = {"docs":
[{"location":"#WittVectors.jl:-An-implementation-of-big-Witt-vectors-supporting-truncation-over-arbitrary-divisor-stable-sets","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","text":"","category":"section"},{"location":"","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","text":"DocTestSetup = quote\n\tusing AbstractAlgebra\n\tusing WittVectors\nend","category":"page"},{"location":"","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","text":"","category":"page"},{"location":"#Parent-and-child-objects-and-constructors","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"Parent and child objects and constructors","text":"","category":"section"},{"location":"","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","text":"BigWittRing\nWittVector\nBigWittVectorRing\nTruncatedBigWittRing\nTruncatedWittVector\nTruncatedBigWittVectorRing\npTypicalWittVectorRing","category":"page"},{"location":"#WittVectors.BigWittRing","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.BigWittRing","text":"mutable struct BigWittRing{T <: RingElement} <: Ring\n\nParent object type for Big Witt Rings (i.e. truncated only by a maximum precision rather than a more general divisor-stable set). Should be constructed using the exported constructors, although I think it's basically safe to call WittVectors.BigWittRing directly.\n\n(W::BigWittRing{T})() where T <: RingElement\n\nThe basic constructor given a Witt Ring W. Identical to zero(W) (in fact the latter simply calls W())\n\nExample:\n\njulia> using AbstractAlgebra;\n\njulia> using WittVectors;\n\njulia> W=BigWittVectorRing(ZZ,10)\nBig Witt vector ring represented up to degree 10 over Integers\n\njulia> w=W()\nBigInt[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]\n\njulia> iszero(w)\ntrue\n\nConstructors\n\n(W::BigWittRing{T})(c::Integer) where T <: RingElement\n(W::BigWittRing{T})(c::T) where T <: RingElement\n\nSince there is no additive ring homomorphism R→W(R), calling W(c) for c an element of R returns the constant lift of c. This is more-or-less the only candidate for that functionality, but for that reason W(c) for c an integer does not behave the way it does for the other functorial constructions out of the category of Rings of AbstractAlgebra.jl. All of the pre-existing such F (to my knowledge) admit a natural transformation id   F, so in those cases calling FR(c) where c may be interpreted as either an element of R or as a Julia integral type is unambiguous and returns the image of c in the composition of structure maps ZRFR. Since we do not have such a natural transformation at our disposal, to avoid ambiguity we have defined W(c) to be the constant lift of the image of c in ZZR.\n\nExample:\n\njulia> using WittVectors;\n\njulia> using AbstractAlgebra;\n\njulia> W1=BigWittVectorRing(ZZ,10)\nBig Witt vector ring represented up to degree 10 over Integers\n\njulia> W1(256)\nBigInt[256, 0, 0, 0, 0, 0, 0, 0, 0, 0]\n\njulia> W2=BigWittVectorRing(GF(7),10)\nBig Witt vector ring represented up to degree 10 over Finite field F_7\n\njulia> W2(256)\nAbstractAlgebra.GFElem{Int64}[4, 0, 0, 0, 0, 0, 0, 0, 0, 0]\n\njulia> W3=BigWittVectorRing(AbsSeriesRing(GF(23),10),10)\nBig Witt vector ring represented up to degree 10 over Univariate power series ring in x over Finite field F_23\n\njulia> W3(256)\nAbstractAlgebra.Generic.AbsSeries{AbstractAlgebra.GFElem{Int64}}[3 + O(x^10), O(x^10), O(x^10), O(x^10), O(x^10), O(x^10), O(x^10), O(x^10), O(x^10), O(x^10)]\n\nThe second one is possibly needed to prevent ambiguity, according to the ring interface documentation for AbstractAlgebra.jl.\n\n(W::BigWittRing{T})(c::T) where T <: RingElement\n\nThis is the constant lift RW(R), which is multiplicative but not additive.\n\nDocTestSetup = quote\n\tusing AbstractAlgebra, WittVectors, Hecke\nend\n\njulia> using AbstractAlgebra, Hecke, WittVectors, Nemo;\n\n\n\njulia> Qx,x = PolynomialRing(Hecke.QQ, \"x\")\n(Univariate Polynomial Ring in x over Rational Field, x)\n\njulia> f=x^3+x+1\nx^3 + x + 1\n\njulia> R, a=Hecke.NumberField(f, 'a', cached=true, check=true)\n(Number field over Rational Field with defining polynomial x^3 + x + 1, a)\n\njulia> W=BigWittVectorRing(R,8)\nBig Witt vector ring represented up to degree 8 over Number field over Rational Field with defining polynomial x^3 + x + 1\n\njulia> W(a+2)\nNemo.nf_elem[a + 2, 0, 0, 0, 0, 0, 0, 0]\n\nDocTestSetup = nothing\n\n(W::BigWittRing{T})(A::Vector{T}) where T <: RingElem\n\nAdditional constructor to create a Witt vector by supplying its coordinates. Will return an error if supplied more coordinates than W.prec \n\n\n\n\n\n","category":"type"},{"location":"#WittVectors.WittVector","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.WittVector","text":"mutable struct WittVector{T <: RingElement} <: RingElem\n\nObject type for Big Witt Vectors, i.e. child objcets of BigWittRing{T}s. DO NOT CONSTRUCT USING WittVectors.WittVector{T}(coords, prec), this will produce an orphan Witt Vector which you would then have to assign a parent to directly. Parent-child compatibility is geneerally unchecked, so no lifeguard on duty. Rather, construct with constructors below. \n\n\n\n\n\n","category":"type"},{"location":"#WittVectors.BigWittVectorRing","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.BigWittVectorRing","text":"BigWittVectorRing(R::Ring, n::Integer, cached::Bool=true)\n\nMain constructor for creating rings of Witt vectors. Returns parent object for the ring of Witt vectors over the base ring R up to degree n. The optional cached argument determines whether to cache the returned object, so that calling the same constructor with the same arguments R,n twice returns the same object and hence child objects will be compatible–no life guard on duty if you call BigWittVectorRing with cached==false.\n\n\n\n\n\n","category":"function"},{"location":"#WittVectors.TruncatedBigWittRing","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.TruncatedBigWittRing","text":"mutable struct TruncatedBigWittRing{T <: RingElement} <: Ring\n\nParent object for truncated rings of Witt vectors. Contains two fields, untruncated::BigWittRing{T} which is the underlying ring (prior to quotient) and truncationset::Vector{Bool} which determines which indices are kept in the truncation. truncationset should be the same length as untruncated.prec.\n\nConstructors\n\nfunction (W::TruncatedBigWittRing{T})() where T <: RingElement\nfunction (W::TruncatedBigWittRing{T})(c::Integer) where T <: RingElement\nfunction (W::TruncatedBigWittRing{T})(c::T) where T <: Integer\nfunction (W::TruncatedBigWittRing{T})(c::T) where T <: RingElement\n\nEach of these mirror the functionality in the untruncated case.\n\nfunction (W::TruncatedBigWittRing{T})(A::Vector{T}) where T <: RingElem\n\nReturn a Witt vector with coordinates specified by A. A can be the length of W.truncationset (i.e. W.untruncated.prec in which case it will ignore the entries of A ignored by W or it can be length equal to the number of true entries in W.truncationset, in which case it will fill in the missing (irrelevant) entries with zero. \n\n\n\n\n\n","category":"type"},{"location":"#WittVectors.TruncatedWittVector","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.TruncatedWittVector","text":"mutable struct TruncatedWittVector{T <: RingElement} <: RingElem\n\nChild type for truncated Witt vectors. Contains three fields, xcoords::Vector{T} which are its coordinates (INCLUDING indices not in the truncation set), truncationset::Vector{Bool} and parent::TruncatedBigWittRing{T}. truncationset and parent.truncationset should match.\n\n\n\n\n\n","category":"type"},{"location":"#WittVectors.TruncatedBigWittVectorRing","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.TruncatedBigWittVectorRing","text":"function TruncatedBigWittVectorRing(R::Ring, S::Vector{Bool}, cached::Bool=true, stabilize::Bool=true)\n\nReturn a ring of Witt vectors over the base ring R truncated by the truncation set S. \n\nSimilarly to the corresponding untruncated constructor, the cached argument determines whether to add the created ring to the parent types dictionary. Recommended this is always true unless you really know what you are doing. The stabilize option determines whether to replace the truncation set S with divisor_stabilize(S). One can expect a slight speedup if called with stabilize=false the first time the ring is created, but this will induce unexpected behavior (namely it will in all likelihood break the associativity of the + and * operators) if S is not divisor-stable to begin with. Recommended you call with stabilize=true (the default option if no argument specified) unless you are creating a great number of Witt rings at once with truncation sets you know to be divisor-stable and need the speedup. The resulting object W will have W.untruncated.prec equal to the length of the supplied truncation set. Recommended the last entry of S is true in order to optimize performance and decrease the chances of creating functionally identical parent objects which are unequal.\n\nfunction TruncatedBigWittVectorRing(R::Ring, Ns::Vector{Int}, cached::Bool=true, stabilize::Bool=true)\n\nSame as above except now taking an integer-vector argument.\n\nfunction TruncatedBigWittVectorRing(W::BigWittRing, S::Vector{Bool}, cached::Bool=true, stabilize::Bool=true)\n\nReturn TruncatedBigWittVectorRing(W.base_ring, S, cached, stabilize).\n\n\n\n\n\n","category":"function"},{"location":"#WittVectors.pTypicalWittVectorRing","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.pTypicalWittVectorRing","text":"function pTypicalWittVectorRing(R::Ring, p::Integer, m::Integer,cached::Bool=true)\n\nSpecialized version of the TruncatedBigWittVectorRing to create W_p^m(R), the ring of p-typical Witt vectors represented up to entry p^m. Resulting object W will have W.untruncated.prec equal to p^m.\n\npTypicalWittVectorRing(W::BigWittRing, p::Integer, m::Integer, cached::Bool=true)\n\nReturn pTypicalWittVectorRing(base_ring(W), p, m, cached) \n\n\n\n\n\n","category":"function"},{"location":"#Data-type-and-parent-object-methods","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"Data type and parent object methods","text":"","category":"section"},{"location":"","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","text":"divexact(w::WittVector{T}, v::WittVector{T}; check::Bool=true) where T <: RingElement","category":"page"},{"location":"#AbstractAlgebra.divexact-Union{Tuple{T}, Tuple{WittVector{T}, WittVector{T}}} where T<:RingElement","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"AbstractAlgebra.divexact","text":"divexact(w::WittVector{T}, v::WittVector{T}; check::Bool=true) where T <: RingElement\ninv(w::WittVector)\n\nThese are effectively not implemented–it has exactly what it needs to in order not to fail the conformance tests, which is to say that if v=W(1), divexact(w,v) returns w. Otherwise, it returns an error. Like everything else having to do with units in the ring of Big Witt Vectors, this may be expanded eventually, but no promises.\n\n\n\n\n\n","category":"method"},{"location":"#Basic-Manipulation","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"Basic Manipulation","text":"","category":"section"},{"location":"","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","text":"zero\nWittVectors.isconstant\nis_unit(w::WittVector)","category":"page"},{"location":"#Base.zero","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"Base.zero","text":"zero(W::BigWittRing)\none(W::BigWittRing)\nisone(w::WittVector)\niszero(w::WittVector)\n\nMore standard ring interface functions. Check the documentation for AbstractAlgebra.jl's generic ring interface\n\n\n\n\n\n","category":"function"},{"location":"#AbstractAlgebra.isconstant","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"AbstractAlgebra.isconstant","text":"function isconstant(w::WittVector)\n\nReturns true if w is in the image of the constant lift set map R→W(R) (better known by another name, but we are avoiding the Nazi associations (somewhat unavoidable in the case of Ernst Witt)).\n\n\n\n\n\n","category":"function"},{"location":"#AbstractAlgebra.is_unit-Tuple{WittVector}","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"AbstractAlgebra.is_unit","text":"is_unit(w::WittVector)\n\nReturns true if w is known to be a unit. Known being the operative word here–outside of special cases like W_p(Z/p), I do not really know a good way to know whether a given Witt vector is a unit. This functionality may be expanded in the future (but perhaps do not hold your breath).\n\n\n\n\n\n","category":"method"},{"location":"#Binary-Operations","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"Binary Operations","text":"","category":"section"},{"location":"","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","text":"*","category":"page"},{"location":"#Base.:*","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"Base.:*","text":"Z-algebra Structure\n\n*(w::WittVector{T}, c::Integer) where T <: RingElement\n\nSince there is no additive ring homomorphism R→W(R), calling W(c) for c an element of R returns the constant lift of c. This is more-or-less the only candidate for that functionality, but for that reason W(c) for c an integer does not behave the way it does for the other functorial constructions out of the category of Rings of AbstractAlgebra.jl. All of the pre-existing such F (to my knowledge) admit a natural transformation id ⟹F, so in those cases calling FR(c) where c may be interpreted as either an element of R or as a Julia integral type is unambiguous and returns the image of c in the composition of structure maps Z→R→FR. Since we do not have such a natural transformation at our disposal, to avoid ambiguity we have defined W(c) to be the constant lift of the image of c in Z→R. Thus, in particular, for a Witt Vector w∈W, W(2)*w ≂̸ w+w (again, unlike other functorial ring constructions in Julia). To compensate, an additional method has been added to the multiplication function * to accept mixed arguments.\n\nExample:\n\njulia> using AbstractAlgebra;\n\njulia> using WittVectors;\n\njulia> W=BigWittVectorRing(ZZ,10)\nBig Witt vector ring represented up to degree 10 over Integers\n\njulia> w=one(W)\nBigInt[1, 0, 0, 0, 0, 0, 0, 0, 0, 0]\n\njulia> x=W(2)*w\nBigInt[2, 0, 0, 0, 0, 0, 0, 0, 0, 0]\n\njulia> y=2*w\nBigInt[2, -1, -2, -4, -6, -12, -18, -40, -54, -120]\n\njulia> x==w+w\nfalse\n\njulia> y==w+w\ntrue\n\njulia> z=w*2\nBigInt[2, -1, -2, -4, -6, -12, -18, -40, -54, -120]\n\njulia> z==w+w\ntrue\n\njulia> t=(-2)*w\nBigInt[-2, -3, 2, -9, 6, -4, 18, -93, 54, -72]\n\njulia> t + w + w == 0\ntrue\n\n\n\n\n\n","category":"function"},{"location":"#Exact-Division","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"Exact Division","text":"","category":"section"},{"location":"","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","text":"parent_type(::Type{WittVector{T}}) where T <: RingElement","category":"page"},{"location":"#AbstractAlgebra.parent_type-Union{Tuple{Type{WittVector{T}}}, Tuple{T}} where T<:RingElement","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"AbstractAlgebra.parent_type","text":"Data type and parent object methods\n\nparent_type(::Type{WittVector{T}}) where T <: RingElement\nelem_type (::Type{WittVector{T}}) where T <: RingElement\nbase_ring(R::BigWittRing)\nparent(R::WittVector)\nis_domain_type(::Type{WittVector{T}}) where T <: RingElement\nis_exact_type(::Type{WittVector{T}}) where T <: RingElement\nhash(w::WittVector, h::UInt)\ndeepcopy_internal(w::WittVector{T}, d::IdDict) where T <: RingElement\n\nStandard components of any conformant ring implementation in AbstractAlgebra.jl. See the documentation there\n\n\n\n\n\n","category":"method"},{"location":"#Comparison","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"Comparison","text":"","category":"section"},{"location":"","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","text":"==","category":"page"},{"location":"#Base.:==","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"Base.:==","text":"function ==(w::TruncatedWittVector{T}, v::TruncatedWittVector{T}) where T<: RingElement\n\nReturn true if and only if w and v have the same parent and w[i]==v[i] for i ∈ w.truncationset (equivelently i ∈ v.truncationset). In general any TruncatedWittVector constructed normally will have zeros for those entries anyway, but in the event this property is somehow broken, that will be invisible to ==.\n\n\n\n\n\n","category":"function"},{"location":"#Truncation-Helpers","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"Truncation Helpers","text":"","category":"section"},{"location":"","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","text":"truncationbools\ntruncationlist\ndivisor_stabilize\ntruncate","category":"page"},{"location":"#WittVectors.truncationbools","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.truncationbools","text":"function truncationbools(X::Vector{Int},n::Int)\n\nReturn vector of booleans corresponding to a truncationset given as a Vector, Array or Matrix of integers. Unexpected results may occur if supplied a matrix with both dimensions exceeding 1. The second argument n specifies the length of the returned vector. n should exceed the largest member of X, will throw an index error otherwise. \n\n\n\n\n\nfunction truncationbools(X)\n\nAlias for trunationbools(X,n) where n is the maximal member of X.\n\n\n\n\n\n","category":"function"},{"location":"#WittVectors.truncationlist","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.truncationlist","text":"function truncationlist(S::Vector{Bool})\n\nReturn a list of integers representing the truncationset given its representation as a boolean vector.\n\n\n\n\n\n","category":"function"},{"location":"#WittVectors.divisor_stabilize","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.divisor_stabilize","text":"function divisor_stabilize(S::Vector{Bool})\n\nReturn a divisor-stable truncationset (as a Vector{Bool}) generated by its argument. For now a very slow and naive implementation, but hardly performance-critical.\n\nExample\n\njulia> using WittVectors;\n\njulia> using AbstractAlgebra;\n\njulia> S=zeros(Bool, 36);\n\njulia> S[36]=true\ntrue\n\njulia> S\n36-element Vector{Bool}:\n 0\n 0\n 0\n 0\n 0\n 0\n 0\n 0\n 0\n 0\n ⋮\n 0\n 0\n 0\n 0\n 0\n 0\n 0\n 0\n 1\n\njulia> divisor_stabilize(S)\n36-element Vector{Bool}:\n 1\n 1\n 1\n 1\n 0\n 1\n 0\n 0\n 1\n 0\n ⋮\n 0\n 0\n 0\n 0\n 0\n 0\n 0\n 0\n 1\n\n\n\n\n\n\n","category":"function"},{"location":"#Base.truncate","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"Base.truncate","text":"truncate(W::BigWittRing, S::Vector{Bool})\n\nReturn a TruncatedBigWittVectorRing W_new with W_new.untruncated being W, truncated by S.  \n\n\n\n\n\nfunction truncate(w::WittVector, S::Vector{Bool})\n\nReturn the image of w in the quotient map W(R)W_S(R). Parent object will be truncate(w.parent, S)\n\n\n\n\n\n","category":"function"},{"location":"","page":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","title":"WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets","text":"","category":"page"}]
}
