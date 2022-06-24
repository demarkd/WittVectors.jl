using Test
#include(joinpath(pathof(AbstractAlgebra), "..", "..", "test", "Rings-conformance-tests.jl"))
include("Witt-rings-conformance-tests.jl")
S1 =ZZ
S2=GF(7)

function test_elem(W::BigWittRing{elem_type(S1)})
	return rand(W, -999:999)
end
function test_elem(W::BigWittRing{elem_type(S2)})
	return rand(W)
end
test_Witt_interface(BigWittVectorRing(S1,11))
test_Witt_interface(BigWittVectorRing(S2,11))
test_Witt_interface(BigWittVectorRing(S1,11,method=:ghost))
#test_Witt_interface(BigWittVectorRing(S2,11))
test_Witt_interface(BigWittVectorRing(S1,11,method=:series))
test_Witt_interface(BigWittVectorRing(S2,11,method=:series))
