module Voxcraft

export HeapSize, EnableSignals, DisableSignals, EnableCilia, DisableCilia, EnableExpansion, DisableExpansion,
    RecordStepSize, EnableRecordVoxel, DisableRecordVoxel, EnableRecordLink,
    DisableRecordLink, EnableCollision, EnableAttach, DisableAttach, DisableCollision,
    StickDistance, SafetyGuard, LinkDamping, CollisionDamping, SimTime, EnableGravity, DisableGravtiy, GravityAcc,
    EnableFloor, DisableFloor, EnableTemp, DisableTemp, BaseTemp, TempAmp, TempPeriod, LatticeDim, AddMaterial,
    AddVoxel, WriteVXA

heapSize = 1.0
HeapSize(v) = global heapSize = v

enableSignals = 0
EnableSignals() = global enableSignals = 1
DisableSignals() = global enableSignals = 0

enableCilia = 0
EnableCilia() = global enableCilia = 1
DisableCilia() = global enableCilia = 0

enableExpansion = 1
EnableExpansion() = global enableExpansion = 1
DisableExpansion() = global enableExpansion = 0

recordStepSize = 100
RecordStepSize(v) = global recordStepSize = v

enableRecordVoxel = 1
EnableRecordVoxel() = global enableRecordVoxel = 1
DisableRecordVoxel() = global enableRecordVoxel = 0

enableRecordLink = 0
EnableRecordLink() = global enableRecordLink = 1
DisableRecordLink() = global enableRecordLink = 0

enableCollisions = 0
EnableCollision() = global enableCollisions = 1
DisableCollision() = global enableCollisions = 0

enableAttach = 0
EnableAttach() = global enableAttach = 1
DisableAttach() = global enableAttach = 0

stickDistance = 10
StickDistance(v) = global stickDistance = v

safteyGuard = 500
SafetyGuard(v) = global safteyGuard = v

linkDamping = 1.0
LinkDamping(v) = global linkDamping = v

collisionDamping = 0.8
CollisionDamping(v) = global collisionDamping = v

simTime = 2
SimTime(v) = global simTime = v

enableGravity = 1
EnableGravity() = global enableGravity = 1
DisableGravtiy() = global enableGravity = 0

gravity = -9.80665
GravityAcc(v) = global gravtiy = v

enableFloor = 1
EnableFloor() = global enableFloor = 1
DisableFloor() = global DisableFloor = 0

enableTemp = 0
EnableTemp() = global enableTemp = 1
DisableTemp() = global enableTemp = 0

baseTemp = 0
BaseTemp(v) = global baseTemp = v

tempAmp = 0
TempAmp(v) = global tempAmp = v

tempPeriod = 0
TempPeriod(v) = global tempPeriod = v

latticeDim = 0.01
LatticeDim(v) = global latticeDim = v

id = 1
mats = []
matPhase = Dict()
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
    matPhase[id] = tempPhase
    id += 1
    return id-1
end

voxels = Dict()
function AddVoxel(mat_id, x, y, z)
    global voxels
    if x < 0 || y < 0 || z < 0
        @error "Indicies must be positive number!\n voxel at x=$x, y=$y, z=$z not added!"
    end
    voxels[(x, y, z)] = mat_id
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

    xs = []; ys= []; zs = [];
    for (idx, id) in voxels
        push!(xs, idx[1])
        push!(ys, idx[2])
        push!(zs, idx[3])
    end
    x_voxels = length(0:maximum(xs))
    y_voxels = length(0:maximum(ys))
    z_voxels = length(0:maximum(zs))

    global voxels = Dict()

    mat = zeros(Int, x_voxels, y_voxels, z_voxels)
    phase = zeros(Float64, x_voxels, y_voxels, z_voxels)
    for (idx, id) in voxels
        mat[idx[1]+1, idx[2]+1, idx[3]+1] = id
        phase[idx[1]+1, idx[2]+1, idx[3]+1] = matPhase[id]
    end

    data = "<Data>"
    for i in 1:size(mat)[3]
        data = data * "\n" * "\t\t\t\t<Layer><![CDATA$(replace(string(mat[:, :, i][:]), ", " => ""))]></Layer>"
    end
    data = data * "\n" * "\t\t\t</Data>"

    phaseOffset = "<PhaseOffset>"
    for i in 1:size(mat)[3]
        phaseOffset = phaseOffset * "\n" * "\t\t\t\t<Layer><![CDATA$(replace(string(phase[:, :, i][:]), ", " => ","))]></Layer>"
    end
    phaseOffset = phaseOffset * "\n" * "\t\t\t</PhaseOffset>"

    vxa = vxa *
"        </Palette>
        <Structure Compression=\"ASCII_READABLE\">
            <X_Voxels>$x_voxels</X_Voxels>
            <Y_Voxels>$y_voxels</Y_Voxels>
            <Z_Voxels>$z_voxels</Z_Voxels>
            $data
            $phaseOffset
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