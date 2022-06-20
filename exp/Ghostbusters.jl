function divideby_leastprimedivisior(n::Integer)
	if n <= 1 return n end
	found::Bool=false
	i::Int64=0
	while found==false
		i=nextprime(i+1)
		#println("i=$i, n%i = $(n%i)")
		if n%i==0
			found = true
		end
	end
	return n ÷ i
end
function factorby_leastprimedivisor(n::Integer)
	if n <= 1 return n end
	found::Bool=false
	i::Int64=0
	while found==false
		i=nextprime(i+1)
		#println("i=$i, n%i = $(n%i)")
		if n%i==0
			found = true
		end
	end
	return i, n ÷ i
end
function check_factorby(n::Integer)
	i,np=factorby_leastprimedivisor(n)
	return n==i*np
end
