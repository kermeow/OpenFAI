extends Object
class_name MapReader

static func read_from_file(path:String) -> Map:
	var map = Map.new(path)
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null: return
	var data = JSON.parse_string(file.get_as_text())
	if data == null: return
	map.data = data
	map.setup()
	return map
