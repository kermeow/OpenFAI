extends Node2D
class_name FloorObject

var floor:Floor

var angle = floor.angle:
	get: return angle
	set(value):
		angle = value
		realign()
var length = floor.length:
	get: return length
	set(value):
		length = value
		realign()

@export_node_path("Node2D") var previous_floor_path
@onready var line:Line2D = $Line

func _ready():
	line.set_point_position(0,Vector2(-length,0))
	if previous_floor_path != null:
		var previous_floor = get_node_or_null(previous_floor_path)
		if previous_floor == self or previous_floor.previous_floor_path == self.get_path():
			previous_floor = null
			previous_floor_path = null
		else:
			align_to_floor(previous_floor)
	realign()

func realign():
	line.set_point_position(2,Vector2(
			cos(deg_to_rad(angle)),
			-sin(deg_to_rad(angle))
			)*length)
func align_to_floor(last_floor:FloorObject):
	var last_angle = last_floor.angle
	line.set_point_position(0,Vector2(
		cos(deg_to_rad(last_angle)),
		-sin(deg_to_rad(last_angle))
		)*-length)
	position = last_floor.position + Vector2(
		cos(deg_to_rad(last_angle)),
		-sin(deg_to_rad(last_angle))
		)*(length + last_floor.length)
