extends Node2D
class_name Player

@export_node_path("Camera2D") var camera_path
@onready var camera:Camera2D = get_node(camera_path)
@export_node_path("AudioStreamPlayer") var music_path
@onready var music:AudioStreamPlayer = get_node(music_path)
@export_node_path("Node") var floor_container_path
@onready var floor_container:Node = get_node(floor_container_path)

var current_floor:FloorObject

var angle:float = 0
var side:bool = false
var clockwise:bool = true

func _process(delta:float):
	if clockwise: angle -= delta*180
	else: angle += delta*180
	movement()
	camera.position = global_position

func _input(event):
	if event is InputEventKey and event.pressed:
		try_hit()

func movement():
	var anchor = $A
	var spinner = $B
	if side:
		anchor = $B
		spinner = $A
	position = current_floor.position
	anchor.position = Vector2()
	spinner.position = Vector2(
		cos(deg_to_rad(angle)),
		-sin(deg_to_rad(angle))
	) * 100

func flip():
	side = not side
	angle -= 180

func try_hit():
	if current_floor.next_floor != null:
		flip()
		for action in current_floor.floor.actions:
			match action.type:
				Action.Type.Twirl:
					clockwise = not clockwise
		current_floor = current_floor.next_floor
