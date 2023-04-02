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
#	if game.playing and spin_angle > 360:
#		game.stop(true)
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
		hit()

func movement():
	anchor.position = Vector2()
	spinner.position = Vector2(
		cos(deg_to_rad(angle)),
		-sin(deg_to_rad(angle))
	) * 100

func flip():
	side = not side
	angle = wrapf(angle-180,-180,180)
func advance(floor:FloorObject,_flip:bool=true):
	current_floor = floor
	if _flip:
		position = current_floor.position
		spin_angle = 0
		flip()
func hit():
	if current_floor != null:
		current_floor.hit(self)
