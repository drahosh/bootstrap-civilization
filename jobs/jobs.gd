extends ReorderableVBox

var job_line: PackedScene = preload("res://jobs/job.tscn")
var population: Population
# Called when the node enters the scene tree for the first time.


func _setup():
	print("initializing jobs")
	for job in [Enums.jobs.GATHERING, Enums.jobs.HUNTING, Enums.jobs.TOOLMAKING]:
		var line = DefaultJobs.create_default_job(job)
		self.add_child(line)


func _ready():
	super._ready()
	self._setup()
	GlobalSignals.unlock_job.connect(unlock_job)
	pass  # Replace with function body.


func set_population(population: Population):
	self.population = population


func tick():
	var remaining_workforce = population.workforce_total
	# for job in all child jobs, ordered based on drag and drop
	for job: JobLine in self.get_children():
		job.process_crises()
		var used_workforce = min(remaining_workforce, job.get_desired_workforce())
		job.workforce_current = used_workforce
		job.tick()
		remaining_workforce -= used_workforce


func save_game():
	var save_dict = {}
	var children = get_children()
	for i in range(children.size()):
		# saving them under their order number to keep their order in queue
		save_dict[i] = children[i].save_game()
	return save_dict


func load_game(data_dict):
	for child in get_children():
		child.free()
	for i in range(data_dict.size()):
		var line = job_line.instantiate()
		line.load_game(data_dict[str(i)])  # file is converted to str json, we need to get it by float
		self.add_child(line)


func unlock_job(job: int):
	var line = DefaultJobs.create_default_job(job)
	self.add_child(line)


func reset():
	for child in get_children():
		child.free()
	_setup()
