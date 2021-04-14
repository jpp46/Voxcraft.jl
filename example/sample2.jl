using Voxcraft

# create red material
rmat = AddMaterial(E=10000, RGBA=(255, 0, 0, 255))

# set a red voxel 3 voxels high in air
AddVoxel(rmat, 0, 0, 3)
WriteVXA("sample2")