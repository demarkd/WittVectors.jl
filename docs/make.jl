push!(LOAD_PATH,"/home/ddm/code/julia/WittVectors/src")
using Documenter, WittVectors

makedocs(
	 modules = [WittVectors],
	 sitename="WittVectors.jl Documentation")
deploydocs(repo = "github.com/demarkd/WittVectors.jl.git",
)
