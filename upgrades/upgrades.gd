extends ScrollContainer


func add_upgrade(upgrade: JobUpgrade):
	$VBoxContainer.add_child(upgrade)


func reset():
	for child in $VBoxContainer.get_children():
		child.free()


func _ready():
	GlobalSignals.add_upgrade.connect(add_upgrade)


func tick():
	for child in $VBoxContainer.get_children():
		child.toggle_affordable()
