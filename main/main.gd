extends Control

static var year_miliseconds = 2000
static var miliseconds_saved = 0
@onready var population = get_node("HSplitContainer/ScrollContainer/VBoxContainer/Population")
@onready var jobs = get_node("HSplitContainer/Clickables/TabContainer/Jobs")
@onready var resources = get_node("HSplitContainer/ScrollContainer/VBoxContainer/Resources")
@onready var unlocks = get_node("HSplitContainer/Clickables/TabContainer/Unlocks")
static var time_since_last_save = 0.0
static var save_interval_s = 15.0


# Called when the node enters the scene tree for the first time.
func _ready():
	jobs.set_population(population)
	self.load_game()
	$HSplitContainer/ScrollContainer/VBoxContainer/HardResetButton.pressed.connect(hard_reset)


func _tick():
	resources.tick()
	population.tick()
	jobs.tick()
	unlocks.tick()


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


func save_game():
	var save_dict = {
		"filename": get_scene_file_path(),
		"timestamp": Time.get_unix_time_from_system(),
		"miliseconds_saved": miliseconds_saved,
		"resources": resources.save_game(),
		"population": population.save_game(),
		"jobs": jobs.save_game(),
		"unlocks": unlocks.save_game(),
	}
	var save_file = FileAccess.open("user://bootstrapciv_savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)


func load_game():
	print(OS.get_data_dir())
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
	return true


func hard_reset():
	if FileAccess.file_exists("user://bootstrapciv_savegame.save"):
		DirAccess.remove_absolute("user://bootstrapciv_savegame.save")
	population.reset()
	resources.reset()
	jobs.reset()
	unlocks.reset()
	time_since_last_save = 0.0
	miliseconds_saved = 0
	year_miliseconds = 2000
