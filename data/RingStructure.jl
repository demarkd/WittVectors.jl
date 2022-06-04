using FileIO, JuliaDB, Nemo, WittVectors, DelimitedFiles, Primes
"""
	function findexponent(p::Integer, m::Integer, S::Vector{Integer})
Construct the ring ``W_S(\\mathbb{Z}/p^m)`` and compute ``N`` s.t. ``p^N W_S(\\mathbb{Z}/p^m)=0.
"""
function findexponent_verbose(p::Integer, m::Integer, S::Vector{Int64})
#p = 5; m = 6; S = [81,90];
    R=ResidueRing(ZZ, p^m);
    W=TruncatedBigWittVectorRing(R, S)
    w = W(1)*p; r = W(1); n = 0;
    #Sbools
    while r != 0;
           r*=w
           n+=1
           println("computing p^N in W_{S}(Z/p^m)=$W, p=$p, m=$m. N=$n, p^N=$r.")
    end
    return n
end
#=
function findexponent(p::Integer, m::Integer, S::Vector{Int64})
#p = 5; m = 6; S = [81,90];
    R=ResidueRing(ZZ, p^m);
    W=TruncatedBigWittVectorRing(R, S)
    w = W(1)*p; r = W(1); n = 0;
    while r != 0;
           r*=w
           n+=1
           #println("computing p^N in W_{S}(Z/p^m)=$W, p=$p, m=$m. N=$n, p^N=$r.")
    end
    return n
end
=#
stable_list(S::Vector{Int64})=truncationlist(divisor_stabilize(truncationbools(S)))
function findexponents_verbose(Ps::Vector{Int64}, Ms::Vector{Int64}, Ss=Vector{Vector{Int64}})
	Ns=findexponent_verbose.(Ps, Ms, Ss)
	Sbs=broadcast(stable_list,Ss)
	return table(Ps, Ms, Sbs, Ns, names = [:p, :m, :S, :N])
end
function logexponents_verbose(Ps::Vector{Int64}, Ms::Vector{Int64}, Ss=Vector{Vector{Int64}})
	t=JuliaDB.load("data/expdata")
	tnew=findexponents_verbose(Ps, Ms, Ss)
	tmerge=merge(t,tnew)
	tmerge_clean=table(unique!(rows(tmerge)))
	JuliaDB.save(tmerge_clean, "data/expdata")
	println("$(tnew)")
	return tnew
end
function view_expdata()
	t=JuliaDB.load("data/expdata")
	return t
end
function investigate_ptypical_verbose(p::Integer, mcap::Integer, degree::Integer)
	Ps=broadcast((x->p*x), vec(ones(Int64, mcap)))
	Ms=collect(1:mcap)
	Ss=fill([p^degree],mcap)
	return logexponents_verbose(Ps, Ms, Ss)
end
function make_coprime(a:: Integer, p:: Integer)
	fdic=factor(a)
	m=fdic[p]
	return a÷p^m
end
function investigate_random_2gen_verbose(p::Integer, mcap::Integer)
	Ps=broadcast((x->p*x), vec(ones(Int64, mcap)))
	Ms=collect(1:mcap)
	a=rand(1:999)
	b=rand(1:999)
	Ss=fill([a,b],mcap)
	return logexponents_verbose(Ps, Ms, Ss)
end
function investigate_random_2gen_coprime_verbose(p::Integer, mcap::Integer)
	Ps=broadcast((x->p*x), vec(ones(Int64, mcap)))
	Ms=collect(1:mcap)
	a=make_coprime(rand(1:999),p)
	b=make_coprime(rand(1:999),p)
	Ss=fill([a,b],mcap)
	return logexponents_verbose(Ps, Ms, Ss)
end
function investigate_many_random_2gen(pcap::Integer, mcap::Integer)
	for p in primes(pcap)
		investigate_random_2gen_verbose(p,mcap)
	end
	return view_expdata()
end

function investigate_many_coprime_2gen(pcap::Integer, mcap::Integer)
	for p in primes(pcap)
		investigate_random_2gen_coprime_verbose(p,mcap)
	end
	return view_expdata()
end
function investigate_many_for_single_prime(p::Integer,reps::Integer,mcap::Integer=1)
	for i in 1:reps
		investigate_random_2gen_coprime_verbose(p,mcap)
	end
	return view_expdata()
end
	
