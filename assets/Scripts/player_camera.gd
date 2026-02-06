extends Marker3D

@export var cameraMarker : Marker3D
@export var camera : Camera3D

var mousePos : Vector2
var viewportResCenter : Vector2
var thirdPerson : bool = false
var thirdPersonCoord : Vector3 = Vector3(0, 2.0, -7.175)
var copilot : bool = false
var pilotCoord : Vector3
const maxFov := 120.0
const minFov := 45.0

func _ready() -> void:
	viewportResCenter = get_viewport().get_visible_rect().size/2
	pilotCoord = cameraMarker.position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mousePos = event.position - viewportResCenter
		cameraMarker.rotation.y = -mousePos.x / 300
		cameraMarker.rotation.x = mousePos.y / 300
	
	if event is InputEventMouseButton:
		if event.is_action_pressed("fov_up") && (camera.fov - 3) > minFov:
			camera.fov -= 3
		elif event.is_action_pressed("fov_down") && (camera.fov + 3) < maxFov:
			camera.fov += 3
		
		if event.is_action_pressed("move_around_cockpit"):
			cameraMarker.position.x = -mousePos.x / 3500 + pilotCoord.x
			cameraMarker.position.y = -mousePos.y / 2500 + pilotCoord.y
	
	if event.is_action_pressed("switch_seats"):
		if copilot:
			pilotCoord.x *= -1
			cameraMarker.position.x = pilotCoord.x
			copilot = false
		elif !copilot:
			pilotCoord.x *= -1
			cameraMarker.position.x = pilotCoord.x
			copilot = true
	
	if event.is_action_pressed("switch_camera"):
		if thirdPerson:
			camera.position = Vector3.ZERO
			thirdPerson = false
		elif !thirdPerson:
			camera.position = thirdPersonCoord
			thirdPerson = true

func say_dupa() -> void:
	print("dupa")
