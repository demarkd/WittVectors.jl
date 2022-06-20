using WittVectors, Nemo, Profile
W=pTypicalWittVectorRing(ZZ,3,5)
w=W([0,1,0,0,0,0])
x=w^9
Profile.clear_malloc_data()
x=w^9
