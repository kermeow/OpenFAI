extends Node2D
class_name FloorObject

var floor:Floor:
	set(value):
		floor = value
		angle = value.angle
		length = value.length
		update_actions()

var angle = 0:
	get: return angle
	set(value):
		angle = value
		realign()
var length = 50:
	get: return length
	set(value):
		length = value
		realign()

var next_floor:FloorObject
var previous_floor:FloorObject

@onready var line:Line2D = $Line

func _ready():
	line.set_point_position(0,Vector2(-length,0))
	if previous_floor != null:
		if previous_floor == self or previous_floor.previous_floor == self:
			previous_floor = null
		else:
			align_to_floor(previous_floor)
	realign()

func update_actions():
	var types = floor.actions.map(func(action): return action.type)
	$Actions/Twirl.visible = Action.Type.Twirl in types

func realign():
	if line == null: return
	line.set_point_position(2,Vector2(
			cos(deg_to_rad(angle)),
			-sin(deg_to_rad(angle))
			)*length)
func align_to_floor(last_floor:FloorObject):
	var last_angle = last_floor.angle
	position = last_floor.position + Vector2(
		cos(deg_to_rad(last_angle)),
		-sin(deg_to_rad(last_angle))
		)*(length + last_floor.length)
	if line != null:
		line.set_point_position(0,Vector2(
			cos(deg_to_rad(last_angle)),
			-sin(deg_to_rad(last_angle))
			)*-length)
