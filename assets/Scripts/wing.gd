extends Node3D

var yawAxis : Vector3 = Vector3.ZERO
var pitchAxis : Vector3 = Vector3.ZERO
var rollAxis : Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	yawAxis = global_transform.basis.y
	pitchAxis = global_transform.basis.x
	rollAxis = global_transform.basis.z
	
	#drawVectors()
	
func drawVectors() -> void:
	
	
	DebugDraw3D.draw_line(global_position, (yawAxis*2 + global_position))
	DebugDraw3D.draw_line(global_position, (pitchAxis*2 + global_position))
	DebugDraw3D.draw_line(global_position, (rollAxis*2 + global_position))
