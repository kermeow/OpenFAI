extends Node2D
class_name GameScene

var map:Map

func _ready():
	$FileDialog.add_filter("*.adofai","ADOFAI Maps")
	$FileDialog.popup_centered()
	$FileDialog.file_selected.connect(map_selected)

func map_selected(path:String):
	map = MapReader.read_from_file(path)
	setup()
	call_deferred("countdown")

func setup():
	get_tree().paused = true
	$Music.stream = map.audio

	var objects = []
	var align_object:FloorObject
	var last_object:FloorObject
	for floor in map.floors:
		var object:FloorObject = preload("res://prefabs/gameplay/Floor.tscn").instantiate()

		object.actions = []

		object.floor = floor
		if align_object: object.align_to_floor(align_object)
		if !floor.midspin and !floor.no_align: align_object = object

		if last_object != null:
			last_object.next_floor = object
		last_object = object

		objects.append(object)
		$Floors.add_child(object)
		if floor.midspin:
			var midspin = preload("res://prefabs/gameplay/Floor.tscn").instantiate()
			midspin.floor = floor
			midspin.align_to_floor(object)
			objects.append(midspin)
			$Floors.add_child(midspin)
			object.midspin_object = midspin
	for action in map.actions:
		if action.floor < objects.size():
			var object = objects[action.floor]
			object.actions.append(action)
			object.update_actions()
		else:
			print("Out of bounds action")

	$Player.bpm = map.settings.get("bpm",60)
	$Player.current_floor = $Floors.get_child(0)
	$Player.current_floor.run_actions($Player)
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

func _process(delta:float):
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
	$Player.angle = from * 180
	$Player.spin_angle = from * 180
	playing = true
func stop(fail:bool=false):
	if stopped or !playing: return
	print("Stopped")
	playing = false
	stopped = true
	$Music.stop()
	get_tree().paused = true
