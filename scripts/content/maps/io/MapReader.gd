extends Object
class_name MapReader

static func read_from_file(path:String) -> Map:
	var map = Map.new()
	var file = FileAccess.open(path, FileAccess.READ)
	map.data = JSON.parse_string(file.get_as_text())
	return map
