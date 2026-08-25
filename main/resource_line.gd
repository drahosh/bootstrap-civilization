extends HBoxContainer

class_name Resource_line

var resource_key
var resources: Resources


func set_label(value):
	get_node("CenterContainer/ResourceName").text = value


func set_resource_key(value):
	resource_key = value


func set_resources(resources):
	self.resources = resources


func redraw():
	redraw_resource()
	get_node("CenterContainer3/ResourceChange").text = str(resources.resource_changes[resource_key])


func redraw_resource():
	# separated for separate use by resources.gd
	var text = str(snapped(resources.resources[resource_key], 0.1))
	if resource_key in resources.resource_capacities:
		text += " / %s" % resources.resource_capacities[resource_key]
	get_node("CenterContainer2/ResourceAmount").text = text


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
