extends PanelContainer
class_name JobUpgrade
var job_name: String
var capacity_cost_multiplier: int
var capacity_upgraded_times: int
var capacity_affecting_upgrade: Signal
var enabled = false
# TODO other 3 upgrades (probably with prestige)


func save_game():
	return {
		"capacity_cost_multiplier": capacity_cost_multiplier,
		"capacity_upgraded_times": capacity_upgraded_times,
		"job_name": job_name
	}


func load_game(data_dict, capacity_affecting_upgrade):
	capacity_cost_multiplier = data_dict["capacity_cost_multiplier"]
	capacity_upgraded_times = data_dict["capacity_upgraded_times"]
	job_name = data_dict["job_name"]
	$VBoxContainer/Label.text = job_name
	self.capacity_affecting_upgrade = capacity_affecting_upgrade
	toggle_affordable()


func init(capacity_cost_multiplier: int, capacity_affecting_upgrade: Signal, job_name: String):
	self.capacity_cost_multiplier = capacity_cost_multiplier
	self.capacity_affecting_upgrade = capacity_affecting_upgrade
	self.job_name = job_name
	$VBoxContainer/Label.text = job_name
	capacity_upgraded_times = 0


func _ready():
	GlobalSignals.manual_resource_change.connect(toggle_affordable, CONNECT_DEFERRED)
	$VBoxContainer/HBoxContainer/CapButton.pressed.connect(upgrade_capacity)
	toggle_visibility()
	redraw_buttons()


func toggle_visibility():
	visible = enabled


func get_current_cost(upgrade_type: int) -> Dictionary:
	var cost
	match upgrade_type:
		Enums.job_upgrade_types.CAPACITY:
			cost = GlobalVariables.capacity_upgrade_base_cost.duplicate()
	for key in cost:
		cost[key] *= capacity_cost_multiplier * pow(GlobalVariables.job_upgrade_scale, capacity_upgraded_times)
	return cost


func can_afford_upgrade(upgrade_type):
	var cost = get_current_cost(upgrade_type)
	for key in cost:
		if Resources.resources[key] < cost[key]:
			return false
	return true


func get_capacity_multiplier():
	return pow(GlobalVariables.capacity_upgrade_size, capacity_upgraded_times)


func toggle_affordable():
	# make buttons clickable if upgrades affordable
	$VBoxContainer/HBoxContainer/CapButton.disabled = not can_afford_upgrade(Enums.job_upgrade_types.CAPACITY)
	# TODO other upgrades when implemented


func upgrade_capacity(times = 1):
	# times can be int>=1 or Enums.MAX
	var bought = 0
	while true:
		if times is int and bought >= times:
			break
		if not can_afford_upgrade(Enums.job_upgrade_types.CAPACITY):
			break
		Resources.change_resources(get_current_cost(Enums.job_upgrade_types.CAPACITY), true, 1, true)
		capacity_upgraded_times += 1
		bought += 1
	GlobalSignals.manual_resource_change.emit()
	capacity_affecting_upgrade.emit()
	redraw_buttons()


func redraw_buttons():
	$VBoxContainer/HBoxContainer/CapButton.text = "Capacity: " + str(capacity_upgraded_times)
	$VBoxContainer/HBoxContainer/CapButton.tooltip_text = Utils.resources_to_string(
		get_current_cost(Enums.job_upgrade_types.CAPACITY)
	)
	# TODO Other buttons


func enable():
	enabled = true
	toggle_visibility()
