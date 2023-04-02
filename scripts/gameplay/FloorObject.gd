extends Node2D
class_name FloorObject

var floor:Floor:
	set(value):
		floor = value
		angle = value.angle
		length = value.length
var actions:Array[Action]

var angle:int = 0:
	get: return angle
	set(value):
		angle = value
		realign()
var length:int = 50:
	get: return length
	set(value):
		length = value
		realign()
var midspin:bool:
	get: return floor.midspin

var aligned_to:FloorObject
var next_floor:FloorObject

@onready var line:Line2D = $Line

func _ready():
	line.set_point_position(0,Vector2(-length,0))
	call_deferred("realign")
	call_deferred("update_actions")

func update_actions():
	var types = actions.map(func(action): return action.type)
	$Actions/Twirl.visible = Action.Type.Twirl in types

func realign():
	if line == null: return
	if midspin:
		self.move_to_front()
		line.set_point_position(2,Vector2(
			cos(deg_to_rad(angle)),
			-sin(deg_to_rad(angle))
			)*length*2)
	else:
		line.set_point_position(2,Vector2(
			cos(deg_to_rad(angle)),
			-sin(deg_to_rad(angle))
			)*length)
	if aligned_to != null:
		var last_angle = aligned_to.angle
		position = aligned_to.position + Vector2(
			cos(deg_to_rad(last_angle)),
			-sin(deg_to_rad(last_angle))
			)*(length + aligned_to.length)
		line.set_point_position(0,Vector2(
			cos(deg_to_rad(last_angle)),
			-sin(deg_to_rad(last_angle))
			)*-length)

func align_to_floor(object:FloorObject):
	aligned_to = object
	realign()
func hit(player:Player):
	if next_floor == null: return
	var spinner_position = player.spinner.position
	var next_position = next_floor.position-position
	if midspin:
		next_position += Vector2(
			cos(deg_to_rad(angle)),
			-sin(deg_to_rad(angle))
			)*length
	var difference = rad_to_deg(spinner_position.angle_to(next_position))
	var abs_difference = abs(difference)
	if abs_difference <= 30:
		print("Perfect")
	elif abs_difference <= 45:
		print("Good")
	elif abs_difference <= 60:
		print("Poor")
	if abs_difference > 60: return
	player.advance(next_floor,!midspin)
