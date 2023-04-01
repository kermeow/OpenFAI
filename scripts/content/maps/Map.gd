extends Resource
class_name Map

var data:Dictionary

var version:int
var meta:Dictionary = {}

var floors:Array[Floor]

func setup():
	var settings = data.get("settings",{})
	version = settings.get("version",-1)
	meta = settings
	
	floors = []
	for angle in data.get("angleData",[]):
		var floor = Floor.new()
		floor.angle = angle
	
	for action_data in data.get("actions",[]):
		var action = Action.new(action_data)
		floors[action_data.get("floor",0)].actions.append(action)
