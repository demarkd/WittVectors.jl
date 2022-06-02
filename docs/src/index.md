# Quick Start Guide
WittVectors.jl is designed to be used with [AbstractAlgebra.jl](https://nemocas.github.io/AbstractAlgebra.jl/dev/). Any time you will be using WittVectors either in the REPL or your own Julia script, call it using `using AbstractAlgebra, WittVectors`, as the base rings you will need are provided by that package. An exception is if you are only using base rings provided properly by another package in the family of related projects, such as [Nemo.jl](http://nemocas.org/) or [Hecke.jl](https://github.com/thofma/Hecke.jl/), in which case you should load that package alongside WittVectors.jl.

## Parents and Children
Following the conventions and type structure of AbstractAlgebra.jl, WittVectors.jl Witt Vectors each "live inside" a parent object (which is not actually a set of objects so much as a container for compatibility data for their objects). WittVectors.jl provides two parent types, `BigWittRing` (which models the ring of Big Witt Vectors up to some user-supplied index) and `TruncatedBigWittRing` (which models the ring of Witt Vectors over a user-supplied truncation set) (n.b. the name of this object may soon change). There are three primary constructors for those parent objects: `BigWittVectorRing` creates a `BigWittRing` and `TruncatedBigWittVectorRing`, and `pTypicalBigWittVectorRing` both create a `TruncatedBigWittRing`.
### Example
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

```@raw html
<details>
<summary> More on parent objects </summary>

As demonstrated at the end of that example, [by default] parent objects are cached so that attempting to create a Witt vector ring isomorphic to an existing Witt vector ring does not create a duplicate. There are a few exceptions, at least for now. For one, `BigWittRing`s and `TruncatedBigWittRing`s are always unequal. In addition, [for now] `TruncatedBigWittRing` carries a `BigWittRing` as part of its data (the `untruncated` field). All of the exported constructors for `TrucnatedBigWittRing`s `W` ensure that `W.untruncated.prec` is the maximal member of its truncation set, but it's possible (a) that the previous statement is actually a lie in some edge case (which should be reported to the author(s) as a bug) or (b) to use an internal command to create a `TruncatedBigWittRing` not having this property (god knows why you would want to, swim at your own risk).
</details>

```
## Creating Witt Vectors

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

julia> f= W()
AbstractAlgebra.GFElem{Int64}[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

julia> f*e == f
true
```
### Truncating

We can quotient `WittVector`s to `TruncatedWittVector`s and `BigWittRing`s to ` using the `truncate` function.
### Example
```jldoctest
julia> using AbstractAlgebra, WittVectors;

julia> W= BigWittVectorRing(GF(5), 12)
Big Witt vector ring represented up to degree 12 over Finite field F_5

julia> W_S=TruncatedBigWittVectorRing(GF(5), [10])
Witt vector ring over Finite field F_5 truncated over the set [1, 2, 5, 10]

julia> w=W(1)*17
AbstractAlgebra.GFElem{Int64}[2, 4, 3, 1, 2, 3, 2, 0, 1, 0, 4, 4]

julia> w_S=W_S(1)*17
AbstractAlgebra.GFElem{Int64}[2, 4, 2, 0] truncated over [1, 2, 5, 10]

julia> S=W_S.truncationset
10-element Vector{Bool}:
 1
 1
 0
 0
 1
 0
 0
 0
 0
 1

julia> truncate(W,S)
Witt vector ring over Finite field F_5 truncated over the set [1, 2, 5, 10]

julia> truncate(w,S)
AbstractAlgebra.GFElem{Int64}[2, 4, 2, 0] truncated over [1, 2, 5, 10]

julia> truncate(W,S)==W_S
true

julia> truncate(w,S)==w_S
true
```
## Performance and Limitations
Well its a dang sure lot faster than my previous implementation of the p-Typical Witt Vectors in Sagemath last fall (which used the universal polynomial approach--bad idea).

More seriously, WittVectors.jl works about as quick as you could hope up to indices of somewhere in the low hundreds--from there it begins to get slow. More optimization is needed on some performance-critical algorithms. Two places likely needing improvement are `WittVectors.getcoords`, which transforms an element in ``1+R[[T]]`` to its so-called Witt coordinates by inverting the formula [^Kedlaya] ``(x_0, x_1, \dots) \mapsto \prod (1-x_n T^n)``, and `WittVectors.multseries` which applies the formula [^Hazewinkel] ``\left(\prod (1-x_n T^n)\right)\otimes \left(\prod (1-y_n T^n)=\prod_{r,s} \left(1-x^{s/\mathrm{gcd}(r,s)}y^{r/\mathrm{gcd}(r,s)}t^{\mathrm{lcm}(r,s)}\right)^{-\mathrm{gcd}(r,s)}``.

[^Kedlaya]: Kiran S. Kedlaya, Notes on Prismatic Cohomology. [(Link to course notes)](https://kskedlaya.org/prismatic/sec_lambda-rings.html)
[^Hazewinkel]: Michiel Hazewinkel, Witt vectors. Part 1. Eqn (9.27). [(arXiv)](https://arxiv.org/abs/0804.3888)

Julia includes quite a bit of support for timing and profiling ones computations. We provide a few performance tests below. All tests performed on a Lenovo Thinkpad X1 Carbon 4th Generation, equipped with a quaad-core Intel i5-6300U @ 3.000GHz and 4GB of ram on a single thread.

## Using other parts of OSCAR with WittVectors.jl


