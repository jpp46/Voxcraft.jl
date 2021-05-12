using Voxcraft

SimTime(6)
EnableExpansion()
EnableTemp()
TempAmp(1)
TempPeriod(2)

passive = AddMaterial(E=10_000, RGBA=(0, 0, 255, 255))
structure = AddMaterial(E=100_000_000, RHO=10000, RGBA=(0, 255, 0, 255))
actuating = AddMaterial(E=1_000_000, CTE=0.5, tempPhase=0, RGBA=(255, 0, 0, 255))
actuating2 = AddMaterial(E=1_000_000, CTE=0.5, tempPhase=0.5, RGBA=(255, 0, 0, 255))

# Passive System
for x in 0:7
	for y in 0:7
		for z in 2:4
			AddVoxel(passive, x, y, z)
		end
	end
end

for x in [1, 6]
	for y in [1, 6]
		for z in 0:1
			AddVoxel(passive, x, y, z)
			AddVoxel(passive, x+1, y, z)
			AddVoxel(passive, x, y+1, z)
			AddVoxel(passive, x-1, y, z)
			AddVoxel(passive, x, y-1, z)
			AddVoxel(passive, x+1, y+1, z)
			AddVoxel(passive, x-1, y-1, z)
			AddVoxel(passive, x+1, y-1, z)
			AddVoxel(passive, x-1, y+1, z)
		end
	end
end

# Structural System
for z in 1:3
	AddVoxel(structure, 1, 1, z)
	AddVoxel(structure, 1, 6, z)
	AddVoxel(structure, 6, 1, z)
	AddVoxel(structure, 6, 6, z)
end

for x in 2:5
	AddVoxel(structure, x, 1, 3)
	AddVoxel(structure, x, 6, 3)
end

for y in 2:5
	AddVoxel(structure, 1, y, 3)
	AddVoxel(structure, 6, y, 3)
end

# Actuators
for x in 2:5
	AddVoxel(actuating, x, 0, 2)
	AddVoxel(actuating2, x, 0, 4)

	AddVoxel(actuating, x, 7, 2)
	AddVoxel(actuating2, x, 7, 4)
end

WriteVXA("actuation")




