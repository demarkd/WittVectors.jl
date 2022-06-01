# WittVectors.jl: An implementation of big Witt vectors supporting truncation over arbitrary divisor-stable sets

## Parent and child objects and constructors

```@docs
BigWittRing
WittVector
BigWittVectorRing
TruncatedBigWitRing
TruncatedWittVector
TruncatedBigWittVectorRing
pTypicalWittVectorRing
```

## Data type and parent object methods
```@docs
parent_type
```

## Basic Manipulation
```@docs
zero
isconstant
is_unit
```
## Binary Operations
```@docs
*
```

## Exact Division
```@docs
divexact
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
