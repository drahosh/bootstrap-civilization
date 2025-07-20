extends PanelContainer

var trigger_prestige_signal: Signal


func _draw():
	var formatString1 = "Your maximum population from this run is %s and you've completed %s ages."
	formatString1 += "\nThis would grant you %s prestige points."
	$VBoxContainer/PointGain.text = (
		formatString1
		% [
			Population.max_population_this_run,
			TopBar.age,
			PrestigeData.calculate_prestige_points(Population.max_population_this_run, TopBar.age)
		]
	)
	var prediction = PrestigeData.calculate_next_prestige(Population.max_population_this_run, TopBar.age)
	var formatString2 = "You currently have %s prestige upgrade points."
	formatString2 += "\nIf you start again from the beginning now, you'd get %s more prestige upgrade points."
	formatString2 += "\nYou need %s more prestige points for the next prestige upgrade point."
	$VBoxContainer/PointPrediction.text = (
		formatString2 % [PrestigeData.upgrade_points, prediction["upgrade_points"], prediction["next"]]
	)


func _ready():
	$VBoxContainer/PrestigeButton.pressed.connect(prestige)


func prestige():
	trigger_prestige_signal.emit()


func set_signal(s: Signal):
	trigger_prestige_signal = s
