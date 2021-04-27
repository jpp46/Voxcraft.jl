using Voxcraft

mat_type = AddMaterial(RGBA=(255, 0, 0, 255))

AddVoxel(mat_type, 0, 0, 4)

WriteVXA("first_simulation")