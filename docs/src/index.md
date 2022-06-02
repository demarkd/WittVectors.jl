# WittVectors.jl: An implementation of Witt vectors over arbitrary truncation sets
<!--[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://demarkd.github.io/WittVectors.jl/stable)-->
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://demarkd.github.io/WittVectors.jl/dev)
[![Build Status](https://github.com/demarkd/WittVectors.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/demarkd/WittVectors.jl/actions/workflows/CI.yml?query=branch%3Amain)
## Quick Start Guide
WittVectors.jl is designed to be used with [AbstractAlgebra.jl](https://nemocas.github.io/AbstractAlgebra.jl/dev/). Any time you will be using WittVectors either in the REPL or your own Julia script, call it using `using AbstractAlgebra, WittVectors`, as the base rings you will need are provided by that package. An exception is if you are only using base rings provided properly by another package in the family of related projects, such as [Nemo.jl](http://nemocas.org/) or [Hecke.jl](https://github.com/thofma/Hecke.jl/), in which case you should load that package alongside WittVectors.jl.

### Parents and Children
Following the conventions and type structure of AbstractAlgebra.jl, WittVectors.jl Witt Vectors each "live inside" a parent object (which is not actually a set of objects so much as a container for compatibility data for their objects). WittVectors.jl provides two parent types, `BigWittRing` (which models the ring of Big Witt Vectors up to some user-supplied index) and `TruncatedBigWittRing` (which models the ring of Witt Vectors over a user-supplied truncation set) (n.b. the name of this object may soon change). There are three primary constructors for those parent objects: `BigWittVectorRing` creates a `BigWittRing` and `TruncatedBigWittVectorRing`, and `pTypicalBigWittVectorRing` both create a `TruncatedBigWittRing`.
#### Example
```jldoctest
julia> using WittVectors, AbstractAlgebra;

julia> W1= BigWittVectorRing(GF(7), 25)
Big Witt vector ring represented up to degree 25 over Finite field F_7

julia> typeof(W1)
BigWittRing{AbstractAlgebra.GFElem{Int64}}

julia> W2=TruncatedBigWittVectorRing(ZZ, [18, 25]) #Most convenient way to call this is with a list of generators for the truncation set
Witt vector ring over Integers truncated over the set [1, 2, 3, 5, 6, 9, 18, 25]

julia> typeof(W2)
TruncatedBigWittRing{BigInt}

julia> W3=pTypicalWittVectorRing(QQ, 3, 4)
Witt vector ring over Rationals truncated over the set [1, 3, 9, 27, 81]

julia> typeof(W3)
TruncatedBigWittRing{Rational{BigInt}}

julia> W4=TruncatedBigWittVectorRing(QQ, [3^4])
Witt vector ring over Rationals truncated over the set [1, 3, 9, 27, 81]

julia> W3==W4 #by default, calling a constructor twice for the same ring returns the same object-- even differing constructors for the same ring
true

```
<details>
<summary> More on parent objects </summary>

As demonstrated at the end of that example, [by default] parent objects are cached so that attempting to create a Witt vector ring isomorphic to an existing Witt vector ring does not create a duplicate. There are a few exceptions, at least for now. For one, `BigWittRing`s and `TruncatedBigWittRing`s are always unequal. In addition, [for now] `TruncatedBigWittRing` carries a `BigWittRing` as part of its data (the `untruncated` field). All of the exported constructors for `TrucnatedBigWittRing`s `W` ensure that `W.untruncated.prec` is the maximal member of its truncation set, but it's possible (a) that the previous statement is actually a lie in some edge case (which should be reported to the author(s) as a bug) or (b) to use an internal command to create a `TruncatedBigWittRing` not having this property (god knows why you would want to, swim at your own risk).
</details>

There are a few ways to create Witt vectors. For elements ``[c]`` of the set-theoretic constant lift ``R\to W(R)``, one can use `W(c)`. This is in contrast to other functorial constructions `F` provided by AbstractAlgebra.jl where for an integer `n`, `F(R)(n)` is the image of `n` in the composition of the structure map and a natural transformation ``\mathrm{id}\implies F``,  ``\mathbb{Z}\to R \to F(R)``. We do not have such a natural transformation at our disposal. Instead, we can the image of ``n\in\mathbb{Z}`` in the structure map ``\mathbb{Z}\to W(R)`` by calling ``n*W(1)``.
### Example
```jldoctest
julia> using WittVectors, AbstractAlgebra;

julia> W= BigWittVectorRing(GF(7), 10)
Big Witt vector ring represented up to degree 10 over Finite field F_7

julia> a=W(6)
AbstractAlgebra.GFElem{Int64}[6, 0, 0, 0, 0, 0, 0, 0, 0, 0]

julia> b=W(-2)
AbstractAlgebra.GFElem{Int64}[5, 0, 0, 0, 0, 0, 0, 0, 0, 0]

julia> c=6*W(1)
AbstractAlgebra.GFElem{Int64}[6, 6, 0, 6, 0, 0, 1, 6, 0, 0]

julia> d=W(1)*(-2)
AbstractAlgebra.GFElem{Int64}[5, 4, 2, 5, 6, 3, 4, 5, 5, 5]

julia> a*b==W(-12)
true

julia> a+b == W(4)
false

julia> c*d == (-12)*W(1)
true

julia> c+d == 4 *W(1)
true

julia> e=3* (a +c) #multiplying by integers works for more than just W(1)
AbstractAlgebra.GFElem{Int64}[1, 3, 0, 4, 0, 6, 2, 4, 0, 1]

julia> e== a+ a + a + c + c + c
true
```
