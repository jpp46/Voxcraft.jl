using Voxcraft

# create 3 materials
rmat = AddMaterial(E=10000, RGBA=(255, 0, 0, 255))
gmat = AddMaterial(E=20000, RGBA=(0, 255, 0, 255))
bmat = AddMaterial(E=30000, RGBA=(0, 0, 255, 255))

# red beam in positive x direction
AddVoxel(rmat, 1, 0, 0)
AddVoxel(rmat, 2, 0, 0)
AddVoxel(rmat, 3, 0, 0)
AddVoxel(rmat, 4, 0, 0)

# green beam in positive y direction
AddVoxel(gmat, 0, 1, 0)
AddVoxel(gmat, 0, 2, 0)
AddVoxel(gmat, 0, 3, 0)
AddVoxel(gmat, 0, 4, 0)

# blue beam in positive z direction
AddVoxel(bmat, 0, 0, 0)
AddVoxel(bmat, 0, 0, 1)
AddVoxel(bmat, 0, 0, 2)
AddVoxel(bmat, 0, 0, 3)

WriteVXA("sample1")