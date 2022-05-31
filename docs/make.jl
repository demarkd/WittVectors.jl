push!(LOAD_PATH,"/home/ddm/code/julia/WittVectors/src")
using Documenter, WittVectors, AbstractAlgebra

makedocs(
	 modules = [WittVectors],
	 sitename="WittVectors.jl Documentation")
