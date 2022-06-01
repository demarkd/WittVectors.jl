# WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets

## Parent and child objects and constructors

```@docs
BigWittRing
WittVector
BigWittVectorRing
TruncatedBigWittRing
TruncatedWittVector
TruncatedBigWittVectorRing
pTypicalWittVectorRing
```

## Data type and parent object methods
```@docs
AbstractAlgebra.parent_type :: Union{Tuple{Type{WittVector{T}}}, Tuple{T}} where T<:AbstractAlgebra.RingElement
```

## Basic Manipulation
```@docs
zero
isconstant
AbstractAlgebra.is_unit :: Tuple{WittVector}
```
## Binary Operations
```@docs
*
```

## Exact Division
```@docs
AbstractAlgebra.divexact :: Union{Tuple{T}, Tuple{WittVector{T}, WittVector{T}}} where T<:AbstractAlgebra.RingElement
```

## Comparison
```@docs
==
```

## Truncation Helpers
```@docs
truncationbools
truncationlist
divisor_stabilize
truncate
```
