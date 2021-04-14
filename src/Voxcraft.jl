module Voxcraft

export HeapSize, EnableSignals, DisableSignals, EnableCilia, DisableCilia, EnableExpansion, DisableExpansion,
    RecordStepSize, EnableRecordVoxel, DisableRecordVoxel, EnableRecordLink,
    DisableRecordLink, EnableCollision, EnableAttach, DisableAttach, DisableCollision,
    StickDistance, SafetyGuard, LinkDamping, CollisionDamping, SimTime, EnableGravity, DisableGravtiy, GravityAcc,
    EnableFloor, DisableFloor, EnableTemp, DisableTemp, BaseTemp, TempAmp, TempPeriod, LatticeDim, AddMaterial,
    AddVoxel, WriteVXA

heapSize = 1.0
HeapSize(v) = heapSize = v

enableSignals = 0
EnableSignals() = enableSignals = 1
DisableSignals() = enableSignals = 0

enableCilia = 0
EnableCilia() = enableCilia = 1
DisableCilia() = enableCilia = 0

enableExpansion = 0
EnableExpansion() = enableExpansion = 1
DisableExpansion() = enableExpansion = 0

recordStepSize = 100
RecordStepSize(v) = recordStepSize = v

enableRecordVoxel = 1
EnableRecordVoxel() = enableRecordVoxel = 1
DisableRecordVoxel() = enableRecordVoxel = 0

enableRecordLink = 0
EnableRecordLink() = enableRecordLink = 1
DisableRecordLink() = enableRecordLink = 0

enableCollisions = 0
EnableCollision() = enableCollisions = 1
DisableCollision() = enableCollisions = 0

enableAttach = 0
EnableAttach() = enableAttach = 1
DisableAttach() = enableAttach = 0

stickDistance = 10
StickDistance(v) = stickDistance = v

safteyGuard = 500
SafetyGuard(v) = safteyGuard = v

linkDamping = 1.0
LinkDamping(v) = linkDamping = v

collisionDamping = 0.8
CollisionDamping(v) = collisionDamping = v

simTime = 2
SimTime(v) = simTime = v

enableGravity = 1
EnableGravity() = enableGravity = 1
DisableGravtiy() = enableGravity = 0

gravity = -9.80665
GravityAcc(v) = gravtiy = v

enableFloor = 1
EnableFloor() = enableFloor = 1
DisableFloor() = DisableFloor = 0

enableTemp = 0
EnableTemp() = enableTemp = 1
DisableTemp() = enableTemp = 0

baseTemp = 0
BaseTemp(v) = baseTemp = v

tempAmp = 0
TempAmp(v) = tempAmp = v

tempPeriod = 0
TempPeriod(v) = tempPeriod = v

latticeDim = 0.01
LatticeDim(v) = latticeDim = v

id = 1
mats = []
function AddMaterial(;E=10000, RHO=1000, P=0.35, CTE=0, tempPhase=0, uStatic=1, uDynamic=0.8,
                      isSticky=0, isPaceMaker=0, paceMakerPeriod=1.0, hasCilia=0, isBreakable=0,
                      RGBA=(rand(1:255), rand(1:255), rand(1:255), 255)
                    )
    global id, mats
    r, g, b, a = RGBA./255
    mat =
"            <Material ID=\"$id\"> <!--Material ID -->
                <MatType>0</MatType> <!--Don't touch this -->
                <Name>$id</Name> <!--Material Name -->
                <Display> <!--RGBA color of material -->
                    <Red>$r</Red>
                    <Green>$g</Green>
                    <Blue>$b</Blue>
                    <Alpha>$a</Alpha>
                </Display>
                <Mechanical>
                    <Sticky>$isSticky</Sticky> <!--Is it sticky -->
                    <isPaceMaker>$isPaceMaker</isPaceMaker> <!--For signaling (this voxel will send out signals) -->
                    <PaceMakerPeriod>$paceMakerPeriod</PaceMakerPeriod> <!--How often it signals -->
                    <Cilia>$hasCilia</Cilia> <!--Does it have cilia -->
                    <MatModel>$isBreakable</MatModel> <!--0 for simple spring, 1 for-->
                    <Elastic_Mod>$E</Elastic_Mod> <!--How stiff the material is -->
                    <Plastic_Mod>0</Plastic_Mod>
                    <Yield_Stress>0</Yield_Stress>
                    <FailModel>0</FailModel>
                    <Fail_Stress>0</Fail_Stress>
                    <Fail_Strain>0</Fail_Strain>
                    <Density>$RHO</Density> <!--How dense the material is -->
                    <Poissons_Ratio>$P</Poissons_Ratio> <!--Poission ratio -->
                    <CTE>$CTE</CTE> <!--Coeffecient of thermal expansion -->
                    <MaterialTempPhase>$tempPhase</MaterialTempPhase> <!--Phase offset for temperature -->
                    <uStatic>$uStatic</uStatic> <!--Static friction -->
                    <uDynamic>$uDynamic</uDynamic> <!--Dynamic Friction -->
                </Mechanical>
            </Material>"
    push!(mats, mat)
    id += 1
    return id-1
