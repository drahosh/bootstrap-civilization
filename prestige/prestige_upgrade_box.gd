extends Control
class_name PrestigeUpgradeBox
# vars assigned by scene instantiator
var prestige_upgrade: PrestigeUpgrade
var toggle_enabled: Signal
var change_filter: Signal


func _draw():
	$VBoxContainer/Name.text = prestige_upgrade.title
	$VBoxContainer/Description.text = prestige_upgrade.description
	$VBoxContainer/Cost.text = "Cost: %s" % prestige_upgrade.cost
	$VBoxContainer/Button.text = "Deactivate" if prestige_upgrade.enabled else "Activate"


func _ready() -> void:
	$VBoxContainer/Button.pressed.connect(toggle_upgrade)
	change_filter.connect(toggle_visible)


func toggle_visible(filter: int):
	if prestige_upgrade.enabled or filter == -1 or filter == prestige_upgrade.type:
		show()
	else:
		hide()


func toggle_upgrade():
	# Signal tells parent to create box in correct container for the enabled state
	prestige_upgrade.enabled = !prestige_upgrade.enabled
	toggle_enabled.emit(prestige_upgrade.id)
	queue_free()
