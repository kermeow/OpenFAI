extends Node2D
class_name GameScene

var map:Map

var objects:Array[FloorObject]
var objects_noms:Array[FloorObject]

func _ready():
	setup()
	call_deferred("generate_path")
	call_deferred("countdown")

	$Player.on_advance.connect(player_advanced)

func player_advanced(to:FloorObject):
	if to == null or to.midspin: return
	var behind_index = objects_noms.find(to) - map.settings.get("beatsBehind",0)
	var ahead_index = objects_noms.find(to) + map.settings.get("beatsAhead",4)
	var index = 0
	for object in objects_noms.duplicate():
		if index < behind_index:
			object.hide_animated($Player)
			objects_noms.remove_at(objects_noms.find(object))
		elif index <= ahead_index and !object.visible:
			object.show_animated($Player)
		elif index > ahead_index:
			break
		index += 1

func generate_path():
	var curve = Curve2D.new()
	$Path.curve = curve
	for object in $Floors.get_children():
		if object.midspin: continue
		curve.add_point(object.position)

func setup():
	get_tree().paused = true
	$Music.stream = map.audio

	objects = []
	var align_object:FloorObject
	var last_object_noms:FloorObject
	var midspins:Array[FloorObject] = []
	var object_count:int = 0
	for floor in map.floors:
		var object:FloorObject = preload("res://prefabs/gameplay/Floor.tscn").instantiate()
		objects.append(object)

		object.actions = []

		object.floor = floor
		var floor_position = Vector2()
		if align_object:
			floor_position = object.align_to_floor(align_object)
		if !floor.midspin and !floor.no_align: align_object = object

		if last_object_noms != null and !floor.midspin:
			last_object_noms.next_floor = object

		if !floor.midspin:
			object.midspins = midspins.duplicate()
			midspins.reverse()
			for midspin in midspins:
				midspin.midspin_parent = object
				object.add_child(midspin)
			midspins = []
			$Floors.add_child(object)
			objects_noms.append(object)
			object_count += 1
			last_object_noms = object
			if object_count > map.settings.get("beatsAhead",4):
				object.visible = false
		else:
			midspins.append(object)
			var midspin = preload("res://prefabs/gameplay/Floor.tscn").instantiate()
			midspin.floor = floor
			midspin.align_to_floor(object)
			objects.append(midspin)
			object.add_child(midspin)
			object.midspin_object = midspin
	for action in map.actions:
		if action.floor < objects.size():
			var object = objects[action.floor]
			object.actions.append(action)
			object.update_actions()
		else:
			print("Out of bounds action")

	$Player.bpm = map.settings.get("bpm",60)
	get_tree().paused = false

var counting = false
var count:float = 0
var countdown_ticks:int = 4
func countdown():
	if counting or playing or stopped: return
	counting = true
	countdown_ticks = map.settings.get("countdownTicks",4)
	$Player.angle = 0
	count = -2

func set_path_offset():
	var curve = $Path.curve as Curve2D
	var offset = 0
	if curve != null: offset = curve.get_closest_offset($Player.position)
	$Path/Follow.progress = offset
func _process(delta:float):
	if playing:
		var bpm_speed = ($Player.bpm/60) * $Player.speed
		$Camera.position_smoothing_speed = bpm_speed / 1.5
		$Path/Follow.progress = $Path/Follow.progress + (bpm_speed * 100 * delta)
	if counting:
		var bpm_speed = ($Player.bpm/60) * $Player.speed
		var offset = map.settings.get("offset",0)/1000.0
		count += delta * bpm_speed
		if count > countdown_ticks - 1 and not playing:
			start(count-countdown_ticks)
		if count > ((countdown_ticks/bpm_speed)-offset)*bpm_speed and not $Music.playing:
			$Music.play((count-countdown_ticks)/bpm_speed)
		if playing and $Music.playing:
			counting = false

var playing:bool = false
var stopped:bool = false
func start(from:float=0):
	if stopped or playing: return
	print("Started")
	$Player.current_floor = $Floors.get_child(0)
	playing = true
func stop(fail:bool=false):
	if stopped or !playing: return
	print("Stopped")
	print("Failed: %s" % fail)
	playing = false
	stopped = true
	$Music.stop()
