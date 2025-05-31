extends Control

static var year_miliseconds = 2000
static var miliseconds_saved = 0
@onready var population = get_node("HSplitContainer/VScrollBar/VBoxContainer/Population")
@onready var jobs = get_node("HSplitContainer/Clickables/TabContainer/Jobs")
@onready var resources = get_node("HSplitContainer/VScrollBar/VBoxContainer/Resources")


# Called when the node enters the scene tree for the first time.
func _ready():
	jobs.set_population(population)


func _tick():
	resources.tick()
	population.tick()
	jobs.tick()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	miliseconds_saved += delta * 1000
	if miliseconds_saved > year_miliseconds:
		miliseconds_saved -= year_miliseconds
		_tick()
