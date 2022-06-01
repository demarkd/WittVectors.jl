# WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets

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
divexact(w::WittVector{T}, v::WittVector{T}; check::Bool=true) where T <: RingElement
```

## Basic Manipulation
```@docs
zero
isconstant
is_unit(w::WittVector)
```
## Binary Operations
```@docs
*
```

## Exact Division
```@docs
parent_type(::Type{WittVector{T}}) where T <: RingElement
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

```@index
```
