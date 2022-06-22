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
	#this may or may not be directly useful to the implementation but if not should definitely be so for testing
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

	#dic= Dict([]) #not sure why we would need this...
#=	wn = 0
	for d in divs
	#	if n%d!=0 return "wtf" end #sanity check
		wn = wn + d * (x[d+1]^(n ÷ d))
	end
	return wn
end=#
#global sumCache=Dict()
#=@memoize function wittsum(n,v,w)
	#see previous comment. this may need to be reworked if we indeed change the approach.
	#this can definitely be optimized, particularly in the recursion-- perhaps by using a dictionary to cache. right now we are computing it repeatedly, I think. Question there is whether to parametrize... on the one hand, its probably cleaner, on the other hand the bookkeeping would be pretty bad here because we would need to make sure we are clearing the dictionary at the appropriate time. same issue with the global route, possibly correctible by a dictionary, indexed by (n,v,w)
	#this version now uses a global dictionary indeed. to my surprise, this seems to slow down the computation the first time it's run, but it gets loads better the second time. probably still optimization that can be done... in particular I somewhat doubt using a global is the optimal way to do this.
	#oh and I think we are computing more of s than we need. can we just index s by divs(n)? what would that look like?
	#no of course not, the witt function is sensitive to indexing. BUT we can make all the inert entries 0, as by the list comprehension below. 
	#thing to look into next time: @memoize? (memoization.jl)--update: this is definitely faster than a global dictionary
	#if haskey(sumCache,(n,v,w)) return sumCache[(n,v,w)] end
	if n==0  return 0 end
	if n ==1 return v[2]+w[2] end
	s=vcat([0],vcat([n%j==0 ? wittsum(j,v,w) : 0 for j ∈ 1:n-1],[0]))
	#println(s)
	println("computing sum of $v and $w up to $n")
	ws= (-witt(n,s)+(witt(n,v)+witt(n,w)))/n
	#sumCache[(n,v,w)]=ws
	return ws
end#remember when adapting from sage that indices need to be shifted by 1....
=#
