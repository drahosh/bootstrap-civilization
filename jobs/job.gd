extends HBoxContainer
class_name JobLine
var job_name: String
var workforce_max: int
var workforce_max_base: int
var workforce_current: int
var workforce_limit_percentage: int
var description: String
var base_upgrade_costs: Dictionary
var upgraded_number: int = 0  #todo IMPLEMENT
var upgrade_cost_scale: float = 1.2  # todo implement
var job_requirements: Dictionary  # resource to amount consumed per workforce
var output: Dictionary  # resource to amount produced per workforce
var input: Dictionary  # resources needed per workforce to produce


# Called when the node enterss the scene tree for the first time.
func _ready():
	$Panel/VBoxContainer/HBoxContainer/buy_box/UpgradeButton.pressed.connect(upgrade)
	self.redraw()


func _update_main_description():
	get_node("Panel/VBoxContainer/HBoxContainer/MainLabel").text = (
		"""[b]%s[/b]
	work: %s
	max:  %s"""
		% [job_name, workforce_current, workforce_max]
	)


func _get_upgrade_cost():
	var discounted = 1  # we start with one upgrade, but want to start scaling after that
	return Utils.get_scaled_cost(
		self.base_upgrade_costs, self.upgrade_cost_scale, max(0, self.upgraded_number - discounted)
	)


func _can_afford_upgrade(number: int = 1):
	var upgrade_cost = _get_upgrade_cost()
	var affordable = true
	for key in upgrade_cost:
		if upgrade_cost[key] > Resources.resources[key]:
			affordable = false
	return affordable


func upgrade(times = 1):
	# times can be integer or Enums.MAX
	var bought = 0
	while true:
		if times is int and bought >= times:
			break
		if not _can_afford_upgrade():
			break
		Resources.change_resources(_get_upgrade_cost(), true)
		self.upgraded_number += 1
		self.workforce_max += self.workforce_max_base
		bought += 1
	self.redraw()


func redraw():
	_update_main_description()
	get_node("Panel/VBoxContainer/HBoxContainer/buy_box/UpgradeButton").disabled = not _can_afford_upgrade()
	get_node("Panel/VBoxContainer/workforce percentage").value = (
		float(self.workforce_current) * 100 / self.workforce_max
	)
	$Panel/VBoxContainer/HBoxContainer/buy_box/UpgradeLabel.text = str(upgraded_number)
	$Panel/VBoxContainer/HBoxContainer/buy_box/UpgradeButton.tooltip_text = Utils.resources_to_string(
		_get_upgrade_cost()
	)
	var tooltip = ""
	if output.size() > 0:
		tooltip += "produces per workforce:\n"
		tooltip += Utils.resources_to_string(output)
		if input.size() > 0:
			tooltip += "\n"
	if input.size() > 0:
		tooltip += "consumes per workforce:\n"
		tooltip += Utils.resources_to_string(input)
	$Panel.tooltip_text = tooltip


func init(
	job_name,
	workforce_max: int,
	output: Dictionary,
	input: Dictionary,
	upgrade_costs: Dictionary,
	description: String,
):
	self.job_name = job_name
	self.workforce_max = workforce_max
	self.workforce_max_base = workforce_max
	self.output = output
	self.input = input
	self.description = description
	self.base_upgrade_costs = upgrade_costs
	self.upgraded_number = 0
	_update_main_description()


func tick():
	# before this function is called, current workforce is set from outside
	self.redraw()
	Resources.change_resources(input, true, workforce_current)
	Resources.change_resources(output, false, workforce_current)


func get_desired_workforce():
	# returns how many workers this can take taking into account available input
	var max = workforce_max
	var wanted_percentage = $Panel/VBoxContainer/HBoxContainer/LineEdit.text
	if wanted_percentage.is_valid_int():
		wanted_percentage = int(wanted_percentage)
	else:
		$Panel/VBoxContainer/HBoxContainer/LineEdit.text = 100
		wanted_percentage = 100
	var wanted_max = int(max * float(wanted_percentage) / 100)
	for resource in input:
		var amount = Resources.resources[resource]
		wanted_max = min(wanted_max, amount / input[resource])
	return wanted_max
