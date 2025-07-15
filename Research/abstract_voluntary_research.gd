extends PanelContainer

class_name AbstractVoluntaryResearch
###########################################################
# How voluntary research works:
#    - If active (enabled and visible), on each tick, pays some percentage of owned
#  resources into research cost
#    - When all resources are paid, has a chance to finish succesfully
#    - If research succeeds, it turns invisible andd its effects are applied
#    - If it fails, both cost and chance to succeed next time increases
#    - Chance increase persists through resets, cost increase doesn't
#    - All effects of research must be saved separately, research is not reapplied on load
###########################################################
var research_cost_paid: Dictionary
var attempted_this_run: int = 0
var attempted_total: int = 0
var completed = false
var unlocked = false
###########################################################
# variables to be set by extending class
var base_research_cost: Dictionary
var base_success_chance: int  # as percentage
var research_type: int  # used to find specific implementation when loading
var description: String
###########################################################


func _ready():
	for key in base_research_cost:
		research_cost_paid[key] = 0
	GlobalSignals.unlock_research.connect(unlock)


func save_game():
	return {
		"attempted_this_run": attempted_this_run,
		"attempted_total": attempted_total,
		"research_type": research_type,
		"description": description,
		"completed": completed,
		"unlocked": unlocked,
	}


func load_game(data_dict: Dictionary):
	# called in implementation after it's found by another node based on research_type
	attempted_this_run = data_dict["attempted_this_run"]
	attempted_total = data_dict["attempted_total"]
	description = data_dict["description"]
	completed = data_dict["completed"]
	unlocked = data_dict["unlocked"]
	if unlocked and not completed:
		visible = true
	draw_description()
	draw_progress()


func _get_current_cost() -> Dictionary:
	if attempted_this_run == 0:
		return base_research_cost
	else:
		var current_cost = {}
		for key in base_research_cost:
			current_cost[key] = base_research_cost[key] * pow(GlobalVariables.research_scale, attempted_this_run)
		return current_cost


func _get_success_chance() -> int:
	# returns percentage
	return min(base_success_chance * (1 + attempted_total), 100)


func draw_description():
	$VBoxContainer/HBoxContainer/Description.text = (
		description + "\n" + "Success_chance: %s%%(%s%%)" % [_get_success_chance(), base_success_chance]
	)


func draw_progress():
	# draws research percentage and cost/total
	# research percentage is the minimum percentage paid of all resources
	var text = ""
	var percentage: float = 100.0
	var current_cost = _get_current_cost()
	for key in current_cost:
		if text != "":
			text += "\n"
		text += "%s: %s/%s" % [Enums.resource_names[key], research_cost_paid[key], current_cost[key]]
		percentage = min(percentage, research_cost_paid[key] * 100.0 / current_cost[key])
	$VBoxContainer/HBoxContainer/Costs.text = text
	$VBoxContainer/ProgressBar.value = percentage


func tick():
	# attempt to pay research cost using resources, but can pa at most research_input_ratio of each resource
	if completed or not unlocked or not $VBoxContainer/Enabled.button_pressed:
		return
	var current_cost = _get_current_cost()
	var paid_everything = true
	for key in current_cost:
		var needed_cost = current_cost[key] - research_cost_paid[key]
		if needed_cost == 0:
			continue
		if needed_cost <= Resources.resources[key] * GlobalVariables.research_input_ratio:
			Resources.change_resources({key: needed_cost}, true)
			research_cost_paid[key] = current_cost[key]
		else:
			paid_everything = false
			var payable = Resources.resources[key] * GlobalVariables.research_input_ratio
			Resources.change_resources({key: payable}, true)
			research_cost_paid[key] += payable
	if paid_everything:
		finish()
	else:
		draw_progress()


func unlock(_resesarch_type: int):
	if _resesarch_type != research_type:
		# signal is not meant for this research
		return
	unlocked = true
	if not completed:
		visible = true
	draw_description()
	draw_progress()


func finish():
	# Called when all costs are paid. Decides if research succeeds.
	# if not, increases costs for this run and success chance for this and futur runs
	if randf() <= _get_success_chance() / 100.0:
		#success
		completed = true
		visible = false
		finish_success()
	else:
		for key in research_cost_paid:
			research_cost_paid[key] = 0
		attempted_this_run += 1
		attempted_total += 1
		draw_progress()
		draw_description()


func reset():
	for key in base_research_cost:
		research_cost_paid[key] = 0
	attempted_this_run = 0
	unlocked = false
	completed = false


###########################################################
# function to be implemented by extending class
func finish_success():
	# action to be taken after research ends in a success
	pass
###########################################################
