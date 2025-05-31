extends VBoxContainer

class_name Resources
var resource_line: PackedScene = preload("res://main/resource_line.tscn")
static var resources: Dictionary = {}  # map of resource name to amount
static var resource_changes: Dictionary = {}  # map of changes from last tick. Is reset to 0 at start of tick, then increased or decreased during processing
var enabled_resources = []  # list of resources shown in UI


func _setup():
	#TODO loading
	#If not state or save file, set defaults
	enabled_resources = [
		Enums.resource_types.FOOD,
		Enums.resource_types.MATERIALS,
		Enums.resource_types.TEXTILES,
		Enums.resource_types.TOOLS
	]
	Resources.resources = {
		Enums.resource_types.FOOD: 500,
		Enums.resource_types.MATERIALS: 20,
		Enums.resource_types.TEXTILES: 0,
		Enums.resource_types.METALS: 0,
		Enums.resource_types.TOOLS: 0,
	}
	for key in Enums.resource_types.values():
		Resources.resource_changes[key] = 0


#Makes list of resources, redrawn on ready and when resource is added
func redraw_resource_list():
	for resource in enabled_resources:
		var line: Resource_line = resource_line.instantiate() as Resource_line

		line.set_label(Enums.resource_names[resource])
		line.set_resource_key(resource)
		line.set_resources(self)
		line.redraw()
		add_child(line)


# Called when the node enters the scene tree for the first time.
func _ready():
	self._setup()
	self.redraw_resource_list()


func tick():
	#zero resource changes
	for line in self.get_children():
		line.redraw()
	for key in Enums.resource_types.values():
		Resources.resource_changes[key] = 0


static func change_resources(to_change: Dictionary, negative: bool = false, times: int = 1):
	# for each resource in to_change, resource[key] += to_change[key]
	# if negative is true, use -= in instead
	# repeats 'times' times (useful if multiplying everything in to_change by same number, like in jobs)
	# This function assumes you're not using it to pay more of a resource than is set, you need to check this separately
	var negator = -1 if negative else 1
	for key in to_change:
		resources[key] += to_change[key] * negator * times
		resource_changes[key] += to_change[key] * negator * times


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
