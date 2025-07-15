extends Control

static var year_miliseconds = 2000
static var miliseconds_saved = 0
@onready var population = get_node("HSplitContainer/ScrollContainer/VBoxContainer/Population")
@onready var jobs = get_node("HSplitContainer/Clickables/TabContainer/Jobs")
@onready var resources = get_node("HSplitContainer/ScrollContainer/VBoxContainer/Resources")
@onready var unlocks = get_node("HSplitContainer/Clickables/TabContainer/Unlocks")
@onready var research = get_node("LockedSections/ResearchList")
@onready var upgrades = $LockedSections/Upgrades
static var time_since_last_save = 0.0
static var save_interval_s = 15.0
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	miliseconds_saved += delta * 1000
	if miliseconds_saved > year_miliseconds:
		miliseconds_saved -= year_miliseconds
		_tick()
	time_since_last_save += delta
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
		"timestamp": Time.get_unix_time_from_system(),
		"miliseconds_saved": miliseconds_saved,
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
	#TODO bonus turbo time from timestamp
	miliseconds_saved = data["miliseconds_saved"]
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


func hard_reset():
	if FileAccess.file_exists("user://bootstrapciv_savegame.save"):
		DirAccess.remove_absolute("user://bootstrapciv_savegame.save")
	research.hard_reset()
	time_since_last_save = 0.0
	miliseconds_saved = 0
	year_miliseconds = 2000
	unlocked_sections = []
