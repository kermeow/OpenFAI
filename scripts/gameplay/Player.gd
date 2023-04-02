extends Node2D
class_name Player

@onready var game:GameScene = get_parent()

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
var speed:float = 1

var anchor:Node2D
var spinner:Node2D

var spins = 0
var spin_angle = 0

func _process(delta:float):
	var addition = delta * 180 * (bpm/60) * speed
	if clockwise: angle -= addition
	else: angle += addition
	spin_angle += addition
	if game.playing and spin_angle > 360:
		game.stop(true)
	angle = wrapf(angle,-180,180)
	anchor = $A
	spinner = $B
	if side:
		anchor = $B
		spinner = $A
	movement()
	camera.position = global_position

func _input(event):
	if !game.playing: return
	if event is InputEventKey and event.pressed and !event.is_echo():
		try_hit()

func movement():
	position = current_floor.position
	anchor.position = Vector2()
	spinner.position = Vector2(
		cos(deg_to_rad(angle)),
		-sin(deg_to_rad(angle))
	) * 100

func flip():
	spins = 0
	side = not side
	angle = wrapf(angle-180,-180,180)

func try_hit():
	var next_floor = current_floor.next_floor
	if next_floor != null:
		var difference = rad_to_deg(spinner.position.angle_to(next_floor.position-position))
		var abs_difference = abs(difference)
		if abs_difference <= 30:
			print("Perfect")
		elif abs_difference <= 45:
			print("Good")
		elif abs_difference <= 60:
			print("Poor")
		if abs_difference > 60: return
		flip()
		current_floor = next_floor
		spin_angle = 0
		run_actions(current_floor.floor)

func run_actions(floor:Floor):
	for action in floor.actions:
		match action.type:
			Action.Type.Twirl:
				clockwise = not clockwise
			Action.Type.SetSpeed:
				var speed_type = action.data.get("speedType","Multiplier")
				var _bpm = action.data.get("beatsPerMinute",100)
				var _speed = action.data.get("bpmMultiplier",1)
				if speed_type == "Multiplier":
					speed *= _speed
				elif speed_type == "Bpm":
					bpm = _bpm