end

voxels = Dict()
function AddVoxel(mat_id, x, y, z)
    global voxels
    if x < 0 || y < 0 || z < 0
        @error "Indicies must be positive number!\n voxel at x=$x, y=$y, z=$z not added!"
    end
    if mat_id in keys(voxels)
        voxels[mat_id] = hcat(voxels[mat_id], [x, y, z])
    else
        voxels[mat_id] = [x, y, z]
    end
end


function WriteVXA(folder)
    global heapSize, enableSignals, enableCilia, enableExpansion, enableCilia, recordStepSize,
        enableRecordVoxel, enableRecordLink, enableCilia, enableCollisions, enableAttach, stickDistance, safteyGuard,
        linkDamping, collisionDamping, simTime, enableGravity, gravity, enableFloor, enableTemp, baseTemp,
        tempAmp, tempPeriod, latticeDim, id, mats, voxels
    vxa =
"<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>
<VXA Version=\"1.1\">
    <Simulator>
        <EnableSignals>$enableSignals</EnableSignals> <!--Voxels send signals to each other, set this to 0 -->
        <EnableCilia>$enableCilia</EnableCilia> <!--Applies external forces simulating cilia -->
        <EnableExpansion>$enableExpansion</EnableExpansion> <!--0 only contraction, 1 is contration + expansion -->
        <EnableTargetCloseness>0</EnableTargetCloseness> <!--Just leave as 0 -->
        <FitnessFunction> <!--Displacement from center -->
            <mtSQRT>
                <mtADD>
                    <mtMUL>
                        <mtVAR>x</mtVAR>
                        <mtVAR>x</mtVAR>
                    </mtMUL>
                    <mtMUL>
                        <mtVAR>y</mtVAR>
                        <mtVAR>y</mtVAR>
                    </mtMUL>
                </mtADD>
            </mtSQRT>
        </FitnessFunction>
        <RecordHistory>
            <RecordStepSize>$recordStepSize</RecordStepSize> <!--Capture image every 100 time steps -->
            <RecordVoxel>$enableRecordVoxel</RecordVoxel> <!--Add voxels to the visualization -->
            <RecordLink>$enableRecordLink</RecordLink> <!--Add links to the visualization -->
        </RecordHistory>
        <AttachDetach>
            <EnableCollision>$enableCollisions</EnableCollision> <!--Enable Voxel-Voxel collisions -->
            <EnableAttach>$enableAttach</EnableAttach> <!--Enable Sticky Voxels -->
            <watchDistance>$stickDistance</watchDistance> <!--How close voxels need to be to stick -->
            <SafetyGuard>$safteyGuard</SafetyGuard> <!--Makes things stable don't lower, increase if explodes -->
            <AttachCondition> <!--Always attach -->
                <Condition_0>
                    <mtCONST>1</mtCONST>
                </Condition_0>
            </AttachCondition>
        </AttachDetach>
        <Integration> <!--Choose integrator and fraction of optimal time step -->
            <Integrator>0</Integrator>
            <DtFrac>0.9</DtFrac>
        </Integration>
        <Damping>
            <BondDampingZ>$linkDamping</BondDampingZ> <!--Damping on voxel-voxel links -->
            <ColDampingZ>$collisionDamping</ColDampingZ> <!--Damping on voxel-voxel collisions and voxel-floor collisions -->
            <SlowDampingZ>0.01</SlowDampingZ> <!--Global damping on all movement -->
        </Damping>
        <ForceField> <!--Increase 0 times time -->
            <z_forcefield>
                <mtMUL>
                    <mtCONST>0.0</mtCONST>
                    <mtVAR>t</mtVAR>
                </mtMUL>
            </z_forcefield>
        </ForceField>
        <StopCondition> <!--Simulate for $simTime seconds (when this formula hits zero, STOP!) -->
            <StopConditionFormula>
                <mtSUB>
                    <mtVAR>t</mtVAR>
                    <mtCONST>$simTime</mtCONST>
                </mtSUB>
            </StopConditionFormula>
        </StopCondition>
    </Simulator>
    <Environment>
        <Gravity>
            <GravEnabled>$enableGravity</GravEnabled> <!--Is there gravity -->
            <GravAcc>$gravity</GravAcc> <!--Gravitational Accleration -->
            <FloorEnabled>$enableFloor</FloorEnabled> <!--Is there a floor -->
        </Gravity>
        <Thermal>
            <TempEnabled>$enableTemp</TempEnabled> <!--Does the tempurature vary -->
            <TempAmplitude>$tempAmp</TempAmplitude> <!--How much expansion and contration -->
            <TempBase>$baseTemp</TempBase> <!--Base Temperture -->
            <VaryTempEnabled>$enableTemp</VaryTempEnabled> <!--Temperature varies over time -->
            <TempPeriod>$tempPeriod</TempPeriod> <!--Expansion and contraction speed -->
        </Thermal>
    </Environment>
    <VXC Version=\"0.94\">
        <Lattice>
            <Lattice_Dim>$latticeDim</Lattice_Dim> <!--Lattice dimension in meters -->
            <X_Dim_Adj>1</X_Dim_Adj>
            <Y_Dim_Adj>1</Y_Dim_Adj>
            <Z_Dim_Adj>1</Z_Dim_Adj>
            <X_Line_Offset>0</X_Line_Offset>
            <Y_Line_Offset>0</Y_Line_Offset>
            <X_Layer_Offset>0</X_Layer_Offset>
            <Y_Layer_Offset>0</Y_Layer_Offset>
        </Lattice>
        <Voxel>
            <Vox_Name>BOX</Vox_Name>
            <X_Squeeze>1</X_Squeeze>
            <Y_Squeeze>1</Y_Squeeze>
            <Z_Squeeze>1</Z_Squeeze>
        </Voxel>
        <Palette>"
    for mat in mats
        vxa = vxa * "\n" * mat
    end
    vxa = vxa * "\n"

    maxx, maxy, maxz = typemin(Int), typemin(Int), typemin(Int)
    for (k, m) in voxels
        x = maximum(m[1, :])
        maxx = x > maxx ? x : maxx

        y = maximum(m[2, :])
        maxy = y > maxy ? y : maxy

        z = maximum(m[3, :])
        maxz = z > maxz ? z : maxz
    end
    x_voxels = length(0:maxx)
    y_voxels = length(0:maxy)
    z_voxels = length(0:maxz)

    #=x_offset = 0
    y_offset = 0
    z_offset = 0    
    if minx <= 0
        x_offset = length(minx:0)
    else
        x_offset = -(length(1:minx)-1)
    end
    if miny <= 0
        y_offset = length(miny:0)
    else
        y_offset = -(length(1:miny)-1)
    end
    if minz <= 0
        z_offset = length(minz:0)
    else
        z_offset = -(length(1:minz)-1)
    end=#

    mat = zeros(Int, x_voxels, y_voxels, z_voxels)
    for (k, m) in voxels
        for i in 1:size(m)[2]
            mat[m[1, i]+1, m[2, i]+1, m[3, i]+1] = k
        end
    end

    data = "<Data>"
    for i in 1:size(mat)[3]
        data = data * "\n" * "\t\t\t\t<Layer><![CDATA$(replace(string(mat[:, :, i][:]), ", " => ""))]></Layer>"
    end
    data = data * "\n" * "\t\t\t</Data>"



    vxa = vxa *
"        </Palette>
        <Structure Compression=\"ASCII_READABLE\">
            <X_Voxels>$x_voxels</X_Voxels>
            <Y_Voxels>$y_voxels</Y_Voxels>
            <Z_Voxels>$z_voxels</Z_Voxels>
            $data
        </Structure>
    </VXC>
</VXA>"

    open("$folder/base.vxa", "w") do io
        write(io, vxa)
    end
    open("$folder/robot.vxd", "w") do io
        write(io, "<VXD></VXD>")
    end
end

end # module