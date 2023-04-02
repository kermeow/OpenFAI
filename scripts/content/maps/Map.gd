extends Resource
class_name Map

const PathAngles = {
	"U":90,
	"R":180,
	"L":360,
	"D":270,
	"E":135,
	"C":225,
	"Q":45,
	"Z":315,
	"H":30,
	"G":60,
	"T":120,
	"J":150,
	"M":210,
	"B":240,
	"F":300,
	"N":330,
	"!":0,
	"5":108,
	"6":252,
	"7":900.0/7.0,
	"8":1620.0/7.0,
	"q":75,
	"W":15,
	"x":345,
	"V":285,
	"Y":255,
	"A":195,
	"p":165,
	"o":105
}

var path:String
var data:Dictionary

var version:int
var settings:Dictionary = {}

var audio:AudioStream

var floors:Array[Floor]
var actions:Array[Action]

func _init(_path:String):
	path = _path

func setup():
	var _settings = data.get("settings",{})
	settings = _settings
	version = settings.get("version",-1)

	audio = AudioReader.read_from_file(path.get_base_dir().path_join(settings.get("songFilename")))

	floors = []
	if data.has("angleData"):
		for angle in data.get("angleData",[]):
			if angle == 999:
				floors[floors.size()-1].midspin = true
				continue
			var floor = Floor.new()
			floor.angle = angle
			floors.append(floor)
	elif data.has("pathData"):
		for key in data.get("pathData","R"):
			if key == "!":
				floors[floors.size()-1].midspin = true
				continue
			var floor = Floor.new()
			floor.angle = 180 - PathAngles.get(key,180)
			floors.append(floor)

	actions = []
	for action_data in data.actions:
		var action = Action.new(action_data)
		actions.append(action)
