include("voxcraft.jl")
using .Voxcraft

DisableGravtiy()
rmat = AddMaterial(E=10000, RGBA=(255, 0, 0, 255))
gmat = AddMaterial(E=20000, RGBA=(0, 255, 0, 255))
bmat = AddMaterial(E=30000, RGBA=(0, 0, 255, 255))

# red beam in positive x direction
AddVoxel(rmat, -1, -1, -1)
AddVoxel(rmat, 0, -1, -1)
AddVoxel(rmat, 1, -1, -1)
AddVoxel(rmat, 2, -1, -1)

# green beam in positive y direction
AddVoxel(gmat, -1, -1, 0)
AddVoxel(gmat, -1, 0, 0)
AddVoxel(gmat, -1, 1, 0)
AddVoxel(gmat, -1, 2, 0)

# blue beam in positive z direction
AddVoxel(bmat, -1, -1, 1)
AddVoxel(bmat, -1, -1, 2)
AddVoxel(bmat, -1, -1, 3)
AddVoxel(bmat, -1, -1, 4)

WriteVXA("test")