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

julia>

```

