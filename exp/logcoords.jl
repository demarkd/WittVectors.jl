using WittVectors, Nemo
function logcoords(n::Int64)
	vars=["Z$i" for i in 1:n]
	varst= tuple(vars[i] for i in 1:n)
	return varst
	#open("unilogs.txt") do r
end
