using Test
#include(joinpath(pathof(AbstractAlgebra), "..", "..", "test", "Rings-conformance-tests.jl"))
include("Witt-rings-conformance-tests.jl")
S =ZZ 

function test_elem(W::BigWittRing{elem_type(S)})
   return W(rand(base_ring(W),  -999:999))
end

test_Witt_interface(BigWittVectorRing(S,11))
