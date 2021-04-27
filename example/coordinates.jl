using Voxcraft

red_mat = AddMaterial(E=10000, RGBA=(255, 0, 0, 255))
green_mat = AddMaterial(E=10000, RGBA=(0, 255, 0, 255))
blue_mat = AddMaterial(E=10000, RGBA=(0, 0, 255, 255))

# red beam in x positive direction
AddVoxel(red_mat, 1, 0, 0)
AddVoxel(red_mat, 2, 0, 0)
AddVoxel(red_mat, 3, 0, 0)
AddVoxel(red_mat, 4, 0, 0)

# green beam in y positive direction
AddVoxel(green_mat, 0, 1, 0)
AddVoxel(green_mat, 0, 2, 0)
AddVoxel(green_mat, 0, 3, 0)
AddVoxel(green_mat, 0, 4, 0)

# blue beam in z positive direction
AddVoxel(blue_mat, 0, 0, 0)
AddVoxel(blue_mat, 0, 0, 1)
AddVoxel(blue_mat, 0, 0, 2)
AddVoxel(blue_mat, 0, 0, 3)

WriteVXA("coordinates")