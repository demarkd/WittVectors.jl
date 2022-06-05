#include("wittpolys.jl")
function test_Witt_interface(W::BigWittRing; reps = 50)
    T=elem_type(W)
    @testset "Witt interface for $(W) of type $(typeof(W))"begin
        for i in 1:reps
            a=test_elem(W)
            b=test_elem(W)
            for j in 1:W.prec
                @test ghostmap(a,j)*ghostmap(b,j)==ghostmap(a*b,j)
		@test ghostmap(a,j)+ghostmap(b,j)==ghostmap(a+b,j)
            end
        end
    end
    return nothing
end

function test_Witt_interface(W::TruncatedBigWittRing; reps = 50)
    T=elem_type(W)
    @testset "Witt interface for $(W) of type $(typeof(W))" begin
        for i in 1:reps
            a=test_elem(W)
            b=test_elem(W)
            for j in WittVectors.truncationlist(W.truncationset)
                @test ghostmap(a,j)*ghostmap(b,j)==ghostmap(a*b,j)
		@test ghostmap(a,j)+ghostmap(b,j)==ghostmap(a+b,j)
            end
        end
    end
    return nothing
end
