extends HBoxContainer
class_name JobLine
var job_name: String
var workforce_max: int
var workforce_max_base: int
var workforce_current: int
var workforce_limit_percentage: int
var description: String
var base_expand_costs: Dictionary
var expanded_number: int
var output: Dictionary  # resource amount produced per workforce
var input: Dictionary  # resources spent per workforce to produce
var upgrade: JobUpgrade

const upgrade_scene: PackedScene = preload("res://upgrades/job_upgrade.tscn")

signal capacity_affecting_upgrade


# Called when the node enterss the scene tree for the first time.
func _ready():
	$Panel/VBoxContainer/HBoxContainer/buy_box/ExpandButton.pressed.connect(expand)
	GlobalSignals.resources_recounted.connect(_set_button_clickability)
	capacity_affecting_upgrade.connect(calculate_max_workforce)
	capacity_affecting_upgrade.connect(redraw)
	redraw()


func _update_main_description():
	get_node("Panel/VBoxContainer/HBoxContainer/MainLabel").text = (
		"""[b]%s[/b]
	work: %s
	max:  %s"""
		% [job_name, workforce_current, workforce_max]
	)


func _get_expand_cost():
	var discounted = 1  # we start with one expansion, but want to start scaling after that
	return Utils.get_scaled_cost(
		base_expand_costs, GlobalVariables.job_expand_scale, max(0, expanded_number - discounted)
	)


func _can_afford_expansion(number: int = 1):
	var expand_cost = _get_expand_cost()
	var affordable = true
	for key in expand_cost:
		if expand_cost[key] > Resources.resources[key]:
			affordable = false
	return affordable


func expand(times = 1):
	# times can be integer or Enums.MAX
	var bought = 0
	while true:
		if times is int and bought >= times:
			break
		if not _can_afford_expansion():
			break
		Resources.change_resources(_get_expand_cost(), true, 1, true)
		expanded_number += 1
		bought += 1
	GlobalSignals.manual_resource_change.emit()
	enable_upgrades()
	calculate_max_workforce()
	self.redraw()


func _set_button_clickability():
	$Panel/VBoxContainer/HBoxContainer/buy_box/ExpandButton.disabled = not _can_afford_expansion()


func redraw():
	_update_main_description()
	$"Panel/VBoxContainer/workforce percentage".value = (float(self.workforce_current) * 100 / self.workforce_max)
	$Panel/VBoxContainer/HBoxContainer/buy_box/ExpandLabel.text = str(expanded_number)
	$Panel/VBoxContainer/HBoxContainer/buy_box/ExpandButton.tooltip_text = Utils.resources_to_string(_get_expand_cost())
	var tooltip = ""
	if output.size() > 0:
		tooltip += "base production per workforce:\n"
		tooltip += Utils.resources_to_string(output)
		if input.size() > 0:
			tooltip += "\n"
	if input.size() > 0:
		tooltip += "base consumption per workforce:\n"
		tooltip += Utils.resources_to_string(input)
	$Panel.tooltip_text = tooltip
	upgrade.toggle_affordable()


func init(
	job_name: String,
	workforce_max: int,
	output: Dictionary,
	input: Dictionary,
	expand_costs: Dictionary,
	description: String,
	upgrade_cost_multiplier: int
):
	self.job_name = job_name
	self.workforce_max = workforce_max
	self.workforce_max_base = workforce_max
	self.output = output
	self.input = input
	self.description = description
	self.base_expand_costs = expand_costs
	self.expanded_number = 1
	upgrade = upgrade_scene.instantiate()
	upgrade.init(upgrade_cost_multiplier, capacity_affecting_upgrade, job_name)
	GlobalSignals.add_upgrade.emit(upgrade)
	calculate_max_workforce()


func enable_upgrades():
	if expanded_number >= 10:
		upgrade.enable()


func _correct_wanted_percentage():
	# correct value if user inputs nonsense
	var percentage = $Panel/VBoxContainer/HBoxContainer/WantedPercentage.text
	if not percentage.is_valid_int() or int(percentage) < 0 or int(percentage) > 100:
		$Panel/VBoxContainer/HBoxContainer/WantedPercentage.text = "100"


func tick():
	# before this function is called, current workforce is set from outside
	_correct_wanted_percentage()
	Resources.change_resources(input, true, workforce_current)
	Resources.change_resources(output, false, workforce_current)
	redraw()


func get_desired_workforce():
	# returns how many workers this can take taking into account available input
	var max = workforce_max
	_correct_wanted_percentage()
	var wanted_percentage = int($Panel/VBoxContainer/HBoxContainer/WantedPercentage.text)
	var wanted_max = floor(max * float(wanted_percentage) / 100)
	for resource in input:
		var amount = Resources.resources[resource]
		wanted_max = min(wanted_max, floor(amount / input[resource]))
	return wanted_max


func calculate_max_workforce():
	var multiplier = upgrade.get_capacity_multiplier()
	workforce_max = round(workforce_max_base * expanded_number * multiplier)


func save_game():
	return {
		"job_name": job_name,
		"workforce_max_base": workforce_max_base,
		"workforce_current": workforce_current,
		"workforce_limit_percentage": workforce_limit_percentage,
		"description": description,
		"base_expand_costs": base_expand_costs,
		"expanded_number": expanded_number,
		"output": output,
		"input": input,
		"upgrade": upgrade.save_game(),
	}


func load_game(data_dict):
	job_name = data_dict["job_name"]
	workforce_max_base = int(data_dict["workforce_max_base"])
	workforce_current = int(data_dict["workforce_current"])
	workforce_limit_percentage = data_dict["workforce_limit_percentage"]
	description = data_dict["description"]

	expanded_number = int(data_dict["expanded_number"])
	# need to convert keys from string to int (since json supports only string keys)
	base_expand_costs = {}
	for key in data_dict["base_expand_costs"]:
		base_expand_costs[int(key)] = data_dict["base_expand_costs"][key]
	output = {}
	for key in data_dict["output"]:
		output[int(key)] = data_dict["output"][key]
	input = {}
	for key in data_dict["input"]:
		input[int(key)] = data_dict["input"][key]
	upgrade = upgrade_scene.instantiate()
	upgrade.load_game(data_dict["upgrade"], capacity_affecting_upgrade)
	enable_upgrades()
	GlobalSignals.add_upgrade.emit(upgrade)
	calculate_max_workforce()
	redraw()
