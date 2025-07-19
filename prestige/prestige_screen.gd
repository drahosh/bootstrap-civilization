extends VBoxContainer

class_name PrestigeScreen

signal change_filter(prestige_upgrade_type: int)  # using -1 for all
signal toggle_upgrade(prestige_upgrade_id: int)

const upgrade_box_scene = preload("res://prestige/prestige_upgrade_box.tscn")
@onready var selected_upgrades = $TabContainer/Upgrades/HBoxContainer/ScrollContainer/SelectedUpgrades
@onready var unselected_upgrades = $TabContainer/Upgrades/HBoxContainer/VBoxContainer/ScrollContainer/UnselectedUpgrades
@onready var filter_select = $TabContainer/Upgrades/HBoxContainer/VBoxContainer/Filters/OptionButton
@onready var prestige_button = $Button
@onready var tally = $TabContainer/Upgrades/Tally


func _ready():
	for key in PrestigeData.prestige_upgrades:
		_create_upgrade_box(key)
	filter_select.item_selected.connect(_change_filter)
	toggle_upgrade.connect(_create_upgrade_box)
	prestige_button.pressed.connect(_prestige)


func _tally_costs() -> int:
	# updates ui. Also returns points left to spend
	var total_cost = 0
	for upgrade in PrestigeData.prestige_upgrades.values():
		# counting from PrestigeData and not from ui elements
		# since one could be scheduled to be removed while this function is running
		if upgrade.enabled:
			total_cost += upgrade.cost
	var points_left = PrestigeData.upgrade_points - total_cost
	tally.text = "Selected upgrades cost %s total points. You have %s points left" % [total_cost, points_left]
	if points_left < 0:
		tally.set("theme_override_colors/font_color", Color.RED)
		prestige_button.disabled = true
	else:
		tally.set("theme_override_colors/font_color", Color.WHITE)
		prestige_button.disabled = false
	return points_left


func _create_upgrade_box(id: int):
	var upgrade = PrestigeData.prestige_upgrades[id]
	var upgrade_box = upgrade_box_scene.instantiate()
	upgrade_box.prestige_upgrade = upgrade
	upgrade_box.toggle_enabled = toggle_upgrade
	upgrade_box.change_filter = change_filter
	if upgrade.enabled:
		selected_upgrades.add_child(upgrade_box)
	else:
		var filter = _get_filter()
		if filter != -1 and filter != upgrade.type:
			upgrade_box.visible = false
		unselected_upgrades.add_child(upgrade_box)
	_tally_costs()


func _change_filter(selected: int):
	var filter = _get_filter()
	change_filter.emit(filter)


func _get_filter() -> int:
	var toreturn
	match filter_select.selected:
		0:
			toreturn = -1
		1:
			toreturn = Enums.prestige_upgrade_type.UPGRADE
		2:
			toreturn = Enums.prestige_upgrade_type.UNLOCK
		3:
			toreturn = Enums.prestige_upgrade_type.BOOTSTRAP
	return toreturn


func _prestige():
	if _tally_costs() < 0:
		return
	get_tree().change_scene_to_file("res://main/main.tscn")
