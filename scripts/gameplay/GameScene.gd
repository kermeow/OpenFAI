extends Node2D
class_name GameScene

var map:Map

func _ready():
	map = MapReader.read_from_file("user://maps/farewell/level.adofai")
	setup()

func setup():
	$Music.stream = map.audio
	var last_floor
	for floor in map.floors:
		var object:FloorObject = preload("res://prefabs/gameplay/Floor.tscn").instantiate()
		object.floor = floor
		object.previous_floor = last_floor
		$Floors.add_child(object)
		last_floor = object
