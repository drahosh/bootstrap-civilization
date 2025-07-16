extends HBoxContainer
### This script only exists to handle buttons and display current year.
### Ticking and related timestamp control saving is still controlled from main
### Even saving year is done from main

class_name TopBar

var year = 1
var turbo_time: int = 0  # in whole seconds
static var buy_multiplier = 1  # can be positive int or "MAX"


func _ready():
	$VBoxContainer2/BuyOptions.item_selected.connect(_change_multiplier)


func _change_multiplier(selected):
	match $VBoxContainer2/BuyOptions.selected:
		0:
			buy_multiplier = 1
		1:
			buy_multiplier = 10
		2:
			buy_multiplier = "MAX"


func tick():
	year += 1
	$Year.text = "Year %s" % year


func set_year(_year):
	year = int(_year)  # can be float from loading
	$Year.text = "Year %s" % year


func get_time_multiplier() -> int:
	# returning -1 means max
	# returning 0 means game is paused
	if $Pause.button_pressed:
		return 0
	if $HBoxContainer/Turbo.button_pressed:
		match $HBoxContainer/TurboOptions.selected:
			0:
				return 2
			1:
				return 5
			2:
				return 10
			3:
				return -1
	return 1


func stop_turbo():
	$HBoxContainer/Turbo.pressed = false


func set_turbo_time(_turbo_time: float):
	turbo_time = floor(_turbo_time)
	if turbo_time == 0:
		$HBoxContainer/Turbo.button_pressed = false
		$HBoxContainer/Turbo.disabled = true
	else:
		$HBoxContainer/Turbo.disabled = false
	# no need to do days since max saved time is less than a day
	var hours = turbo_time / 3600
	var minutes = (turbo_time % 3600) / 60
	var seconds = turbo_time % 60
	$HBoxContainer/Label.text = "Saved time: %sh %sm %ss" % [hours, minutes, seconds]
