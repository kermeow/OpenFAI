extends Object
class_name Action

enum ActionType {
	Unknown,
	SetSpeed,
	Twirl,
	PositionTrack
}

var type:ActionType
var data:Dictionary

func _init(_data:Dictionary):
	data = _data
	type = ActionType.get(data.eventType)

func _get(property):
	if property in get_property_list():
		return null
	if property in data.keys():
		return data.get(property)
