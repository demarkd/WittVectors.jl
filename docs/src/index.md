# Overview
## Installation
These installation instructions assume a \*nix-family operating system with Git and Julia 1.7.x or later already installed. To install Julia, follow the distribution-specific instructions [here.](https://julialang.org/downloads/) For Windows users, first format your primary storage device and install a \*nix-family operating system before returning to these instructions.

To install WittVectors.jl and use it in the REPL, clone this git repository to a local directory on your machine. Then, open Julia from the root of that directory. 
```
$ git clone https://github.com/demarkd/WittVectors.jl
Cloning into 'WittVectors.jl'...
remote: Enumerating objects: 1175, done.
remote: Counting objects: 100% (272/272), done.
remote: Compressing objects: 100% (147/147), done.
remote: Total 1175 (delta 112), reused 235 (delta 84), pack-reused 903
Receiving objects: 100% (1175/1175), 301.22 KiB | 929.00 KiB/s, done.
Resolving deltas: 100% (492/492), done.
$ cd WittVectors.jl
WittVectors.jl$ julia
               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.7.3 (2022-05-06)
 _/ |\\__'_|_|_|\\__'_|  |  Official https://julialang.org/ release
|__/                   |

julia>
```
From there go into Pkg mode by hitting `]` on your keyboard. The prompt should change to one indicating you are using Pkg. There, activate the current directory's project with `activate .` after which the prompt should change to indicate the current project is WittVectors. Next, instantiate it to install the required dependencies with `instantiate`. You can optionally precompile those packages with `precompile`--otherwise packages will precompile as you load them. If you choose to precompile now, this may take longer or shorter depending on whether you have already locally installed the packages in question. Once you are done setting up the project, enter `<backspace>` to an empty `pkg>` prompt to return to your main Julia session. You can then make the exported contents of `WittVectors.jl` available with the Julia command `using WittVectors.jl`. If you'd like to keep your namespace clean, you may instead `import WittVectors.jl`, which imports the exported names as `WittVectors.<name>`.
```
#press the ] key
(@v1.7) pkg> activate .
  Activating project at `~/WittVectors.jl`

(WittVectors) pkg> instantiate
    Updating registry at `~/.julia/registries/General.toml`
    Updating `~/WittVectors.jl/Project.toml`
  [c3fe647b] + AbstractAlgebra v0.26.0
  [e30172f5] + Documenter v0.27.18
  [27ebfcd6] + Primes v0.5.2
  [fb686558] + RandomExtensions v0.4.3
  [295af30f] + Revise v3.3.3
    Updating `~/WittVectors.jl/Manifest.toml`
  [a4c015fc] + ANSIColoredPrinters v0.0.1
  [c3fe647b] + AbstractAlgebra v0.26.0
  [da1fd8a2] + CodeTracking v1.0.9
  [ffbed154] + DocStringExtensions v0.8.6
  [e30172f5] + Documenter v0.27.18
  [d5909c97] + GroupsCore v0.4.0
  [b5f81e59] + IOCapture v0.2.2
  [18e54dd8] + IntegerMathUtils v0.1.0
  [682c06a0] + JSON v0.21.3
  [aa1ae85d] + JuliaInterpreter v0.9.13
  [6f1432cf] + LoweredCodeUtils v2.2.2
  [1914dd2f] + MacroTools v0.5.9
  [bac558e1] + OrderedCollections v1.4.1
  [69de0a69] + Parsers v2.3.1
  [27ebfcd6] + Primes v0.5.2
  [fb686558] + RandomExtensions v0.4.3
  [ae029012] + Requires v1.3.0
  [295af30f] + Revise v3.3.3
  [0dad84c5] + ArgTools
  [56f22d72] + Artifacts
  [2a0f44e3] + Base64
  [ade2ca70] + Dates
  [8ba89e20] + Distributed
  [f43a241f] + Downloads
  [7b1f6079] + FileWatching
  [b77e0a4c] + InteractiveUtils
  [b27032c2] + LibCURL
  [76f85450] + LibGit2
  [8f399da3] + Libdl
  [37e2e46d] + LinearAlgebra
  [56ddb016] + Logging
  [d6f4376e] + Markdown
  [a63ad114] + Mmap
  [ca575930] + NetworkOptions
  [44cfe95a] + Pkg
  [de0858da] + Printf
  [3fa0cd96] + REPL
  [9a3f8284] + Random
  [ea8e919c] + SHA
  [9e88b42a] + Serialization
  [6462fe0b] + Sockets
  [2f01184e] + SparseArrays
  [fa267f1f] + TOML
  [a4e569a6] + Tar
  [8dfed614] + Test
  [cf7118a7] + UUIDs
  [4ec0a83e] + Unicode
  [e66e0078] + CompilerSupportLibraries_jll
  [deac9b47] + LibCURL_jll
  [29816b5a] + LibSSH2_jll
  [c8ffd9c3] + MbedTLS_jll
  [14a3606d] + MozillaCACerts_jll
  [4536629a] + OpenBLAS_jll
  [83775a58] + Zlib_jll
  [8e850b90] + libblastrampoline_jll
  [8e850ede] + nghttp2_jll
  [3f19e933] + p7zip_jll

(WittVectors) pkg> precompile
Precompiling project...
  1 dependency successfully precompiled in 2 seconds (24 already precompiled)

#now hit <backspace>
julia> using WittVectors
```
In order to use WittVectors.jl within another project, you will need to make its source directory visible to that project by adding it to the project's import path. In the repl, this can be done with `]add <path-to-WittVectors.jl>` (with the `]` indicating this should be run in Pkg mode). This changes your project's `Project.toml` so now, any time you activate that project in the REPL or by calling a julia evaluation from the command line, `using WittVectors` should behave as expected.

!!! info
    Installation will become substantially easier should I ever register WittVectors.jl in the Julia general registry.
## Normal Usage
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


