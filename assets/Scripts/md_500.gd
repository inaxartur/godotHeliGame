extends RigidBody3D

#var inputHandleScript := preload("res://assets/Scripts/input_handler.gd").new()

@export var tailRotorNode : Node3D
@export var mainRotorNode : Node3D
@export var collectiveNode : Node3D
@export var stickNode : Node3D
@export var stick2Node : Node3D

var pathVector : Vector3 = Vector3.ZERO
var pathIter := 0
var currentPosition : Vector3
var previousPosition : Vector3

var stickRot := 0.15
var stickRotVec : Vector3

var debugMode : bool = true
var debugIter := 0

const maxThrottle := 100.0
const maxCollective := 100.0
const stepInputValue := 2

@export var horsePower := 50

var yawAxis : Vector3 = Vector3.ZERO
var pitchAxis : Vector3 = Vector3.ZERO
var rollAxis : Vector3 = Vector3.ZERO

var collective := 0.0
var throttle := 0.0
var rpm := 0.0
var speed := 0.0
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
	
	upForce = yawAxis * collective * horsePower / 5
	apply_force(upForce, Vector3.ZERO)
	debug()

### PATH VECTOR ###
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	currentPosition = state.transform.origin
	pathVector = currentPosition - previousPosition
	previousPosition = currentPosition

### HANDLING INPUT ###
func inputHandler() -> void:
	if Input.is_action_pressed("collective_up"):
		if collective + stepInputValue > maxCollective:
			pass
		else:
			collective += stepInputValue
			print("collective: ", collective)
	if Input.is_action_pressed("collective_down"):
		if collective - stepInputValue < 0:
			pass
		else:
			collective -= stepInputValue+1
			print("collective: ", collective)
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



func debug() -> void:
	if debugMode == true:
		if debugIter > 6:
			print("rotation: ", rotation)
			print("global position: ", global_position, " | previousPosition: ", previousPosition)
			debugIter = 0
		else:
			debugIter += 1
		
		drawVectors()


func drawVectors() -> void:
	DebugDraw3D.draw_line(global_position, pathVector*10 + global_position)
	DebugDraw3D.draw_line(global_position, (upForce/100) + global_position)
	
	DebugDraw3D.draw_line(position, (yawAxis*2 + position))
	DebugDraw3D.draw_line(position, (pitchAxis*2 + position))
	DebugDraw3D.draw_line(position, (rollAxis*2 + position))
	

func anims() -> void:
	mainRotorNode.rotation.y -= 0.1
	tailRotorNode.rotation.z -= 0.2
	collectiveNode.rotation.z = -collective / 300
