extends Node2D
class_name GameScene

var map:Map

func _ready():
	var path:String = FileAccess.open("res://map_path.txt", FileAccess.READ).get_as_text().strip_edges()
	map = MapReader.read_from_file(path)
	setup()
	call_deferred("countdown")

func setup():
	get_tree().paused = true
	$Music.stream = map.audio
	var last_floor
	for floor in map.floors:
		var object:FloorObject = preload("res://prefabs/gameplay/Floor.tscn").instantiate()
		object.floor = floor
		object.previous_floor = last_floor
		if last_floor != null: last_floor.next_floor = object
		$Floors.add_child(object)
		last_floor = object
	$Player.bpm = map.settings.get("bpm",60)
	$Player.current_floor = $Floors.get_child(0)
	$Player.run_actions($Player.current_floor.floor)
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
		count += delta * ($Player.bpm/60) * $Player.speed
		if count > countdown_ticks - 1 and not playing:
			start(count-countdown_ticks)
		elif playing and count > countdown_ticks:
			$Music.play(count-countdown_ticks)
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
