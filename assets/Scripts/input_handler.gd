extends Node
class_name inputHandle

@onready var playerNode 

var parent = get_parent()

@export var collectiveNode : Node3D
@export var stickNode : Node3D
@export var stick2Node : Node3D

#@onready var stickNode = $stick
#@onready var stick2Node = $stick2

const maxThrottle := 100.0
const maxCollective := 100.0
const stepInputValue := 2

var stickRot := 0.15
var stickRotVec : Vector3

var yawAxis : Vector3 = Vector3.ZERO
var pitchAxis : Vector3 = Vector3.ZERO
var rollAxis : Vector3 = Vector3.ZERO

var collective := 0.0
var throttle := 0.0
var rpm := 0.0
var speed := 0.0
var altitude := 0.0

func printParent() -> void:
	print(parent)

func handleInput(horsePower : float, stickNode : Node3D, stick2Node : Node3D, collectiveNode : Node3D) -> void:
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
		get_parent().apply_torque(-pitchAxis * horsePower)
		stickNode.rotation.z = -stickRot
		stick2Node.rotation.z = -stickRot
		
	elif Input.is_action_pressed("pitch_down"):
		get_parent().apply_torque(pitchAxis * horsePower)
		stickNode.rotation.z = stickRot
		stick2Node.rotation.z = stickRot
	else:
		stickNode.rotation.z = stickRotVec.z
		stick2Node.rotation.z = stickRotVec.z
		
		
	if Input.is_action_pressed("roll_left"):
		playerNode.apply_torque(-rollAxis * horsePower)
		stickNode.rotation.x = stickRot
		stick2Node.rotation.x = stickRot
		
	elif Input.is_action_pressed("roll_right"):
		playerNode.apply_torque(rollAxis * horsePower)
		stickNode.rotation.x = -stickRot
		stick2Node.rotation.x = -stickRot
	else:
		stickNode.rotation.x = stickRotVec.x
		stick2Node.rotation.x = stickRotVec.x
	
	if Input.is_action_pressed("yaw_left"):
		playerNode.apply_torque(yawAxis * horsePower)
		
	elif Input.is_action_pressed("yaw_right"):
		playerNode.apply_torque(-yawAxis * horsePower)
