extends PanelContainer
class_name AbstractCompulsoryResearch

###########################################################
# How compulsory research works:
#    - If active, on each tick, advances by specific equation defined for it
#    - When advances to 100%, fisnishes if theres an unpaid delay cost
#    - if all delay costs are paid, instead returns to 0% and starts again
#    - delay costs are exponential based on number of times delayed this run
#    - on each tick, if delay button is on, and you have more of a resource than an unpaid delay cost,
#       that delay cost is paid in full
#    - All effects of research must be saved separately, research is not reapplied on load
###########################################################

var delay_cost_paid: Dictionary  # resource_type -> bool

var delayed_this_run: int = 0
var completed = false
var unlocked = false
var prevented = false
var progress = 0.0
###########################################################
# variables to be set by extending class
var base_delay_cost: Dictionary
var research_type: int  # used to find specific implementation when loading
var description: String
###########################################################


func _ready():
	for key in base_delay_cost:
		delay_cost_paid[key] = false
	GlobalSignals.unlock_research.connect(unlock)
	GlobalSignals.prevent_research.connect(prevent)


func save_game():
	return {
		"delayed_this_run": delayed_this_run,
		"research_type": research_type,
		"description": description,
		"completed": completed,
		"unlocked": unlocked,
		"delay_cost_paid": delay_cost_paid,
		"delay_enabled": $VBoxContainer/HBoxContainer/DelayButton.button_pressed
	}


func load_game(data_dict: Dictionary):
	# called in implementation after it's found by another node based on research_type
	delayed_this_run = data_dict["delayed_this_run"]
	description = data_dict["description"]
	completed = data_dict["completed"]
	unlocked = data_dict["unlocked"]
	for key in data_dict["delay_cost_paid"]:
		delay_cost_paid[int(key)] = data_dict["delay_cost_paid"][key]
	progress = data_dict["progress"]
	$VBoxContainer/HBoxContainer/DelayButton.button_pressed = data_dict["enabled"]
	if unlocked and not completed:
		visible = true
	$VBoxContainer/HBoxContainer/Description.text = description
	draw_progress()


func _get_current_cost() -> Dictionary:
	if delayed_this_run == 0:
		return base_delay_cost
	else:
		var current_cost = {}
		for key in base_delay_cost:
			current_cost[key] = base_delay_cost[key] * pow(GlobalVariables.research_delay_scale, delayed_this_run)
		return current_cost


func draw_progress():
	$VBoxContainer/ProgressBar.value = 100.0 * progress


func tick():
	if completed or not unlocked:
		return
	if $VBoxContainer/HBoxContainer/DelayButton.pressed:
		# pay delay costs
		var delay_cost = _get_current_cost()
		for key in delay_cost:
			if not delay_cost_paid[key]:
				if Resources.resources[key] <= delay_cost[key]:
					Resources.change_resources({key: delay_cost[key]}, true)
					delay_cost_paid[key] = true

	progress += calculate_added_progress()
	if progress >= 1:
		if delay_cost_paid.values().all(func(x): x == true):
			# all delay costs are paid, we are delaying
			progress = 0
			delayed_this_run += 1
			for key in delay_cost_paid:
				delay_cost_paid[key] = false
		else:
			completed = true
			finish_success()


func unlock(_research_type: int):
	if prevented or _research_type != research_type:
		# already blocked or signal is not meant for this research
		return
	unlocked = true
	if not completed:
		visible = true
	draw_progress()


func prevent(_research_type: int):
	if _research_type != research_type:
		# already done or signal is not meant for this research
		return
	unlocked = false
	prevented = true
	visible = false
	draw_progress()


###########################################################
# functions to be implemented by extending class
func calculate_added_progress():
	# returns how much progress increases in this tick
	pass


func finish_success():
	# action to be taken after research finishes without delaying
	pass
###########################################################
