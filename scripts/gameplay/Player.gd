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
var bpm:float = 60
var speed:float = 0.25

func _process(delta:float):
	var addition = delta * 180 * (bpm/60) * speed
	if clockwise: angle -= addition
	else: angle += addition
	angle = wrapf(angle,0,360)
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
	var next_floor = current_floor.next_floor
	if next_floor != null:
		var spinner:Node2D = $B
		if side: spinner = $A
		var difference = rad_to_deg(abs(spinner.position.angle_to(next_floor.position-position)))
		if difference > 60: return
		flip()
		current_floor = next_floor
		for action in current_floor.floor.actions:
			match action.type:
				Action.Type.Twirl:
					clockwise = not clockwise
				Action.Type.SetSpeed:
					var speed_type = action.data.get("speedType","Multiplier")
					var _bpm = action.data.get("beatsPerMinute",100)
					var _speed = action.data.get("bpmMultiplier",1)
					if speed_type == "Multiplier":
						speed *= _speed
