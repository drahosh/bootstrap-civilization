extends Control

static var year_seconds = 2.0
@onready var population = get_node("HSplitContainer/ScrollContainer/VBoxContainer/Population")
@onready var jobs = $HSplitContainer/Clickables/TabContainer/Jobs/ReorderableVBox
@onready var resources = get_node("HSplitContainer/ScrollContainer/VBoxContainer/Resources")
@onready var unlocks = get_node("HSplitContainer/Clickables/TabContainer/Unlocks")
@onready var research = get_node("LockedSections/ResearchList")
@onready var upgrades = $LockedSections/Upgrades
@onready var timeControl = $TimeControl/TimeBar
static var time_since_last_save = 0.0
static var save_interval_s = 15.0
var last_timestamp = Time.get_unix_time_from_system()
var saved_time = 0.0  # time used for normal operation in between process ticks
var turbo_time = 0.0  # time used for turbo
var unlocked_sections = []


# Called when the node enters the scene tree for the first time.
func _ready():
	jobs.set_population(population)
	self.load_game()
	$HSplitContainer/ScrollContainer/VBoxContainer/HardResetButton.pressed.connect(hard_reset)
	GlobalSignals.unlock_section.connect(unlock_section)


func _tick():
	research.tick()
	population.tick()
	resources.process_perishables()
	jobs.tick()
	unlocks.tick()
	resources.tick()
	timeControl.tick()


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


func unlock_section(section: int):
	if section not in unlocked_sections:
		unlocked_sections.append(section)
		match section:
			Enums.UnlockableSections.UPGRADES:
				upgrades.reparent($HSplitContainer/Clickables/TabContainer)
			Enums.UnlockableSections.RESEARCH:
				research.reparent($HSplitContainer/Clickables/TabContainer)


func save_game():
	var save_dict = {
		"filename": get_scene_file_path(),
		"last_timestamp": last_timestamp,
		"turbo_time": turbo_time,
		"year": timeControl.year,
		"resources": resources.save_game(),
		"population": population.save_game(),
		"jobs": jobs.save_game(),
		"unlocks": unlocks.save_game(),
		"research": research.save_game(),
		"unlocked_sections": unlocked_sections,
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
	var data = json.data
	last_timestamp = data["last_timestamp"]
	timeControl.set_year(data["year"])
	turbo_time = data["turbo_time"]
	resources.load_game(data["resources"])
	population.load_game(data["population"])
	jobs.load_game(data["jobs"])
	unlocks.load_game(data["unlocks"])
	research.load_game(data["research"])
	for section in data["unlocked_sections"]:
		unlock_section(section)
	return true


func soft_reset():
	# Usually Prestige
	unlocked_sections = []  # TODO keep prestige when implemented
	upgrades.reset()
	upgrades.reparent($LockedSections)
	population.reset()
	resources.reset()
	jobs.reset()
	unlocks.reset()
	research.reset()
	upgrades.reparent($LockedSections)
	research.reparent($LockedSections)
	saved_time = 0
	timeControl.set_year(1)


func hard_reset():
	if FileAccess.file_exists("user://bootstrapciv_savegame.save"):
		DirAccess.remove_absolute("user://bootstrapciv_savegame.save")
	research.hard_reset()
	time_since_last_save = 0.0
	year_seconds = 2
	turbo_time = 0
	unlocked_sections = []
	soft_reset()
