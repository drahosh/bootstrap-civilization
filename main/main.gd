extends Control

static var year_seconds = 2.0
@onready var population = $HSplitContainer/ScrollContainer/VBoxContainer/Population
@onready var jobs = $HSplitContainer/Clickables/TabContainer/Jobs/ReorderableVBox
@onready var resources = $HSplitContainer/ScrollContainer/VBoxContainer/Resources
@onready var unlocks = $HSplitContainer/Clickables/TabContainer/Unlocks
@onready var research = $LockedSections/Tech
@onready var upgrades = $LockedSections/Upgrades
@onready var timeControl = $TimeControl/TimeBar
@onready var crises = $HSplitContainer/ScrollContainer/VBoxContainer/Crises
@onready var prestigeTab = $LockedSections/Prestige
static var time_since_last_save = 0.0
static var save_interval_s = 15.0
var last_timestamp = Time.get_unix_time_from_system()
var saved_time = 0.0  # time used for normal operation in between process ticks
var turbo_time = 0.0  # time used for turbo
var unlocked_sections = []

signal trigger_prestige


# Called when the node enters the scene tree for the first time.
func _ready():
	jobs.set_population(population)
	if PrestigeData.prestige_points == 0:
		# We have never prestiged, meaning we got here by starting the game, not after prestiging
		self.load_game()
	else:
		soft_reset()  # need to delete some data that remained even after scene change, for example top bar
	$HSplitContainer/ScrollContainer/VBoxContainer/HardResetButton.pressed.connect(hard_reset)
	GlobalSignals.unlock_section.connect(unlock_section)
	trigger_prestige.connect(_trigger_prestige)
	prestigeTab.set_signal(trigger_prestige)
	PrestigeData.apply_prestige_upgrades()


func _tick():
	research.tick()
	population.tick()
	resources.process_perishables()
	jobs.tick()
	upgrades.tick()
	unlocks.tick()
	resources.tick()
	crises.tick()
	timeControl.tick()
	prestigeTab.queue_redraw()  # redraw needed while active


func _add_turbo_time(_time):
	# maximum saved turbo time is 12 hours
	turbo_time = min(turbo_time + _time, 12 * 3600)


func _process(_delta):
	# this function:
	# - processes time difference
	# - decides to call tick based on time and turbo speed, then adjusts them
	# - sets bonus time in timeControl (this can disable turbo)
	# - calss save_game every save_interval_s seconds

	# We use timestamp difference instead of delta to account for time when game is turned off
	var timestamp = Time.get_unix_time_from_system()
	var seconds_passed = timestamp - last_timestamp
	last_timestamp = timestamp
	time_since_last_save += seconds_passed
	# in case of unfocused tab we want to quickly speedrun up to 10 seconds
	if seconds_passed < 10:
		saved_time += seconds_passed
	else:
		_add_turbo_time(seconds_passed)
	var time_mult = timeControl.get_time_multiplier()
	if time_mult > 0:
		# not paused or max speed
		var real_time_needed = year_seconds / time_mult
		if saved_time >= real_time_needed:
			# Moving from saved time to bonus time, then using bonus time for multiticks
			saved_time -= real_time_needed
			turbo_time -= year_seconds - real_time_needed
			if turbo_time < 0:
				saved_time -= turbo_time  #can go negative but thats ok, will just make next tick later
				turbo_time = 0
			_tick()
	if time_mult == -1:
		# max speed:
		if saved_time + turbo_time >= year_seconds:
			if saved_time >= year_seconds:
				saved_time -= year_seconds
			else:
				turbo_time -= year_seconds
				if turbo_time < 0:
					saved_time -= turbo_time
					turbo_time = 0
			_tick()
	if time_mult == 0:
		_add_turbo_time(saved_time)
		saved_time = 0
	timeControl.set_turbo_time(turbo_time)
	if time_since_last_save > save_interval_s:
		time_since_last_save = 0
		save_game()
	if Population.population_total == 0:
		# TODO make some popup
		_trigger_prestige()


func unlock_section(section: int):
	if section not in unlocked_sections:
		unlocked_sections.append(section)
		match section:
			Enums.UnlockableSections.UPGRADES:
				upgrades.reparent($HSplitContainer/Clickables/TabContainer)
			Enums.UnlockableSections.RESEARCH:
				research.reparent($HSplitContainer/Clickables/TabContainer)
			Enums.UnlockableSections.PRESTIGE:
				prestigeTab.reparent($HSplitContainer/Clickables/TabContainer)


func save_game():
	var save_dict = {
		"filename": get_scene_file_path(),
		"last_timestamp": last_timestamp,
		"turbo_time": turbo_time,
		"year": timeControl.year,
		"age": timeControl.age,
		"resources": resources.save_game(),
		"population": population.save_game(),
		"jobs": jobs.save_game(),
		"unlocks": unlocks.save_game(),
		"research": research.save_game(),
		"crises": crises.save_game(),
		"unlocked_sections": unlocked_sections,
		"prestige": PrestigeData.save_game()
	}
	var save_file = FileAccess.open("user://bootstrapciv_savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)


func load_game():
	# Attempts to load game from savefile
	# Returns true if game was loaded
	if not FileAccess.file_exists("user://bootstrapciv_savegame.save"):
		return false
	var save_file = FileAccess.open("user://bootstrapciv_savegame.save", FileAccess.READ)
	var json = JSON.new()
	var json_string = save_file.get_line()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		# TODO warn user, give them save file, pause until they click ok
		return false
	# TODO try loadding and on failure warn user and give them save file, and pause until they click ok
	var data = json.data
	last_timestamp = data["last_timestamp"]
	timeControl.set_year(data["year"])
	timeControl.change_age(data["age"])
	turbo_time = data["turbo_time"]
	resources.load_game(data["resources"])
	population.load_game(data["population"])
	jobs.load_game(data["jobs"])
	unlocks.load_game(data["unlocks"])
	research.load_game(data["research"])
	crises.load_game(data["crises"])
	for section in data["unlocked_sections"]:
		unlock_section(section)
	PrestigeData.load_game(data["prestige"])
	return true


func soft_reset():
	# Usually Prestige
	unlocked_sections = []
	if PrestigeData.prestige_points > 0:
		# start with prestige tab open if you did it already
		unlock_section(Enums.UnlockableSections.PRESTIGE)
	upgrades.reset()
	upgrades.reparent($LockedSections)
	population.reset()
	resources.reset()
	jobs.reset()
	unlocks.reset()
	research.reset()
	crises.reset()
	upgrades.reparent($LockedSections)
	research.reparent($LockedSections)
	prestigeTab.reparent($LockedSections)
	saved_time = 0
	timeControl.set_year(1)
	timeControl.change_age(Enums.ages.NOMADIC)


func hard_reset():
	if FileAccess.file_exists("user://bootstrapciv_savegame.save"):
		DirAccess.remove_absolute("user://bootstrapciv_savegame.save")
	research.hard_reset()
	time_since_last_save = 0.0
	year_seconds = 2
	turbo_time = 0
	unlocked_sections = []
	soft_reset()


func _trigger_prestige():
	save_game()
	PrestigeData.prestige(Population.max_population_this_run, TopBar.age)
	get_tree().change_scene_to_file("res://prestige/prestige_screen.tscn")
