using WittVectors
using Documenter

DocMeta.setdocmeta!(WittVectors, :DocTestSetup, :(using WittVectors); recursive=true)

makedocs(;
    modules=[WittVectors],
    authors="David DeMark <demar180@umn.edu>",
    repo="https://github.com/demarkd/WittVectors.jl/blob/{commit}{path}#{line}",
    sitename="WittVectors.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://demarkd.github.io/WittVectors.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/demarkd/WittVectors.jl",
    devbranch="main",
)
