# Full Documentation

```@meta
DocTestSetup = quote
	using AbstractAlgebra
	using WittVectors
end
```
```@contents
```
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
parent_type(::Type{WittVector{T}}) where T <: RingElement
project
ghostmap(w::WittVector, n)
```

## Basic Manipulation
```@docs
zero
WittVectors.isconstant
is_unit(w::WittVector)
```
## Binary Operations
```@docs
*
```

## Exact Division
```@docs
divexact(w::WittVector{T}, v::WittVector{T}; check::Bool=true) where T <: RingElement
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
truncationgens
```

```@index
```
