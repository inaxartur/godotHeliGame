extends Camera3D

@onready var camera = $Camera3D

var mousePos : Vector2
var viewportResCenter : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	viewportResCenter = get_viewport().get_visible_rect().size/2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mousePos = event.position - viewportResCenter
		
		
