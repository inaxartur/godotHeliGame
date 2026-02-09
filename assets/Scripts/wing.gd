extends Node3D

# Relative wind
# Induced flow
# Resultant Relative Wind

const PIdivby30 := 0.10471975512

@export var heliNode : RigidBody3D
@export var bladeLength := 5.335 # METERS
var bladeLengthFeet := bladeLength * 3.2808
@export var bladeWidth := 0.273 # METERS
@export var liftCoefCurve : Curve
@export var thrustCoefCurve : Curve
var airDensity := 1.225

var thrust : float

var liftForce : float = 0.0
var heliPathVec : Vector3 = Vector3.ZERO
var heliSpeed : float = 0.0
var heliClimbRate : float = 0.0
var bladeArea = bladeLength * bladeWidth # METERS^2
var rotorArea = pow(bladeLength, 2) * PI
var solidity = (bladeArea * 4) / rotorArea
var advanceRatio : float = 0.0
var KTAS : float

var inducedVelocity : float
var inflowVelocity : float
var netDownFlowSpeed : float
var inflowRatio : float

var yawAxis : Vector3 = Vector3.ZERO
var pitchAxis : Vector3 = Vector3.ZERO
var rollAxis : Vector3 = Vector3.ZERO

var globalRollAxis : Vector3 = Vector3.BACK
var heliPitch : float

var bladePitch : float
var aoa : float
var liftCoef : float
var thrustCoef : float
var rpm : float
var bladeSpeed : float
var debugIter := 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	yawAxis = global_transform.basis.y
	pitchAxis = global_transform.basis.x
	rollAxis = global_transform.basis.z
	
	heliPitch = heliNode.heliPitch
	heliPathVec = heliNode.pathVector
	heliClimbRate = heliNode.rateOfClimb.length()
	heliSpeed = heliPathVec.length() / delta
	rpm = heliNode.rpm
	
	bladeSpeed = (rpm * PIdivby30 * bladeLength)
	KTAS = heliSpeed * 16
	
	advanceRatio = (KTAS * cos(heliPitch)) / (rpm * bladeLengthFeet) ## ADVANCE RATIO CALC
	thrustCoef = thrustCoefCurve.sample(advanceRatio) ## THRUST COEFFICIENT
	thrust = thrustCoef * airDensity * rotorArea * pow(rpm * bladeLength, 2)
	
	inducedVelocity = sqrt(thrust / (2 * airDensity * rotorArea))
	#1inducedVelocity = (-(heliClimbRate/2) + sqrt(pow(heliClimbRate/2, 2) + (thrust / (2 * airDensity * rotorArea))))
	inflowVelocity = inducedVelocity + heliClimbRate
	netDownFlowSpeed = (KTAS * sin(heliPitch)) + (heliClimbRate * cos(heliPitch)) + inducedVelocity
	inflowRatio = netDownFlowSpeed / rpm * bladeLength
	
	bladePitch = 0.06 - (heliNode.collective / 300) # RADIANS
	aoa = 0 - (heliNode.collective / 300) # RADIANS
	liftCoef = liftCoefCurve.sample(-aoa)
	
	liftForce = liftCoef * pow(bladeSpeed, 2) * bladeArea * airDensity
	
	drawVectors()
	
func drawVectors() -> void:
	if debugIter > 10:
		print("bladePitchAngle: ", rad_to_deg(bladePitch))
		print("aoa: ", aoa)
		print("rpm: ", rpm)
		print("bladeSpeed: ", bladeSpeed)
		#print("liftCoef: ", liftCoef)
		#print("liftForce: ", liftForce)
		print("thrustCoef: ", thrustCoef)
		print("thrust: ", thrust)
		print("Advance ratio: ", advanceRatio)
		print("induced velocity: ", inducedVelocity)
		print("net down flow speed: ", netDownFlowSpeed)
		print("inflow ratio: ", inflowRatio)
		#print("solidity: ", solidity)
		debugIter = 0
	else:
		debugIter += 1
	
	#DebugDraw3D.draw_line(global_position, (pitchAxis*2 + global_position))
	DebugDraw3D.draw_line(global_position, (yawAxis*liftForce/100 + global_position), Color.BLUE)
	DebugDraw3D.draw_line(global_position, (rollAxis*2 + global_position))
	DebugDraw3D.draw_line(global_position, (globalRollAxis + global_position))
	DebugDraw3D.draw_line(global_position, (rollAxis.rotated(pitchAxis, bladePitch) * 2 + global_position), Color.BLUE_VIOLET)
	
	
