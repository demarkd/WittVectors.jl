#using Memoization
function vee(p,n)#auxillary funciton to divisors--consider branching to another file for this
        q = p

        while mod(n,q) == 0
                q=q^2
        end

        q = floor(Int64, √q)
        return q<p ? p : q * vee(p,n÷q)

end

function divisors(n)
	#I somewhat doubt this is the most performant implementation we could have--taken from a stackexchange answer (TODO cite that)
	dsieve, psieve = fill(true, n), fill(true, n) #parallel assignment
        psieve[1] = false

        @inbounds Threads.@threads for i ∈ eachindex(psieve)
                if psieve[i] && dsieve[i]
                        #i.e. if both are true--remove non primes
                        for j = i^2:i:n
                                psieve[j]=false #remove nonprimes from prime sieve
                        end

                        vp = vee(i,n)
                        for j = vp:vp:n
                                dsieve[j] = false
                        end
                end
        end
        dlist = [k for k in 1:n if dsieve[k]]
        return dlist #reshape(dlist,1,size(dlist)[1])
end

function properdivisors(n)
	#I somewhat doubt this is the most performant implementation we could have--taken from a stackexchange answer (TODO cite that)
	dsieve, psieve = fill(true, n-1), fill(true, n-1) #parallel assignment
        psieve[1] = false

        @inbounds Threads.@threads for i ∈ eachindex(psieve)
                if psieve[i] && dsieve[i]
                        #i.e. if both are true--remove non primes
			for j = i^2:i:(n-1)
                                psieve[j]=false #remove nonprimes from prime sieve
                        end

                        vp = vee(i,n)
			for j = vp:vp:(n-1)
                                dsieve[j] = false
                        end
                end
        end
	dlist = [k for k in 1:(n-1) if dsieve[k]]
        return dlist #reshape(dlist,1,size(dlist)[1])
end

checkdivs(n)=push!(properdivisors(n),n)==divisors(n)

function ghostpoly1(x::Vector,n=length(x))
	if n<0 return "error" end
	if n==0 return x[1] end
	divs=divisors(n)
	return sum(d*(x[d]^(n÷d)) for d in divs)
end

function ghostpoly(X::Vector{TT}, n::Integer)::TT where TT<: RingElement
        return sum(d*X[d]^(n÷d) for d in 1:n if n%d==0)
end


function ghostmap(w::WittVector{TT}, n::Integer)::TT where TT<: RingElement
	return ghostpoly(w.xcoords, n)
end
function ghostmap(w::TruncatedWittVector{TT}, n)::TT where TT <: RingElement
	return ghostpoly(w.xcoords, n)
end

