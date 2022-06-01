push!(LOAD_PATH,"/home/ddm/code/julia/WittVectors/src")
using Documenter, WittVectors, AbstractAlgebra
DocMeta.setdocmeta!(WittVectors, :DocTestSetup, :(using WittVectors; using AbstractAlgebra); recursive = true)

makedocs(
	 modules = [WittVectors],
	 sitename="WittVectors.jl Documentation")
deploydocs(repo = "github.com/demarkd/WittVectors.jl.git",
)