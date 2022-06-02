using Test
#include(joinpath(pathof(AbstractAlgebra), "..", "..", "test", "Rings-conformance-tests.jl"))
include("Witt-rings-conformance-tests.jl")
S1 =QQ
S2 =GF(7)

function test_elem(W::TruncatedBigWittRing{elem_type(S1)})
	return rand(W,-999:999)
end
function test_elem(W::TruncatedBigWittRing{elem_type(S2)})
	return rand(W)
end
test_Witt_interface(TruncatedBigWittVectorRing(S1,[true, true, false, false, false, false, false, true]))

test_Witt_interface(TruncatedBigWittVectorRing(S2,[true, true, false, false, false, false, false, true]))
