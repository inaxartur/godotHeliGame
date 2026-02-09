extends RigidBody3D

var debugMode : bool = true
var debugIter := 0

#var inputHandleScript := preload("res://assets/Scripts/input_handler.gd").new()

@export var tailRotorNode : Node3D
@export var mainRotorNode : Node3D
@export var collectiveNode : Node3D
@export var stickNode : Node3D
@export var stick2Node : Node3D
@export var blade : Node3D

var pathVector : Vector3 = Vector3.ZERO
var currentPosition : Vector3 = Vector3.ZERO
var previousPosition : Vector3 = Vector3.ZERO

var stickRot := 0.15
var stickRotVec : Vector3

const maxThrottle := 100.0
const maxCollective := 100.0
const stepInputValue := 2

@export var horsePower := 50

var yawAxis : Vector3 = Vector3.ZERO
var pitchAxis : Vector3 = Vector3.ZERO
var rollAxis : Vector3 = Vector3.ZERO
var rateOfClimb : Vector3 = Vector3.ZERO

var angleOfROC : float = 0.0

var collective := 0.0
var throttle := 0.0
var rpm := 0.0
var speed : float = 0.0
var altitude := 0.0

var upForce

### READY ###
func _ready() -> void:
	stickRotVec = stickNode.rotation
	


### PROCESS ###
func _process(_delta: float) -> void:
	#inputHandleScript.handleInput(horsePower, stickNode, stick2Node, collectiveNode)
	#inputHandleScript.printParent()
	inputHandler()
	anims()
	yawAxis = global_transform.basis.y
	pitchAxis = global_transform.basis.x
	rollAxis = global_transform.basis.z
	
	upForce = yawAxis * blade.liftForce
	apply_force(upForce, Vector3.ZERO)
	debug()

### PATH VECTOR ###
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	currentPosition = state.transform.origin
	pathVector = currentPosition - previousPosition
	speed = pathVector.length() / get_process_delta_time()
	angleOfROC = pathVector.angle_to(yawAxis)
	rateOfClimb = pathVector * cos(angleOfROC)
	previousPosition = currentPosition

### HANDLING INPUT ###
func inputHandler() -> void:
	if Input.is_action_pressed("collective_up"):
		if collective + stepInputValue > maxCollective:
			pass
		else:
			collective += stepInputValue
	if Input.is_action_pressed("collective_down"):
		if collective - stepInputValue < 0:
			pass
		else:
			collective -= stepInputValue+1
	if Input.is_action_pressed("pitch_up"):
		apply_torque(-pitchAxis * horsePower)
		stickNode.rotation.z = -stickRot
		stick2Node.rotation.z = -stickRot
		
	elif Input.is_action_pressed("pitch_down"):
		apply_torque(pitchAxis * horsePower)
		stickNode.rotation.z = stickRot
		stick2Node.rotation.z = stickRot
	else:
		stickNode.rotation.z = stickRotVec.z
		stick2Node.rotation.z = stickRotVec.z
		
		
	if Input.is_action_pressed("roll_left"):
		apply_torque(-rollAxis * horsePower)
		stickNode.rotation.x = stickRot
		stick2Node.rotation.x = stickRot
		
	elif Input.is_action_pressed("roll_right"):
		apply_torque(rollAxis * horsePower)
		stickNode.rotation.x = -stickRot
		stick2Node.rotation.x = -stickRot
	else:
		stickNode.rotation.x = stickRotVec.x
		stick2Node.rotation.x = stickRotVec.x
	
	if Input.is_action_pressed("yaw_left"):
		apply_torque(yawAxis * horsePower)
		
	elif Input.is_action_pressed("yaw_right"):
		apply_torque(-yawAxis * horsePower)
		
	
	if Input.is_action_pressed("throttle_up"):
		rpm += 1
	elif Input.is_action_pressed("throttle_down") && rpm > 0:
		rpm -= 1



func debug() -> void:
	if debugMode == true:
		if debugIter > 10:
			print("rotation: ", rotation)
			print("global position: ", global_position, " | previousPosition: ", previousPosition)
			print("speed: ", speed)
			print("angle of roc: ", angleOfROC)
			debugIter = 0
		else:
			debugIter += 1
		
		drawVectors()


func drawVectors() -> void:
	
	if pathVector != Vector3.ZERO || global_position != global_position:
		#DebugDraw3D.draw_line(global_position, -pathVector*10 + global_position)
		DebugDraw3D.draw_line(global_position, pathVector*10 + global_position)
		DebugDraw3D.draw_line(global_position, rateOfClimb*10 + global_position, Color.CYAN)
		
	#DebugDraw3D.draw_line(global_position, (upForce/100) + global_position)
	
	DebugDraw3D.draw_line(position, (yawAxis + position))
	DebugDraw3D.draw_line(position, (pitchAxis + position))
	DebugDraw3D.draw_line(position, (rollAxis + position))
	

func anims() -> void:
	mainRotorNode.rotation.y -= 0.1
	tailRotorNode.rotation.z -= 0.2
	collectiveNode.rotation.z = -collective / 300
