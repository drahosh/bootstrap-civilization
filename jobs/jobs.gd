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
	pass  # Replace with function body.


func set_population(population: Population):
	self.population = population


func tick():
	var remaining_workforce = population.workforce_total
	# for job in all child jobs, ordered based on drag and drop
	for job: JobLine in self.get_children():
		var used_workforce = min(remaining_workforce, job.get_desired_workforce())
		job.workforce_current = used_workforce
		job.tick()
		remaining_workforce -= used_workforce
