using Voxcraft

stiff = AddMaterial(E=2000000, RHO=20000, RGBA=(255, 0, 0, 255))
soft = AddMaterial(E=10000, RGBA=(0, 255, 0, 255))
softer = AddMaterial(E=1000, RGBA=(0, 255, 0, 255))

#cross base
x = 1
AddVoxel(stiff, x, 1, 0)
AddVoxel(stiff, x+1, 1, 0)
AddVoxel(stiff, x-1, 1, 0)
AddVoxel(stiff, x, 2, 0)
AddVoxel(stiff, x, 0, 0)

#add post
for z in 1:5
	AddVoxel(stiff, x, 1, z)
end

#cross base
x = 11
AddVoxel(stiff, x, 1, 0)
AddVoxel(stiff, x+1, 1, 0)
AddVoxel(stiff, x-1, 1, 0)
AddVoxel(stiff, x, 2, 0)
AddVoxel(stiff, x, 0, 0)

#add post
for z in 1:5
	AddVoxel(stiff, x, 1, z)
end

#add beam
for x in 2:10
	AddVoxel(softer, x, 1, 5)
end

WriteVXA("materials")




