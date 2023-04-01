extends Resource
class_name Map

var path:String
var data:Dictionary

var version:int
var settings:Dictionary = {}

var audio:AudioStream

var floors:Array[Floor]

func _init(_path:String):
	path = _path

func setup():
	var _settings = data.get("settings",{})
	settings = _settings
	version = settings.get("version",-1)
	
	audio = AudioReader.read_from_file(path.get_base_dir().path_join(settings.get("songFilename")))
	
	floors = []
	for angle in data.get("angleData",[]):
		var floor = Floor.new()
		floor.angle = angle
		floors.append(floor)
	
	for action_data in data.get("actions",[]):
		var action = Action.new(action_data)
		floors[int(action_data.get("floor",0))].actions.append(action)
