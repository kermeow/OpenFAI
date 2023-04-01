extends Object
class_name Action

enum Type {
	Unknown,
	SetSpeed,
	Twirl,
	PositionTrack
}

var type:Type
var data:Dictionary

func _init(_data:Dictionary):
	data = _data
	type = Type.get(data.eventType,Type.Unknown)

func _get(property):
	if property in get_property_list():
		return null
	if property in data.keys():
		return data.get(property)
