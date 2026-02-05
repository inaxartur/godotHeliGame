extends RigidBody3D

@export var camera : Camera3D
@export var tailRotorNode : Node3D
@export var mainRotorNode : Node3D
@export var collectiveNode : Node3D
@export var stickNode : Node3D
@export var stick2Node : Node3D
@onready var cameraMarker = $CameraMarker

var stickRot := 0.15
var stickRotVec : Vector3
#Camera
var mousePos : Vector2
var viewportResCenter : Vector2
var thirdPerson : bool = false
var thirdPersonCoord : Vector3 = Vector3(0, 2.0, -7.175)


var debugMode : bool = true
var debugIter := 0

const maxFov := 120.0
const minFov := 45.0
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


func _ready() -> void:
	viewportResCenter = get_viewport().get_visible_rect().size/2 # for camera
	stickRotVec = stickNode.rotation


func _process(delta: float) -> void:
	inputHandler()
	anims()
	yawAxis = global_transform.basis.y
	pitchAxis = global_transform.basis.x
	rollAxis = global_transform.basis.z
	
	apply_force(yawAxis * collective * horsePower / 5, Vector3.ZERO)
	
	
	debug()

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
			print("mousePos: ", mousePos)
			print("cameraPos: ", camera.position)
			debugIter = 0
		else:
			debugIter += 1
		
		#drawVectors()


func drawVectors() -> void:
	DebugDraw3D.draw_arrow(position, (yawAxis*2 + position))
	DebugDraw3D.draw_arrow(position, (pitchAxis*2 + position))
	DebugDraw3D.draw_arrow(position, (rollAxis*2 + position))
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mousePos = event.position - viewportResCenter
		cameraMarker.rotation.y = -mousePos.x / 300
		cameraMarker.rotation.x = mousePos.y / 300 + 0.2
	if event is InputEventMouseButton:
		if event.is_action_pressed("fov_up") && (camera.fov - 3) > minFov:
			camera.fov -= 3
		elif event.is_action_pressed("fov_down") && (camera.fov + 3) < maxFov:
			camera.fov += 3
		if event.is_action_pressed("move_around_cockpit"):
			cameraMarker.position.x = -mousePos.x / 1000 - 0.287
			cameraMarker.position.y = -mousePos.y / 2000 - 0.303
	if event.is_action_pressed("switch_camera"):
		if thirdPerson:
			camera.position = Vector3.ZERO
			thirdPerson = false
		elif !thirdPerson:
			camera.position = thirdPersonCoord
			thirdPerson = true
func anims() -> void:
	mainRotorNode.rotation.y -= 0.1
	tailRotorNode.rotation.z -= 0.2
	collectiveNode.rotation.z = -collective / 300
