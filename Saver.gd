extends Node

var saved_res = [
	{
		"res": null,
		"path": ""
	}
]

func save(res: Resource, path: String) -> void:
	var err = ResourceSaver.save(res, path)
	if not err == OK:
		printerr("saving error")
	else:
		var new_entry = {
			"res": res,
			"path": path
			}
		saved_res.append(new_entry)

func load(path: String) -> Resource:
	var resource = null
	for entry in saved_res:
		if entry.get("path") == path:
			resource = ResourceLoader.load(entry.get("res"))
			break
	
	return resource
