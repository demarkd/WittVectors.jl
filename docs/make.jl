push!(LOAD_PATH,"/home/ddm/code/julia/WittVectors/src")
using Documenter, WittVectors, AbstractAlgebra
DocMeta.setdocmeta!(WittVectors, :DocTestSetup, :(using WittVectors, AbstractAlgebra;); recursive = true)

makedocs(
    format = Documenter.HTML(),
    modules = [WittVectors],
    sitename="WittVectors.jl",
    pages = [
	     "index.md",
	     "fulldocs.md",
	     ],
)
deploydocs(repo = "github.com/demarkd/WittVectors.jl.git",
	   target = "build",
)
