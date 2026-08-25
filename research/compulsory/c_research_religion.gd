extends AbstractCompulsoryResearch
class_name CResearchReligion


func _ready():
	base_delay_cost = {Enums.resource_types.CULTURE: 200}
	research_type = Enums.research_type.RELIGION
	description = "Organized religion\nCreates a class of priests\n Advances by 1% per 1000 population"
	super._ready()


func calculate_added_progress():
	# returns how much progress increases in this tick
	return Population.population_total * 0.001


func finish_success():
	# action to be taken after research finishes without delaying
	pass
