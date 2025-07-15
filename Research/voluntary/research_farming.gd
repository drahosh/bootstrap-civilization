extends AbstractVoluntaryResearch
class_name ResearchFarming


func _ready():
	base_research_cost = {
		Enums.resource_types.CULTURE: 1000,
	}
	base_success_chance = 10
	research_type = Enums.research_type.FIBERS
	description = "Convince your civilization to settle down\n gathering turns into farming, halving output but tripling capacity"
	super._ready()


func finish_success():
	GlobalSignals.research_job_change.emit(
		Enums.jobs.GATHERING,
		{
			Enums.research_job_changes.OUTPUT_MULTIPLIER: 0.5,
			Enums.research_job_changes.CAPACITY_MULTIPLIER: 3,
			Enums.research_job_changes.NEW_JOB_TYPE: Enums.jobs.FARMING
		}
	)
	# TODO enter next age
