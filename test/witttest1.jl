using Test
include(joinpath(pathof(AbstractAlgebra), "..", "..", "test", "Rings-conformance-tests.jl"))

S =QQ 

function test_elem(W::BigWittRing{elem_type(S)})
   return W(rand(base_ring(W),  -999:999))
end

test_Ring_interface(BigWittVectorRing(S,8))
