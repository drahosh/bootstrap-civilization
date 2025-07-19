extends Node
class_name DefaultJobs
const Enums = preload("res://data/enums.gd")
const job_line: PackedScene = preload("res://jobs/job.tscn")


static func create_default_job(job: int) -> JobLine:
	# returns default state of the selected job from enum
	var jobs = Enums.jobs
	var line = job_line.instantiate() as JobLine
	const r = Enums.resource_types
	# initialize the line based on what type of job it is
	# initializes with: name, base workforce max, base income per workforce, bases description, base upgrade costs
	match job:
		jobs.GATHERING:
			(
				line
				. init(
					job,
					10,
					{r.FOOD: 2, r.MATERIALS: 0.1},
					{},
					{r.TOOLS: 10},
					"Walk around looking for stuff to eat",
					1,
				)
			)
		jobs.HUNTING:
			(
				line
				. init(
					job,
					10,
					{r.FOOD: 2, r.TEXTILES: 0.2},
					{},
					{r.TOOLS: 20},
					"Hunt larger animals in groups",
					1,
				)
			)
		jobs.TOOLMAKING:
			line.init(job, 10, {r.TOOLS: 1}, {r.MATERIALS: 1}, {r.MATERIALS: 20}, "Make tools", 2)
		jobs.CLOTHESMAKING:
			line.init(job, 10, {r.CLOTHES: 1}, {r.TEXTILES: 1}, {r.TOOLS: 20, r.TEXTILES: 100}, "Make clothes", 3)
		jobs.RECREATION:
			line.init(job, 10, {r.CULTURE: 0.1}, {}, {r.FOOD: 100, r.TOOLS: 10}, "Rest, Play, Make art", 1)
		jobs.WOODCUTTING:
			line.init(job, 10, {r.MATERIALS: 3}, {r.TOOLS: 1}, {r.TOOLS: 100}, "Cut wood", 5)
		jobs.ARTMAKING:
			line.init(
				job,
				10,
				{r.CULTURE: 5, r.LUXURY: 1},
				{r.TOOLS: 1, r.MATERIALS: 1, r.TEXTILES: 1},
				{r.TOOLS: 100, r.CULTURE: 100},
				"Make art",
				10
			)
		_:
			printerr("job number doesn't exist: " + str(job))
	return line
