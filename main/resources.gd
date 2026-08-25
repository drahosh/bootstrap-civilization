extends VBoxContainer

class_name Resources
var resource_line: PackedScene = preload("res://main/resource_line.tscn")
static var resources: Dictionary = {}  # map of resource name to amount
static var resource_changes: Dictionary = {}  # map of changes from last tick. Is reset to 0 at start of tick, then increased or decreased during processing
var visible_resources = []  # list of resources shown in UI
var resource_capacities = {}  # nonperishable capacity for perishable resources
static var granary_enabled = false


func _setup():
	visible_resources = [
		Enums.resource_types.FOOD,
		Enums.resource_types.MATERIALS,
		Enums.resource_types.TEXTILES,
		Enums.resource_types.TOOLS,
	]

	for resource_type in Enums.resource_types.values():
		resources[resource_type] = 0
		resource_changes[resource_type] = 0
	resources[Enums.resource_types.FOOD] = 100
	for resource_type in Enums.perishable_resources:
		resource_capacities[resource_type] = 0
	redraw_resource_list()


#Makes list of resources, redrawn on ready and when resource is added
func redraw_resource_list():
	for child in get_children():
		child.free()
	for resource in visible_resources:
		var line: Resource_line = resource_line.instantiate() as Resource_line

		line.set_label(Enums.resource_names[resource])
		line.set_resource_key(resource)
		line.set_resources(self)
		line.redraw()
		add_child(line)


# Called when the node enters the scene tree for the first time.
func _ready():
	_setup()
	GlobalSignals.unlock_resource.connect(unlock_resource)
	GlobalSignals.manual_resource_change.connect(refresh_display)


func process_perishables():
	if granary_enabled:
		resource_capacities[Enums.resource_types.FOOD] = Population.max_population_this_run * 7
	for resource_type in Enums.perishable_resources:
		var perishable = resources[resource_type] - resource_capacities[resource_type]
		change_resources({resource_type: -perishable * Enums.perishable_resources[resource_type]})


func refresh_display():
	for line in get_children():
		line.redraw_resource()
	GlobalSignals.resources_recounted.emit()


func tick():
	for line in get_children():
		line.redraw()
	GlobalSignals.resources_recounted.emit()
	for key in Enums.resource_types.values():
		Resources.resource_changes[key] = 0


static func change_resources(to_change: Dictionary, negative: bool = false, times: int = 1, manual = false):
	# for each resource in to_change, resource[key] += to_change[key]
	# if negative is true, use -= in instead (useful with multiple items in dictionary)
	# repeats 'times' times (useful if multiplying everything in to_change by same number, like in jobs)
	# This function assumes you're not using it to pay more of a resource than is set, you need to check this separately
	var negator = -1 if negative else 1
	for key in to_change:
		# When buying things manually, you actually spend only half the amount of food you need
		var manual_food_mult = 1
		if manual and key == Enums.resource_types.FOOD:
			manual_food_mult = 0.5  #
		resources[key] += to_change[key] * negator * times * manual_food_mult
		# could emit manual resource change signal here, but that could cause hundreds of signals with current implementation of buy max
		if not manual:
			resource_changes[key] += to_change[key] * negator * times


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func save_game():
	return {
		"resources": resources,
		"resource_changes": resource_changes,
		"visible_resources": visible_resources,
		"granary_enabled": granary_enabled,
	}


func load_game(dict):
	# need to parse types from enums as ints instead of floats
	resources = {}
	for key in dict["resources"]:
		resources[int(key)] = dict["resources"][key]
	resource_changes = {}
	for key in dict["resource_changes"]:
		resource_changes[int(key)] = dict["resource_changes"][key]
	visible_resources = []
	for value in dict["visible_resources"]:
		visible_resources.append(int(value))
	granary_enabled = dict["granary_enabled"]
	redraw_resource_list()


func unlock_resource(resource: int):
	if resource not in visible_resources:
		visible_resources.append(resource)
	if resource not in resources:
		resources[resource] = 0
	redraw_resource_list()


func reset():
	_setup()
